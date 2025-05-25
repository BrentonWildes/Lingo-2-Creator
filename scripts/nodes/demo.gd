extends Node

func _init():
	global.name = "demo"
	
func _ready():
	call_deferred("_deferredReady")
	
func _deferredReady():
	for key in ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]:
		unlocks.unlockKey( key, 2 )
