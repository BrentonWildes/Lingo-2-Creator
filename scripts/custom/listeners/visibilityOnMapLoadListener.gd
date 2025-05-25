extends Receiver

@export_enum("hide","show") var on_solve:String = "hide"

var ran = false
var loaded = false

signal trigger
signal untrigger

func _ready():
	super._ready()
	if on_solve == "show":
		get_parent().hide()
	await get_node("/root/scene/player").level_loaded
	await get_tree().process_frame
	await get_tree().process_frame
	loaded = true

func handleTriggered():
	if loaded:
		return
	
	triggered += 1
	if ( triggered >= total && !ran):
		if on_solve == "hide":
			get_parent().hide()
		elif on_solve == "show":
			get_parent().show()
		ran = true
		
func handleUntriggered():
	if loaded:
		return
	triggered -= 1
	if ( triggered < total && ran):
		if on_solve == "hide":
			get_parent().show()
		elif on_solve == "show":
			get_parent().hide()
		ran = false
