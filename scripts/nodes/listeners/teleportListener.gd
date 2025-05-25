extends Receiver

# Be careful when using this class with panels, or other saved signalers
# If your triggerers here are saved, then you will/may trigger this on load

@export var teleport_point:Vector3 = Vector3(0,0,0)
@export var teleport_rotate:Vector3 = Vector3(0,0,0)
@export var sets_entry_point:bool = false
@export var return_on_untrigger:bool = true
@export var target_path:Node = null

var ran = false
var unsolve_return_point:Vector3 = Vector3(0,1000,0)
var unsolve_return_rotate:Vector3 = Vector3(0,0,0)

func _ready():
	super._ready()
	if target_path == null:
		target_path = get_parent()

func handleTriggered():
	triggered += 1
	if ( triggered >= total && !ran ):
		if sets_entry_point:
			global.entry_point = teleport_point
			global.entry_rotate = teleport_rotate
		unsolve_return_point = target_path.position
		unsolve_return_rotate = Vector3( target_path.rotation.x, target_path.rotation.y, target_path.rotation.z )
		target_path.position = teleport_point
		target_path.rotation.x = deg_to_rad(teleport_rotate.x)
		target_path.rotation.y = deg_to_rad(teleport_rotate.y)
		target_path.rotation.z = deg_to_rad(teleport_rotate.z)
		ran = true
		
func handleUntriggered():
	triggered -= 1
	if ( triggered < total && ran ):
		if ( return_on_untrigger ):
			target_path.position = unsolve_return_point
			target_path.rotation.x = unsolve_return_rotate.x
			target_path.rotation.y = unsolve_return_rotate.y
			target_path.rotation.z = unsolve_return_rotate.z
		ran = false
