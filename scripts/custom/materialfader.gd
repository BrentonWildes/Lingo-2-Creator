extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for mesh in get_children():
		var modified_material = mesh.get_surface_override_material(0).duplicate()
		modified_material.transparency = 1
		modified_material.distance_fade_mode = 3
		modified_material.distance_fade_min_distance = 20
		modified_material.distance_fade_max_distance = 60
		mesh.set_surface_override_material(0,modified_material)
