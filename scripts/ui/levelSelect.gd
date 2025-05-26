extends Node

func _ready():
	var button
	var theme = load( "res://assets/themes/baseUI.tres" )
	var script = load( "res://scripts/ui/buttons.gd" )
	var container = get_node( "Shader/ScrollContainer/VBoxContainer" )
	global.findScenes()
	var scenes = global.scenes
	for scene in scenes:
		if scene.ends_with("_"):
			continue
		button = Button.new()
		if scene == global.map:
			button.disabled = true
		button.set_script(script)
		button.text = scenes[scene]["title"]
		button.pressed.connect(_scene_selected.bind(button, scenes[scene]["name"]))
		button.theme = theme
		container.add_child(button)

func _scene_selected(_button, scene_name):
	global.map = scene_name
	get_tree().change_scene_to_file.bind("res://objects/scenes/menus/main_menu.tscn").call_deferred()
