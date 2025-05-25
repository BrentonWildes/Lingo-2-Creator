extends Receiver

var ran = false

signal trigger
signal untrigger

func _ready():
	super._ready()

func handleTriggered():
	triggered += 1
	if ( triggered >= total && !ran ):
		emit_signal("trigger")
		ran = true
		
func handleUntriggered():
	triggered -= 1
	if ( triggered < total && ran ):
		emit_signal("untrigger")
		ran = false
