extends Area3D

func _ready():
	get_node("MeshInstance3D").queue_free()
	get_node("MeshInstance3D2").queue_free()
	get_node("MeshInstance3D3").queue_free()
