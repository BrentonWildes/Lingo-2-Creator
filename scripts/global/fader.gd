extends CanvasLayer

var path = "res://objects/scenes/the_entry.tscn"

var duration = 0.5
var rect
var timer

func _ready():
	rect = $rect
	timer = $timer
	timer.wait_time = duration
	timer.timeout.connect(_change_scene)

func _fade_start(scene_name):
	#if scene_name in global.scenes:
	#	path = global.scenes[scene_name]["path"]
		path = scene_name #replace with above eventually
		_fade_out()
		timer.start()
	#else:
	#	_reload_scene()
	

func _fade_in():
	var tween = create_tween()
	tween.tween_property(rect, "color", Color(0.0, 0.0, 0.0, 0.0), duration)
	tween.tween_callback( tweenInComplete )

func _fade_out():
	var tween = create_tween()
	tween.tween_property(rect, "color", Color(0.0, 0.0, 0.0, 1.0), duration)
	tween.tween_callback( tweenOutComplete )

func _reload_scene():
	path = get_tree().get_current_scene().get_filename()
	_fade_out()
	timer.start()

func _change_scene():
	global.loaded = false
	switcher.switch_map(path, true)

func tweenInComplete():
	pass

func tweenOutComplete():
	pass
