extends Receiver

@export var replace_with:NodePath

func _ready():
	updateText()

func handleTriggered():
	triggered += 1
	if ( triggered == total ):
		self.global_translate(Vector3(0,-10000,0))
	updateText()
	
func handleUntriggered():
	if ( triggered == total ):
		self.global_translate(Vector3(0,10000,0))
	triggered -= 1
	updateText()
	
func updateText():
	get_node("Viewport/GUI/Panel/Label").text = (total - triggered) as String
	self.get_node("Viewport").render_target_update_mode = 1
