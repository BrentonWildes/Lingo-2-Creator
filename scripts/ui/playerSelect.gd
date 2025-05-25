extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	if ( global.using_keyboard ):
		get_node("Shader/return").grab_focus()
	var button
	var theme = load( "res://assets/themes/baseUI.tres" )
	var script = load( "res://scripts/ui/buttons.gd" )
	var container = get_node( "Shader/ScrollContainer/VBoxContainer" )
	var path = "user://users/"
	var directory = global.directoryFindOrNew( path )
	directory.list_dir_begin()
	var file_name = directory.get_next()
	while file_name != "":
		if file_name == "steam_autocloud.vdf":
			file_name = directory.get_next()
			continue
		if directory.current_is_dir():
			button = Button.new()
			if file_name == global.user:
				button.disabled = true
			button.set_script(script)
			button.text = file_name
			button.username = file_name
			button.pressed.connect(_player_selected.bind(button))
			button.theme = theme
			container.add_child(button)
			file_name = directory.get_next()
	button = Button.new()
	#button.set_script(script)
	button.text = "Create New"
	button.pressed.connect(_create_player.bind(button))
	button.theme = theme
	container.add_child(button)
	
	autosplitter.reset()

func _player_selected( button ):
	global.user = button.username
	global.map = "demo"
	settings.loadSettings()
	settings.applySettings()
	settings.saveSettings()
	get_tree().change_scene_to_file.bind("res://objects/scenes/menus/main_menu.tscn").call_deferred()

func _create_player( _button ):
	get_tree().change_scene_to_file.bind("res://objects/scenes/menus/player_create.tscn").call_deferred()
