extends Receiver

@export_enum("hide","show") var on_solve:String = "hide"

var ran = false

signal trigger
signal untrigger

func _ready():
	super._ready()
	if on_solve == "show":
		get_parent().hide()

func handleTriggered():
	triggered += 1
	if ( triggered >= total && !ran):
		if on_solve == "hide":
			get_parent().hide()
		elif on_solve == "show":
			get_parent().show()
		ran = true
		
func handleUntriggered():
	triggered -= 1
	if ( triggered < total && ran):
		if on_solve == "hide":
			get_parent().show()
		elif on_solve == "show":
			get_parent().hide()
		ran = false
