extends Node
	
func _ready():
	call_deferred("_readier")

func _readier():
	global.allow_numbers = true
