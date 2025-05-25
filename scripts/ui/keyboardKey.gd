extends Node

@export var key = "a"
signal pushed()

var player

func _ready():
	get_node("key").text = key
	player = get_node("/root/scene/player")
	update_status()

func update_status():
	if ( unlocks.keys[key] == 0 ):
		get_node("background_0").show()
		get_node("background_1").hide()
		get_node("background_2").hide()
		get_node("key").hide()
	elif ( unlocks.keys[key] == 1 ):
		get_node("background_0").hide()
		get_node("background_1").show()
		get_node("background_2").hide()
		get_node("key").show()
		if (_is_used()):
			get_node("key").modulate.a = 0.5
		else:
			get_node("key").modulate.a = 1.0
	elif ( unlocks.keys[key] == 2 ):
		get_node("background_0").hide()
		get_node("background_1").hide()
		get_node("background_2").show()
		get_node("key").show()
		get_node("key").modulate.a = 1.0
	#if !global.solving:
	#	deselect()

func select():
	get_node("selected").show()
	
func deselect():
	get_node("selected").hide()

func push():
	pushed.emit( key )

func _is_used():
	if not global.solving:
		return false
	var active_panel = player.panel
	if not active_panel:
		return false
	if "has_focus" not in active_panel or not active_panel.has_focus:
		return false
	return "hasKey" in active_panel and active_panel.hasKey( key )
