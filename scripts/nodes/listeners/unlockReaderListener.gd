extends Receiver

@export var key:String = "color"
@export var value:String = ""

signal trigger
signal untrigger

func _ready():
	super._ready()
	call_deferred("_readier")

func _readier():
	if unlocks.data.has(key):
		if ( unlocks.data[key] == value ):
			emit_signal("trigger")
	
func handleTriggered():
	triggered += 1
	if ( triggered >= total ):
		if ( unlocks.data[key] == value ):
			emit_signal("trigger")
		
func handleUntriggered():
	triggered -= 1
	if ( triggered < total ):
		if ( unlocks.data[key] != value ):
			emit_signal("untrigger")
