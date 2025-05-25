extends Receiver

var ran = false
var current_item = 0

signal trigger
signal untrigger

func _ready():
	super._ready()

func handleTriggered():
	if ( get_node( all_senders[current_item] ).is_complete ):
		current_item += 1
	else:
		current_item = 0
	triggered += 1
	if ( triggered >= total && !ran ):
		if ( current_item == all_senders.size() ):
			emit_signal("trigger")
			ran = true
		
func handleUntriggered():
	current_item = 0
	triggered -= 1
	if ( triggered < total && ran ):
		emit_signal("untrigger")
		ran = false
