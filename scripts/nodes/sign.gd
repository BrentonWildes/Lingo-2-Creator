extends Node3D
class_name Sign

@export var material:Material = preload("res://assets/materials/purple.material")
@export var font_size:int = 96
@export var text:String = "hi"

# Called when the node enters the scene tree for the first time.
func _ready():
	var mesh = get_node("MeshInstance3D").mesh
	mesh.text = text
	mesh.material = material
	mesh.font_size = font_size
