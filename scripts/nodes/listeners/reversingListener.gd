extends Receiver

var ran = false

signal trigger
signal untrigger

func _ready():
	super._ready()
	ran = true
	call_deferred("_readier")

func _readier():
	if triggered < total:
		emit_signal("trigger")
		ran = false

func handleTriggered():
	triggered += 1
	if ( triggered >= total && !ran):
		emit_signal("untrigger")
		ran = true
		
func handleUntriggered():
	triggered -= 1
	if ( triggered < total && ran):
		emit_signal("trigger")
		ran = false
