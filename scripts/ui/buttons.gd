extends Button

var username:String = "notnerb"
var has_run = false

func _pressed():
	if (name == "new_game"):
		get_parent().get_node("discord").queue_free()
		if (global.is_demo):
			global.map = "demo"
		unlocks.resetKeys()
		unlocks.resetCollectables()
		unlocks.resetData()
		unlocks.loadKeys()
		unlocks.loadCollectables()
		unlocks.loadData()
		unlocks.unlockKey("capslock", 1) #lol this is so dumb, all the files are bad
		global.sets_entry_point = false
		
		if unlocks.data["double_letters"] == "unlocked":
			for scene in global.personal_scenes:
				if (global.user.to_lower() == scene):
					global.map = global.personal_scenes[scene]
					switcher.switch_map("res://objects/scenes/" + global.personal_scenes[scene] + ".tscn")
					return
		if global.reserved_scenes.has(global.map):
			switcher.switch_map("res://objects/scenes/" + global.map + ".tscn")
		else:
			global.universe = global.map
			switcher.switch_map("user://maps/" + global.map + ".tscn")
	
	if (name == "player_select"):
		get_tree().change_scene_to_file.bind("res://objects/scenes/menus/player_select.tscn").call_deferred()
	
	if (name == "level_select"):
		get_tree().change_scene_to_file.bind("res://objects/scenes/menus/level_select.tscn").call_deferred()
		
	if (name == "settings"):
		get_tree().change_scene_to_file.bind("res://objects/scenes/menus/settings.tscn").call_deferred()
	
	if (name == "settings_return"):
		settings.storeSettings( "/root/settingsMenu/Shader/settingsInner/TabContainer" )
		get_tree().change_scene_to_file.bind("res://objects/scenes/menus/main_menu.tscn").call_deferred()
		
	if (name == "return"):
		get_tree().change_scene_to_file.bind("res://objects/scenes/menus/main_menu.tscn").call_deferred()

	#for inexplicable reasons this triggers twice
	if (name == "discord"):
		if !has_run:
			has_run = true
			var _discard = OS.shell_open("https://discord.gg/DG48y2Msky")
		else:
			has_run = false
	
	if (name == "controls"):
		get_tree().change_scene_to_file.bind("res://objects/scenes/menus/controls.tscn").call_deferred()
	
	if (name == "view_game_data"):
		var _discard = OS.shell_open( OS.get_user_data_dir() )
		
	if (name == "create_player"):
		var player = get_parent().get_node("Shader/CenterContainer/Grid/GridContainer/TextEdit").text
		if player == "" || !player.is_valid_filename():
			get_parent().get_node("Shader/CenterContainer/Grid/error").show()
			return
		var path = "user://users/" + player
		var _directory = global.directoryFindOrNew( path )
		global.user = player
		get_tree().change_scene_to_file.bind("res://objects/scenes/menus/main_menu.tscn").call_deferred()

	if (name == "quit"):
		get_tree().quit()
