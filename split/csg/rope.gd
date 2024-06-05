extends CSGMesh3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var data = get_meshes()
	print("data: ",len(data))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
