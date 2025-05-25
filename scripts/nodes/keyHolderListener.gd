extends Receiver

@export var answer:String = "-"

var unlocked = false

signal trigger
signal untrigger

func handleTriggered():
	var holder = get_node(senders[0])
	if !unlocked && holder.held_key == answer:
		unlocked = true
		emit_signal("trigger")
	elif unlocked:
		unlocked = false
		emit_signal("untrigger")
		
func handleUntriggered():
	if unlocked:
		unlocked = false
		emit_signal("untrigger")
