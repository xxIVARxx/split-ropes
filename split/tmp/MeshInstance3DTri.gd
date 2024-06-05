@tool
extends MeshInstance3D


func _ready():
	var surface_tool = SurfaceTool.new();

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);

	surface_tool.set_normal(Vector3(0, 0, -1));
	surface_tool.set_color(Color(0, 0, 0, 1));
	surface_tool.add_vertex(Vector3(-1, 2, 0));
	
	surface_tool.set_normal(Vector3(0, 0, -1));
	surface_tool.set_color(Color(1, 0, 0, 1));
	surface_tool.add_vertex(Vector3(-1, 0, 0));
	
	surface_tool.set_normal(Vector3(0, 0, -1));
	surface_tool.set_color(Color(0, 0, 0, 1));
	surface_tool.add_vertex(Vector3(-1, -2, 0));
	
	surface_tool.set_normal(Vector3(0, 0, -1));
	surface_tool.set_color(Color(0, 0, 0, 1));
	surface_tool.add_vertex(Vector3(1, -2, 0));

	surface_tool.set_normal(Vector3(0, 0, -1));
	surface_tool.set_color(Color(1, 0, 0, 1));
	surface_tool.add_vertex(Vector3(1, 0, 0));
	
	surface_tool.set_normal(Vector3(0, 0, -1));
	surface_tool.set_color(Color(0, 0, 0, 1));
	surface_tool.add_vertex(Vector3(1, 2, 0));
	
	
	surface_tool.add_index(5);
	surface_tool.add_index(0);
	surface_tool.add_index(1);
	
	surface_tool.add_index(3);
	surface_tool.add_index(1);
	surface_tool.add_index(2);
	
	mesh = surface_tool.commit();
