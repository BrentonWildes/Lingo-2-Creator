extends Node3D

@export var material:Material = load("res://assets/materials/white.material")

func _ready():
	for child in get_node("Meshes").get_children():
		child.set_surface_override_material(0, material)
