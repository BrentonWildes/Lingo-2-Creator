extends Control

var keys = [ "rte_the_entry", "rte_the_gallery", "rte_control_center", "rte_daedalus", "rte_the_plaza" ]

func _ready():
	for button in get_children():
		button.pressed.connect( _buttonPressed.bind(button) )
	call_deferred("_readier")

func _readier():
	for key in keys:
		if unlocks.data.has(key) && unlocks.data[key] == "unlocked":
			get_node(key).show()
	setUI()

func _buttonPressed(button):
	var new_map = button.name.replace("rte_","")
	if (new_map == global.map):
		get_node("/root/scene/player/pause_menu")._reload()
	else:
		global.map = new_map
		_changeMap()
	
func _changeMap():
	switcher.switch_map("res://objects/scenes/" + global.map + ".tscn")

func setUI():
	switcher.preload_map("res://objects/scenes/the_entry.tscn")
	if ( unlocks.data["rte_the_gallery"] == "unlocked" ):
		get_node("rte_the_entry").focus_neighbor_left = get_node("rte_the_gallery").get_path()
		switcher.preload_map("res://objects/scenes/the_gallery.tscn")
	if ( unlocks.data["rte_the_plaza"] == "unlocked" ):
		get_node("rte_the_entry").focus_neighbor_top = get_node("rte_the_plaza").get_path()
		switcher.preload_map("res://objects/scenes/the_plaza.tscn")
	if ( unlocks.data["rte_daedalus"] == "unlocked" ):
		get_node("rte_the_entry").focus_neighbor_right = get_node("rte_daedalus").get_path()
		switcher.preload_map("res://objects/scenes/daedalus.tscn")
	if ( unlocks.data["rte_control_center"] == "unlocked" ):
		get_node("rte_the_entry").focus_neighbor_bottom = get_node("rte_control_center").get_path()
		get_node("rte_control_center").focus_neighbor_bottom = get_node("/root/scene/player/pause_menu/menu/return/rte_close").get_path()
		get_node("/root/scene/player/pause_menu/menu/return/rte_close").focus_neighbor_top = get_node("rte_control_center").get_path()
		switcher.preload_map("res://objects/scenes/control_center.tscn")
	else:
		get_node("rte_the_entry").focus_neighbor_bottom = get_node("/root/scene/player/pause_menu/menu/return/rte_close").get_path()
		get_node("/root/scene/player/pause_menu/menu/return/rte_close").focus_neighbor_top = get_node("rte_the_entry").get_path()
