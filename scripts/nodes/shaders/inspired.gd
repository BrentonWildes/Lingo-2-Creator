extends MeshInstance3D

func _ready():
	for gridmap in _get_nodes_of_type(get_tree().get_root()):
		for i in gridmap.mesh_library.get_item_list():
			var mesh_map = gridmap.mesh_library.get_item_mesh(i)
			var mat = mesh_map.surface_get_material(0)
			if mat is StandardMaterial3D:
				mat.flags_unshaded = true

func _get_nodes_of_type(node: Node, result = []) -> Array:
	if node is GridMap:
		result.push_back(node)
	for child in node.get_children():
		var _discard = _get_nodes_of_type(child, result)
	return result
