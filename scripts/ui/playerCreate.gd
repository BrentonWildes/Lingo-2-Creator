extends Node2D

func _ready():
	if ( global.using_keyboard ):
		get_node("Shader/CenterContainer/Grid/GridContainer/TextEdit").grab_focus()
