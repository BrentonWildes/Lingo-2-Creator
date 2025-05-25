extends Node2D

func _ready():
	global.map = "the_entry"
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# The credits screen is an edge case when it comes to map switching, and we need to turn off the
	# loading flag manually since there's no player node.
	autosplitter.setLoadingFlag(false)
