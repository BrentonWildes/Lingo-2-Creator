extends Node3D

@export var material:StandardMaterial3D = preload("res://assets/materials/pedestal.material")

func _ready():
	var mesh = get_node("Hinge/MeshInstance3D")
	mesh.set_surface_override_material(0, material)
	var mesh_bottom = get_node("Hinge/MeshInstance3D2")
	mesh_bottom.set_surface_override_material(0, material)
