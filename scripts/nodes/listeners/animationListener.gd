extends Receiver

@export var remove_on_complete:bool = false
@export var animate_distance_x:float = 0
@export var animate_distance_y:float = -5.0
@export var animate_distance_z:float = 0
@export var rotate_x:float = 0
@export var rotate_y:float = 0
@export var rotate_z:float = 0

var ran = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

func handleTriggered():
	triggered += 1
	if ( triggered >= total && !ran):
		ran = true
		animate(animate_distance_x, animate_distance_y, animate_distance_z, rotate_x, rotate_y, rotate_z)

func handleUntriggered():
	triggered -= 1
	if ( triggered < total && ran ):
		ran = false
		animate(0,0,0,0,0,0)

func animate(x, y, z, rx, ry, rz):
	var tween = create_tween()
	var hinge = get_parent().get_node("Hinge")
	
	tween.tween_property(hinge, "position:x", x, 1)
	tween.parallel().tween_property(hinge, "position:y", y, 1)
	tween.parallel().tween_property(hinge, "position:z", z, 1)
	tween.parallel().tween_property(hinge, "rotation:x", deg_to_rad(rx), 1)
	tween.parallel().tween_property(hinge, "rotation:y", deg_to_rad(ry), 1)
	tween.parallel().tween_property(hinge, "rotation:z", deg_to_rad(rz), 1)
	tween.tween_callback(animationComplete)
	
func animationComplete():
	if (remove_on_complete):
		self.queue_free()
