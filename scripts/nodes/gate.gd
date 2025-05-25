extends Node3D

@export var material:StandardMaterial3D = preload("res://assets/materials/silver.material")

func _ready():
	var mesh_one = get_node("Hinge/MeshInstance3D")
	mesh_one.set_surface_override_material(0, material)
	var mesh_two = get_node("Hinge/MeshInstance3D2")
	mesh_two.set_surface_override_material(0, material)
	var mesh_three = get_node("Hinge/MeshInstance3D3")
	mesh_three.set_surface_override_material(0, material)
	var mesh_four = get_node("Hinge/MeshInstance3D4")
	mesh_four.set_surface_override_material(0, material)
