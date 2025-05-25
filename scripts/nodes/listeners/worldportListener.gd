extends Receiver

# Be careful when using this class with panels, or other saved signalers
# If your triggerers here are saved, then you may trigger this on load

@export var exit:String
@export var entry_point:Vector3 = Vector3(0,0,0)
@export var entry_rotate:Vector3 = Vector3(0,0,0)
@export var sets_entry_point:bool = true

func _ready():
	super._ready()
	
	switcher.preload_map( "res://objects/scenes/" + exit + ".tscn" )

func handleTriggered():
	triggered += 1
	if ( triggered >= total ):
		global.solving = false
		global.map = exit
		global.entry_point = entry_point
		global.entry_rotate = entry_rotate
		global.entry_pivot = Vector3(0,0,0)
		global.entry_player_rotate = Vector3(0,0,0)
		global.sets_entry_point = sets_entry_point
		global.entry_velocity = Vector3(0,0,0) 
		call_deferred( "changeScene" )
		
func handleUntriggered():
	triggered -= 1
	
func changeScene():
	switcher.switch_map( "res://objects/scenes/" + exit + ".tscn" )
