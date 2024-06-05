extends Node3D
#class_name HookController


@export_group("Optional Settings")
@export_group("Advanced Settings")
@export_category("Hook Controller")
@export_group("Required Settings")
@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
const RopeGen: PackedScene = preload("res://RopeGenerator/RopeGenerator.tscn")
@export var hook_scene: PackedScene = preload("res://addons/grappling_hook_3d/src/hook.tscn")
const player = preload("res://player.tscn")
const RopeScene: PackedScene = preload("res://addons/rope3d/Rope3D.tscn")
var _hook_model: Node3D
var _hook_target_normal: Vector3	


@onready var start_point = $BlueCapsule/Marker3D
@onready var end_point = $BlueCapsule2/Marker3D

@onready var friend01 = $box2/Marker3D
@onready var enemy01 = $box3/Marker3D
@onready var box4 = $box4
@onready var box5 = $box5
@onready var box_6 = $box6

signal hook_launched()
signal hook_attached()
signal hook_detached()

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _ready():
	var rope = RopeScene.instantiate()
	rope.start_point = start_point
	rope.end_point = end_point
	rope.rope_length = start_point.global_transform.origin.distance_to(end_point.global_transform.origin)
	rope.resolution = 2.0
	rope.radius = 0.1
	
	var ok = rope.can_make()
	if ok:
		add_child(rope)
		rope.make()
	
	var laserMain = RopeGen.instantiate()
	laserMain.temp_hook = friend01
	laserMain.temp_player = enemy01
	add_child(laserMain)

	_hook_model = hook_scene.instantiate()
	add_child(_hook_model)
	
func _physics_process(delta):
	var source_position = box5.global_position
	var hook_target_position =  box4.global_position
	_hook_model.extend_from_to(source_position, hook_target_position, _hook_target_normal)


func _on_host_button_pressed():
	main_menu.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed():
	main_menu.hide()
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	print(">>player added: ",peer_id, " - ",multiplayer.get_unique_id())
	var player = player.instantiate()
	player.name = str(peer_id)
	player.net_id = peer_id
	player.friend = friend01
	player.delegator = self
	player._debug_keep_effect = true
	
	add_child(player)
	if peer_id == multiplayer.get_unique_id():
		print(">>draw cam update: ",peer_id)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _on_area_3d_area_entered(area):
	print("_on_area_3d_area_entered:")
	pass # Replace with function body.

func _on_area_3d_body_entered(body):
	print("_on_area_3d_body_entered:")
	pass # Replace with function body.
