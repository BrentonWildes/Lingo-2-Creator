extends Receiver

var solved = 0
@onready var label = get_node("Viewport/GUI/Panel/Label")

func _ready():
	pass

func handleTriggered():
	solved += 1
	label.text = str( solved )
	$Viewport.render_target_update_mode = 1
	
func handleUntriggered():
	solved -= 1
	label.text = str( solved )
	$Viewport.render_target_update_mode = 1
