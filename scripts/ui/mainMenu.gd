extends Node2D

func _ready():
	# Editor specific - load scenes from custom to maps automatically
	var dir_source = global.directoryFindOrNew("res://objects/scenes/custom")
	var _dir_dest = global.directoryFindOrNew("user://maps")
	if dir_source:
		dir_source.list_dir_begin()
		var file_name = dir_source.get_next()
		while file_name != "":
			if dir_source.current_is_dir():
				print("Skipping directory: " + file_name)
			else:
				DirAccess.copy_absolute( "res://objects/scenes/custom/" + file_name, "user://maps/" + file_name )
			file_name = dir_source.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	
	global.findScenes()
	
	switcher.preload_map(global.scenes[global.map].path)
	
	if global.is_demo:
		get_node("title2").text = "the demo"
		get_node("title2").show()
		get_node("level_select").queue_free()
		get_node("settings").position.y = 700
		get_node("quit").position.y = 800
	else:
		if (global.map != "the_entry"):
			get_node("title2").text = global.map.replace("_", " ")
			get_node("title2").show()
		if global.scenes.size() < 2:
			get_node("player_select").focus_neighbor_bottom = get_node("settings").get_path()
			get_node("settings").focus_neighbor_top = get_node("player_select").get_path()
			get_node("player_select").focus_next = get_node("settings").get_path()
			get_node("settings").focus_previous = get_node("player_select").get_path()
			get_node("level_select").queue_free()
			get_node("settings").position.y = 700
			get_node("quit").position.y = 800
	
	if ( global.using_keyboard ):
		get_node("new_game").grab_focus()
		#get_node("discord").queue_free()
	
