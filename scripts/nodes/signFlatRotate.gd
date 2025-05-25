extends Node3D
class_name SignFlatRotate

@export_multiline var front:String = "front"
@export_multiline var back:String = "back"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Label3D").text = front
	get_node("Label3D2").text = back
	$AnimationPlayer.play("spin")
