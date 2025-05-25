extends CanvasLayer
var menu
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = get_parent()
	menu = $menu
	get_node("menu/default/map_name").text = global.map.replace("_"," ")
	if ( global.is_demo || !global.reserved_scenes.has(global.map) || global.personal_scenes.values().has(global.map) ):
		get_node("menu/default/button_rte").hide()
		get_node("menu/default/button_rte_basic").show()
		get_node("menu/default/button_resume").focus_neighbor_bottom = get_node("menu/default/button_rte_basic").get_path()
		get_node("menu/default/button_resume").focus_next = get_node("menu/default/button_rte_basic").get_path()
		get_node("menu/default/button_settings").focus_neighbor_top = get_node("menu/default/button_rte_basic").get_path()
		get_node("menu/default/button_settings").focus_previous = get_node("menu/default/button_rte_basic").get_path()
	_unpause_game()
	
func _input(event):
	if event.is_action_pressed("escape"):
		if !get_tree().paused:
			_pause_game()
		elif !switcher.switching:
			_unpause_game()
			
func _pause_game():
	if (!player || switcher.switching):
		return
	player.solvingEnd()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu.show()
	if ( global.using_keyboard ):
		get_node("menu/default/button_resume").grab_focus()
	get_node("menu/return").hide()
	get_node("menu/settings").hide()
	get_node("menu/default").show()
	global.can_enter_solve = false
	
func _unpause_game():
	settings.mapKeys()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu.hide()
	
func _reload():
	if !player:
		return
	player.position = player.default_entry_point
	player.rotation = player.default_entry_rotation
	player.velocity = Vector3.ZERO
	player.flipped = false
	_unpause_game()

func _main_menu():
	autosplitter.reset()
	_unpause_game()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	musicPlayer.stop()
	if global.reserved_scenes.has(global.map):
		global.map = "demo"
	get_tree().change_scene_to_file("res://objects/scenes/menus/main_menu.tscn")

func _settings_open():
	if ( global.using_keyboard ):
		get_node("menu/settings/button_settings_close").grab_focus()
	settings.initSettingsMenu( "/root/scene/player/pause_menu/menu/settings/settingsInner/TabContainer" )
	get_node("menu/settings").show()
	get_node("menu/default").hide()

func _settings_close():
	if ( global.using_keyboard ):
		get_node("menu/default/button_settings").grab_focus()
	settings.storeSettings( "/root/scene/player/pause_menu/menu/settings/settingsInner/TabContainer" )
	get_node("menu/settings").hide()
	get_node("menu/default").show()
	
func _rte_open():
	if ( global.using_keyboard ):
		get_node("menu/return/rteInner/rte_the_entry").grab_focus()
	get_node("menu/return").show()
	get_node("menu/default").hide()
	
func _rte_close():
	if ( global.using_keyboard ):
		get_node("menu/default/button_rte").grab_focus()
	get_node("menu/return").hide()
	get_node("menu/default").show()

func _controls_open():
	if ( global.using_keyboard ):
		get_node("menu/controls/controls_close").grab_focus()
	get_node("menu/controls").show()
	get_node("menu/default").hide()

func _controls_close():
	if ( global.using_keyboard ):
		get_node("menu/default/button_settings").grab_focus()
	get_node("menu/controls").hide()
	get_node("menu/default").show()
