extends CollisionObject3D
class_name RopeSegment

var radius := 0.5

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collisionshape: CollisionShape3D = $CollisionShape3D


func _ready():
	var mesh: CylinderMesh = mesh_instance.mesh
	var shape: CylinderShape3D = collisionshape.shape
	#visible=false
	#mesh.radius = radius
	#mesh.height = radius * 2.0
	#
	#shape.radius = radius


func _on_body_entered(body):
	print("_on_body_entered:")
	if body.is_in_group("enemy"):
		print("enemy:")
	pass # Replace with function body.


func _on_area_entered(area):
	print("_on_area_entered:")
	if area.is_in_group("enemy"):
		print("enemy:")
	pass # Replace with function body.
