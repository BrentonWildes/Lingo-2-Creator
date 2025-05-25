extends Receiver
class_name signMasteryLookup

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
func updateSign():
	var mesh = get_parent().get_node("MeshInstance3D").mesh
	mesh.text = str(triggered)
	
func handleTriggered():
	triggered += 1
	updateSign()
	
func handleUntriggered():
	triggered -= 1
	updateSign()
