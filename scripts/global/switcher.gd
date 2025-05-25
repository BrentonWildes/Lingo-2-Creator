extends CanvasLayer


var loaded_map_files: Dictionary
var load_indicator: Node
var switching: bool
var current_map_name: String


func _ready():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	loaded_map_files = {}
	switching = false
	current_map_name = ""
	
	load_indicator = preload("res://objects/nodes/load_indicator.tscn").instantiate()
	load_indicator.visible = false
	add_child(load_indicator)


func preload_map(path):
	if !loaded_map_files.has(path):
		if (FileAccess.file_exists(path)):
			ResourceLoader.load_threaded_request(path)


func switch_map(path, fade_in = false):
	preload_map(path)
	
	switching = true
	autosplitter.setLoadingFlag(true)
	load_indicator.visible = true
	get_tree().paused = true
	
	# This is needed in order to get the game to render the loading indicator. For whatever reason,
	# one frame is not enough.
	await get_tree().process_frame
	await get_tree().process_frame
	
	_do_switch.call_deferred(path, fade_in)


func _do_switch(path, fade_in):
	global.loaded = false
	var scene
	if loaded_map_files.has(path):
		scene = loaded_map_files.get(path)
	else:
		scene = ResourceLoader.load_threaded_get(path)
		loaded_map_files[path] = scene
	
	get_tree().change_scene_to_packed(scene)
	
	get_tree().paused = false
	load_indicator.visible = false
	# We don't unset the autosplitter loading flag until the player can move
	switching = false
	
	current_map_name = path.get_file().get_basename()
	autosplitter.setCurrentMap(current_map_name)
	
	if fade_in:
		fader._fade_in()
