extends Node3D

signal trigger
signal untrigger

func _ready():
	get_node("Area3D").body_entered.connect(onBodyEntered)
	get_node("Area3D").body_exited.connect(onBodyExited)
	get_node("MeshInstance3D").queue_free()

func onBodyEntered(body):
	if body.is_in_group("player"):
		emit_signal("trigger")

func onBodyExited(body):
	if body.is_in_group("player"):
		emit_signal("untrigger")
