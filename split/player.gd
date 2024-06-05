extends CharacterBody3D

class_name Player

const RopeScene: PackedScene = preload("res://addons/rope3d/Rope3D.tscn")
const LaserScene: PackedScene = preload("res://laser/main.tscn")
const RopeGen: PackedScene = preload("res://RopeGenerator/RopeGenerator.tscn")
@export var hook_scene: PackedScene = preload("res://addons/grappling_hook_3d/src/hook.tscn")

@onready var target = $Marker3D

@onready var camera_mount = $camera_mount
@onready var animation_player = $"visuals/Root Scene/AnimationPlayer"
#@onready var healthbar = $Healthbar

@onready var visuals = $visuals
@onready var camera = $camera_mount/Camera3D
@onready var hitbox = $"visuals/Root Scene/RootNode/RedTeam_SwordsMen_Armature/Skeleton3D/TwoHand_Sword_Iron/HitBox"
@onready var sync = $MultiplayerSynchronizer

@export var sens_horizental = 0.5
@export var sens_vertical = 0.5
@export var uuid : String

var SPEED = 3.0

const JUMP_VELOCITY = 4.5
var walking_speed = 3.0
var running_speed = 5.0

var running = false
var health = 100
var net_id = -1
var _is_hitting = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# Get the gravity from the project settings to be synced with RigidBody nodes.

var friend = null

var _debug_keep_effect = false
var delegator
var hook
var _hook_target_normal: Vector3
	
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	if has_method("get_network_master"):
		print("This character is owned by the local player.")
	else:
		print("This character is not networked.")

func _input(event):
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*sens_horizental))
		visuals.rotate_y(deg_to_rad(event.relative.x*sens_horizental))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y*sens_vertical))

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	rpc("remote_set_position", direction)
	if Input.is_action_just_pressed("hit"):
		if animation_player.current_animation != "RedTeam_SwordsMen_Armature|Atack_TwoHandSwordsMen":
			hitx.rpc()
			hitbox.monitoring = true
			#laser1(friend)
			#laser2(friend)
			#laser3(friend)
			laser4(friend)
	else:
		hitbox.monitoring = false
	
	if Input.is_action_just_released("hit"):
		if hook:
			remove_child(hook)
			hook = null
	
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = true
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if hook:
		self.hook.extend_from_to(global_position, friend.global_position, _hook_target_normal)

@rpc("call_local")
func runx():
	animation_player.play("RedTeam_SwordsMen_Armature|Running_TwoHandSwordsMen")

@rpc("call_local")
func hitx():
	animation_player.play("RedTeam_SwordsMen_Armature|Atack_TwoHandSwordsMen")

@rpc("any_peer", "call_local")
func remote_set_position(direction):
	#visuals.look_at(position + direction)
	#dirx.rpc()
	if direction:
		if running:
				runx.rpc()
				visuals.look_at(position + direction)
						
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
			#if animation_player.current_animation != "RedTeam_SwordsMen_Armature|Running_TwoHandSwordsMen":
				#animation_player.play("RedTeam_SwordsMen_Armature|Running_TwoHandSwordsMen")
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _on_hit_box_body_entered(body):
	if body.is_in_group("enemy"):
		print("damage +++")

func _on_hit_box_area_entered(area):
	print("damage from player: ")
	pass # Replace with function body.

func laser1(friend=null):
	if not friend:
		print("opponet is null")
		return
	var rope = RopeScene.instantiate()
	rope.start_point = target
	if ("target" in friend):
		rope.end_point = friend.target
		rope.rope_length = rope.start_point.global_transform.origin.distance_to(friend.target.global_transform.origin)
	else:
		rope.end_point = friend
		rope.rope_length = rope.start_point.global_transform.origin.distance_to(friend.global_transform.origin)
	rope.resolution = 1.0
	rope.radius = 0.2
	
	var ok = rope.can_make()
	if ok:
		delegator.add_child(rope)
		rope.make()
	else:
		print("cannot darw rope")

func laser2(friend=null):
	if not friend:
		print("opponet is null")
		return
	if _is_hitting:
		print("already running")
		return
	var laser = LaserScene.instantiate()
	_is_hitting = true
	laser.start_point = target.global_transform.origin
	laser.end_point = friend.global_transform.origin
	laser.scale_duration = 0.5
	laser._debug_keep_effect = _debug_keep_effect
	laser.delegator = self
	laser.start_scaling()
	add_child(laser)

func laser3(friend=null):
	if not friend:
		print("opponet is null")
		return
	var laser = RopeGen.instantiate()

	_is_hitting = false
	if ("target" in friend):
		laser.temp_hook = friend.target
	else:
		laser.temp_hook = friend
	if ("target" in target):
		laser.temp_player = target.target
	else:
		laser.temp_player = target

	delegator.add_child(laser)
	#add_child(laser)

func laser4(friend):
	if not friend:
		print("opponet is null")
		return
	if _is_hitting:
		print("already running")
		return
	var player_hook_model = hook_scene.instantiate()
	self.hook = player_hook_model
	self.add_child(self.hook)
	self.hook.extend_from_to(global_position, friend.global_position, _hook_target_normal)

func whoami():
	print("name: ",name)
