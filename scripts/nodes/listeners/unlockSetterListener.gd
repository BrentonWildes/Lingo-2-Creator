extends Receiver

@export var key:String = "color"
@export var value:String = ""

signal trigger
signal untrigger

func _ready():
	super._ready()
	
func handleTriggered():
	triggered += 1
	if ( triggered >= total ):
		if ( unlocks.data[key] != value ):
			unlocks.setData(key, value)
			emit_signal("trigger")
		
func handleUntriggered():
	triggered -= 1
	if ( triggered < total ):
		if ( unlocks.data[key] == value ):
			unlocks.setData(key, "")
			emit_signal("untrigger")
