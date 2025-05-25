extends Receiver

@export var on_solve:Environment = load("res://assets/environments/default.tres")
@export var on_unsolve:Environment = load("res://assets/environments/default.tres")

var ran = false

signal trigger
signal untrigger

func _ready():
	super._ready()

func handleTriggered():
	triggered += 1
	if ( triggered >= total && !ran):
		get_node("/root/scene/WorldEnvironment").set_environment(on_solve)
		ran = true
		
func handleUntriggered():
	triggered -= 1
	if ( triggered < total && ran):
		get_node("/root/scene/WorldEnvironment").set_environment(on_unsolve)
		ran = false
