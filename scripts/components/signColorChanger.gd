extends Receiver
class_name signColorChanger 

func _ready():
	super._ready()
	call_deferred( "_update" )

func _update():
	var mesh = get_parent().get_node("MeshInstance3D").mesh
	var color = unlocks.data["color"]
	mesh.text = color
	if ( color != "" ):
		mesh.material = load("res://assets/materials/" + color + ".material")
		get_parent().show()
	else:
		mesh.material = load("res://assets/materials/black.material")
		get_parent().hide()
	
func handleTriggered():
	call_deferred("_update")
	
func handleUntriggered():
	call_deferred("_update")
