extends Receiver
class_name scoreRemainingReplacement

var parent

signal trigger
signal untrigger

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent().get_node("MeshInstance3D").mesh
	super._ready()
	call_deferred( "_readier" )

func _readier():
	_run()

func _run():
	
	parent.text = str( total - triggered )

func handleTriggered():
	triggered += 1
	_run()
	if ( triggered >= total ):
		
		emit_signal("trigger")
		
func handleUntriggered():
	triggered -= 1
	_run()
	if ( triggered < total ):
		emit_signal("untrigger")
