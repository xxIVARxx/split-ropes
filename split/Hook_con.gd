#extends Node
#
#@export var launch_action_name: String
#@export var hook_scene: PackedScene = preload("res://addons/grappling_hook_3d/src/hook.tscn")
#@export var RayCast3d: RayCast3D
#signal hook_attached()
#signal hook_launched()
#var _hook_model: Node3D
#
#var _hook_target_normal: Vector3
#var hook_target_position: Vector3
#func ready():
	#hook_launched.emit()
	#var hook_target_position =$"../box3/box4/Marker3D" 
	#var _hook_target_normal =$"../box3/box5/Marker3D"
	#_hook_model = hook_scene.instantiate()
	#add_child(_hook_model)
	#hook_attached.emit()
