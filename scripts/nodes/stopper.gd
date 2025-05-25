extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("MeshInstance3D").queue_free()
