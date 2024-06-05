@tool
extends MeshInstance3D

@export var iterations = 5
@export var dirty = false
@export var resolution = 10

var grapple_hook_position : Vector3 = Vector3.ZERO
var player_position : Vector3 = Vector3.ZERO

var vertex_array : PackedVector3Array = []
var uv1_array : PackedVector2Array = []
var index_array : PackedInt32Array = []
var normal_array : PackedVector3Array = []

var tangent_array : PackedVector3Array = []
var uv_array : PackedVector2Array = []

var points : PackedVector3Array = []
var points_old : PackedVector3Array = []

@export var point_count = 20

var rope_length : float = 0.0
var point_spacing : float = 0.0
@export var rope_width = .02
@export var uv_scale = .5

@export var isDrawing = false
@export var firstTime = true

@export var temp_player :Node3D
@export var temp_hook : Node3D

var texture_height_to_width = 0.5

var gravity_default = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	if not temp_hook or not temp_player:
		return
	var new_mesh = mesh.duplicate()
	set_mesh(new_mesh)
	SetGrappleHookPosition(temp_hook.global_transform.origin)
	SetPlayerPosition(temp_player.global_transform.origin)
	PreparePoints()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	SetPlayerPosition(temp_player.global_transform.origin)
#	SetGrappleHookPosition(temp_hook.position)
	
	if isDrawing || dirty:
		if firstTime:
			PreparePoints()
			firstTime = false
		UpdatePoints(delta)
		GenerateMesh()
		dirty = false


func SetGrappleHookPosition(val : Vector3):
	grapple_hook_position = val
	firstTime = true

func SetPlayerPosition(val : Vector3):
	player_position = val

func StartDrawing():
	isDrawing = true
	
func StopDrawing():
	isDrawing = false

func PreparePoints():
	points.clear()
	points_old.clear()
	
	for i in range(point_count):
		var t = i / (point_count - 1.0)
		
		points.append(lerp(player_position, grapple_hook_position, t))
		points_old.append(points[i])
		
	_UpdatePointSpacing()
	
func _UpdatePointSpacing():
	rope_length = (grapple_hook_position - player_position).length() 
	point_spacing = rope_length / (point_count - 1.0)

func UpdatePoints(delta):
	points[0] = player_position
	points[point_count-1] = grapple_hook_position

	_UpdatePointSpacing()

	for i in range(1, point_count - 1):
		var curr : Vector3 = points[i]
		points[i] = points[i] + (points[i] - points_old[i]) + (
			Vector3.DOWN * gravity_default * delta * delta)
		points_old[i] = curr
	
	for i in range(iterations):
		ConstraintConnections()
	
func ConstraintConnections():
	for i in range(point_count - 1):
		var centre : Vector3 = (points[i+1] + points[i]) / 2.0
		var offset : Vector3 = (points[i+1] - points[i])
		var length : float = offset.length()
		var dir : Vector3 = offset.normalized()
		
		var d = length - point_spacing
		
		if i != 0:
#			points[i] = centre + dir * d / 2.0
			points[i] += dir * d * 0.5
		
		if i + 1 != point_count - 1:
#			points[i+1] = centre - dir * d / 2.0
			points[i+1] -= dir * d * 0.5

func GenerateMesh():
	
	vertex_array.clear()
	uv1_array.clear()
	
	CalculateNormals()

	index_array.clear()
	
	var circumference = 2.0 * PI * rope_width
	var uv_segment_length = circumference * texture_height_to_width
	
	#segment / point
	for p in range(point_count):
		
		var center : Vector3 = points[p]
		
		var forward = tangent_array[p]
		var norm = normal_array[p]
		var bitangent = -norm.cross(forward).normalized()
		
		#UV1
		#V coordinate
#		var distance_from_end_point = (player_position - center).length()
		var distance_from_end_point = (grapple_hook_position - center).length()

		var uv1_v = distance_from_end_point / uv_segment_length
		
		#current resolution
		for c in range(resolution):
			var angle = (float(c) / resolution) * 2.0 * PI
			
			var xVal = sin(angle) * rope_width
			var yVal = cos(angle) * rope_width
			
			var point = (norm * yVal) + (bitangent * xVal) + center
			
			vertex_array.append(point)
			
			#U coordinate
			var maxAngle = 2.0 * PI
			
#			var t_u = (angle - 0.0) / (maxAngle - 0.0)
			var t_u = angle / maxAngle - 0.0
			
#			var uv1_u = lerp(0.0, 1.0, t_u) #This is therefore not necessary
			var uv1_u = t_u
			
			uv1_array.append(Vector2(uv1_u, uv1_v))
			
			if p < point_count - 1:
				var start_index = resolution * p
				#INT values
				index_array.append(start_index + c);
				index_array.append(start_index + c + resolution);
				index_array.append(start_index + ((c + 1) % resolution));
#				index_array.append(start_index + c + resolution);

				index_array.append(start_index + ((c + 1) % resolution));
				index_array.append(start_index + c + resolution);
				index_array.append(start_index + ((c + 1) % resolution) + resolution);
#				index_array.append(start_index + c + resolution);
		
#	if mesh.surface_get_arrays(0).size() != 0: print(mesh.surface_get_arrays(0)[5])
#	print("<---BEFORE-------------------------")
	mesh.clear_surfaces()
	
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	var first_triangle : bool = true
	
	var current_iter = 0
	var max_iter = resolution * 2
	
#	print(index_array.size())
	for i in range(index_array.size() / 3):
		var i1 = index_array[3*i]
		var i2 = index_array[3*i+1]
		var i3 = index_array[3*i+2]
		
		var p1 = vertex_array[i1]
		var p2 = vertex_array[i2]
		var p3 = vertex_array[i3]
		
		var uv1 = uv1_array[i1]
		var uv2 = uv1_array[i2]
		var uv3 = uv1_array[i3]
		
		if current_iter == max_iter - 1:
#			uv1.x = ceil(uv1.x) 
#			uv3.x = ceil(uv3.x)
			uv1.x = 1
			uv3.x = 1
			
		elif current_iter == max_iter - 2:
#			uv3.x = ceil(uv3.x)
			uv3.x = 1
		
		var tangent = Plane(p1, p2, p3)
		var normal = tangent.normal
		
		#1. point
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		
#		if first_triangle:
#			mesh.surface_set_uv(Vector2.ONE * uv_scale)
#			mesh.surface_set_uv2(Vector2.ONE * uv_scale)
#		else:
#			mesh.surface_set_uv(Vector2.DOWN * uv_scale)
#			mesh.surface_set_uv2(Vector2.DOWN * uv_scale)
			
		mesh.surface_set_uv(uv1 * uv_scale)	
#		mesh.surface_set_uv2((uv1 * uv_scale))
		
		
		
		mesh.surface_add_vertex(p1)
		
		#2. point
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		
#		if first_triangle:
#			mesh.surface_set_uv(Vector2.RIGHT * uv_scale)
#			mesh.surface_set_uv2(Vector2.RIGHT * uv_scale)
#		else:
#			mesh.surface_set_uv(Vector2.RIGHT * uv_scale)
#			mesh.surface_set_uv2(Vector2.RIGHT * uv_scale)
			
		mesh.surface_set_uv(uv2 * uv_scale)	
#		mesh.surface_set_uv2(uv2 * uv_scale)	
		
		mesh.surface_add_vertex(p2)
		
		#3. point
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		
#		if first_triangle:
#			mesh.surface_set_uv(Vector2.DOWN * uv_scale)
#			mesh.surface_set_uv2(Vector2.DOWN * uv_scale)
#		else:
#			mesh.surface_set_uv(Vector2.ZERO * uv_scale)
#			mesh.surface_set_uv2(Vector2.ZERO * uv_scale)

		mesh.surface_set_uv(uv3 * uv_scale)	
#		mesh.surface_set_uv2(uv3 * uv_scale)
		
		mesh.surface_add_vertex(p3)
		
		first_triangle = !first_triangle
		current_iter += 1
		if current_iter == max_iter: current_iter = 0
	# End drawing.
	mesh.surface_end()
#	print(mesh.surface_get_arrays(0)[5])
	

func CalculateNormals():
	normal_array.clear()
	tangent_array.clear()
	
	var helper
	
	for i in range(point_count):
		var tangent := Vector3(0,0,0)
		var normal := Vector3(0,0,0)
		
		var temp_helper_vector := Vector3(0,0,0)
		
		#first point
		if i == 0:
			tangent = (points[i+1] - points[i]).normalized()
		#last point
		elif i == point_count - 1:
			tangent = (points[i] - points[i-1]).normalized()
		#between
		else:
			tangent = (points[i+1] - points[i]).normalized() + (
				points[i] - points[i-1]).normalized()
			
		if i == 0:
			temp_helper_vector = -Vector3.FORWARD if (
				tangent.dot(Vector3.UP) > 0.5) else Vector3.UP
				
			normal = temp_helper_vector.cross(tangent).normalized()
			
		else:
			var tangent_prev = tangent_array[i-1]
			var normal_prev = normal_array[i-1]
			var bitangent = tangent_prev.cross(tangent)
			
			if bitangent.length() == 0:
				normal = normal_prev
			else:
				var bitangent_dir = bitangent.normalized()
				var theta = acos(tangent_prev.dot(tangent))

				var rotate_matrix = Basis(bitangent_dir, theta)
				normal = rotate_matrix * normal_prev

		tangent_array.append(tangent)
		normal_array.append(normal)
