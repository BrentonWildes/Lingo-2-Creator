extends Node

var left_of = {
	"t":"r", "r":"e", "e":"w", "w":"q", "q":"p", "p":"o", "o":"i", "i":"u", "u":"y","y":"t",
	"g":"f", "f":"d", "d":"s", "s":"a", "a":"l", "l":"k", "k":"j", "j":"h", "h":"g",
	"b":"v", "v":"c", "c":"x", "x":"z", "z":"m", "m":"n", "n":"b"
}

var right_of = {
	"q":"w", "w":"e", "e":"r", "r":"t", "t":"y", "y":"u", "u":"i", "i":"o", "o":"p", "p":"q", 
	"a":"s", "s":"d", "d":"f", "f":"g", "g":"h", "h":"j", "j":"k", "k":"l", "l":"a", 
	"z":"x", "x":"c", "c":"v", "v":"b", "b":"n", "n":"m", "m":"z"
}

var up_of = {
	"q":"z", "w":"x", "e":"c", "r":"v", "t":"b", "y":"n", "u":"m", "i":"k", "o":"l", "p":"p",
	"a":"q", "s":"w", "d":"e", "f":"r", "g":"t", "h":"y", "j":"u", "k":"i", "l":"o",
	"z":"a", "x":"s", "c":"d", "v":"f", "b":"g", "n":"h", "m":"j"
}

var down_of = {
	"q":"a", "w":"s", "e":"d", "r":"f", "t":"g", "y":"h", "u":"j", "i":"k", "o":"l", "p":"p",
	"a":"z", "s":"x", "d":"c", "f":"v", "g":"b", "h":"n", "j":"m", "k":"i", "l":"o",
	"z":"q", "x":"w", "c":"e", "v":"r", "b":"t", "n":"y", "m":"u"
}

func _ready():
	global.selected = "h"
	unlocks.unlocked_key.connect( unlock )
	var player = get_node("/root/scene/player")
	player.solve_start.connect( _update_key_status )
	player.solve_end.connect( _update_key_status )
	player.key_pressed.connect( _update_key_status )

func _update_key_status():
	for key in get_children():
		if "update_status" in key:
			key.update_status()

func unlock( key ):
	get_node( "key_" + key ).update_status()

func _input( event ):
	if (event.is_action_type()):
		if (global.solving):
			#check to break out of infinite while loop if no letters
			var has_letters = false
			for letter in global.letters_array:
				if unlocks.keys[letter] > 0:
					has_letters = true
					break
			if !has_letters:
				return
			#end of that check
			var key = global.selected
			if (event.is_action_pressed("ui_left") && !event.is_echo()):
				get_node("key_" + key).deselect()
				key = _try_left(key, key)
				global.selected = key
				get_node("key_" + key ).select()
			elif (event.is_action_pressed("ui_right") && !event.is_echo()):
				get_node("key_" + key).deselect()
				key = _try_right(key, key)
				global.selected = key
				get_node("key_" + key ).select()
			elif (event.is_action_pressed("ui_up") && !event.is_echo()):
				get_node("key_" + key).deselect()
				key = _try_up(key, key)
				global.selected = key
				get_node("key_" + key ).select()
			elif (event.is_action_pressed("ui_down") && !event.is_echo()):
				get_node("key_" + key).deselect()
				key = _try_down(key, key)
				global.selected = key
				get_node("key_" + key ).select()
			elif (event.is_action_pressed("push") && !event.is_echo()):
				get_node("/root/scene/player").press( key )

func _try_left( key, start_key ):
	key = left_of[key]
	
	if ( key == start_key ):
		return _try_left( down_of[key], down_of[start_key] )
	elif ( unlocks.keys[key] > 0 ):
		return key
	else:
		return _try_left( key, start_key )

func _try_right( key, start_key ):
	key = right_of[key]
	
	if ( key == start_key ):
		return _try_right( up_of[key], up_of[start_key] )
	elif ( unlocks.keys[key] > 0 ):
		return key
	else:
		return _try_right( key, start_key )

func _try_up( key, start_key ):
	key = up_of[key]
	
	if ( key == start_key ):
		return _try_up( right_of[key], right_of[start_key] )
	elif ( unlocks.keys[key] > 0 ):
		return key
	else:
		return _try_up( key, start_key )

func _try_down( key, start_key ):
	key = down_of[key]
	
	if ( key == start_key ):
		return _try_down( left_of[key], left_of[start_key] )
	elif ( unlocks.keys[key] > 0 ):
		return key
	else:
		return _try_down( key, start_key )
