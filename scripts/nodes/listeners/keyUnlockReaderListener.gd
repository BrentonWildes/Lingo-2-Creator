extends Receiver

@export var key:String = "h"
@export var level:int = 1

signal trigger
signal untrigger

func _ready():
	super._ready()
	call_deferred("_readier")

func _readier():
	if unlocks.keys.has(key):
		if ( unlocks.keys[key] >= level ):
			emit_signal("trigger")
	
func handleTriggered():
	triggered += 1
	if ( triggered >= total ):
		if ( unlocks.keys[key] >= level ):
			emit_signal("trigger")
		
func handleUntriggered():
	triggered -= 1
	if ( triggered < total ):
		if ( unlocks.keys[key] < level ):
			emit_signal("untrigger")
