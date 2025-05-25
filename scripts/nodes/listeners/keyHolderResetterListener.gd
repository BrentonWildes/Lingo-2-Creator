extends Receiver

var path

signal trigger
signal untrigger

func _ready():
	super._ready()

func reset():
	var matches = unlocks.unlockAllKeyholders()
	if matches.size() > 0:
		sfxPlayer.sfx_play("pickup")
	
func handleTriggered():
	triggered += 1
	if ( triggered >= total ):
		reset()
		
func handleUntriggered():
	triggered -= 1
