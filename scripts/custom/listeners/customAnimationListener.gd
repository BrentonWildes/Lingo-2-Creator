extends Receiver

@export var animationName = ""

var ran = false

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(get_parent() is AnimationPlayer, "custom animation listener at: " + str(get_path()) + " is not a child of an animation player")
	super._ready()

func handleTriggered():
	triggered += 1
	if ( triggered >= total && !ran):
		ran = true
		get_parent().play(animationName)



func handleUntriggered():
	triggered -= 1
	if ( triggered < total && ran ):
		ran = false
		get_parent().pause()
