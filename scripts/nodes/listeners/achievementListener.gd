extends Receiver

@export var achievement:String = ""

var ran = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

func handleTriggered():
	triggered += 1
	if ( triggered >= total && !ran):
		ran = true
		var key = achievement + "_ending"
		if ( unlocks.data[key] != "unlocked" ):
			unlocks.setData(key, "unlocked")
		global.achieve(achievement)

func handleUntriggered():
	triggered -= 1
