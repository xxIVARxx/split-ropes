@tool
extends Path3D

func _ready():
	curve = Curve3D.new()
	# Add your desired curve points here
	curve.add_point(Vector3(1, 0, 0))
	curve.add_point(Vector3(2, 1, 0))
	curve.add_point(Vector3(3, 0, 0))
