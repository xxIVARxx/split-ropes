extends Node3D

# Define variables for the start and end points of the laser beam
var start_point : Vector3 = Vector3.ZERO
var end_point : Vector3 = Vector3(0, 0, 10)

# Reference to the laser beam mesh
var laser_beam_mesh : MeshInstance3D

# Define variables for controlling the scaling animation
var scaling_started : bool = false
var scaling_forward : bool = true
var scale_duration : float = 1.0
var scale_timer : float = 0.0
var _debug_keep_effect : bool = false
var delegator 

func _ready():
	var laser_beam_mesh_scene : PackedScene = preload("res://laser/laser_beam_mesh.tscn")
	laser_beam_mesh = laser_beam_mesh_scene.instantiate()
	add_child(laser_beam_mesh)
	laser_beam_mesh.global_transform.origin = start_point
	laser_beam_mesh.look_at(end_point, Vector3.MODEL_FRONT)
	laser_beam_mesh.delegator = delegator

func _process(delta):
	if Input.is_action_pressed("hit"):
		start_scaling()
		
	if scaling_started:
		if scaling_forward:
			scale_timer += delta / scale_duration
			if scale_timer >= 1.0:
				scale_timer = 1.0
				scaling_forward = false
				finishing()
		else:
			if _debug_keep_effect:
				return
			scale_timer -= delta / scale_duration
			if scale_timer <= 0.0:
				scale_timer = 0.0
				scaling_started = false
				finishing()
	
		# Interpolate the scale factor
		var scale_factor = lerp(0.1, 1.0, scale_timer)
		laser_beam_mesh.scale.z = scale_factor * start_point.distance_to(end_point)

func start_scaling():
	scaling_started = true
	scaling_forward = true
	scale_timer = 0.0

func finishing():
	get_parent()._is_hitting = false
	queue_free()


