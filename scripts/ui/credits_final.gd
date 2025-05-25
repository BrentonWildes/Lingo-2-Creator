extends Node2D

var tween
var autoscroll_speed = 65

func _ready():
	global.map = "the_entry"
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# The credits screen is an edge case when it comes to map switching, and we need to turn off the
	# loading flag manually since there's no player node.
	autosplitter.setLoadingFlag(false)
	call_deferred("_readier")

func _readier():
	var scrollbar = get_node("Shader/CenterContainer2/ScrollContainer")
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(scrollbar, "scroll_vertical", scrollbar.get_v_scroll_bar().max_value, autoscroll_speed)
