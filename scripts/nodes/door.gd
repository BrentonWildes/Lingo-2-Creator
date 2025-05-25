extends Receiver

@export var remove_on_complete:bool = false
@export var material_override:Material = load("res://assets/materials/blackMatte.material")
@export var animate_distance_x:float = 0
@export var animate_distance_y:float = -5.0
@export var animate_distance_z:float = 0
@export var rotation_x:float = 0
@export var rotation_y:float = 0
@export var rotation_z:float = 0
@export var incremental:bool = false

var ran = false
var tween

func _ready():
	super._ready()
	
	if get_node_or_null("Hinge/MeshInstance3D") != null:
		var mesh = self.get_node("Hinge/MeshInstance3D")
		mesh.set_surface_override_material(0, material_override)

func handleTriggered():
	triggered += 1
	if (!ran):
		if ( triggered >= total ):
			ran = true
			animate(animate_distance_x, animate_distance_y, animate_distance_z, rotation_x, rotation_y, rotation_z)
		elif ( incremental ):
			var ratio = float(triggered) / float(total)
			animate(animate_distance_x * ratio, animate_distance_y * ratio, animate_distance_z * ratio, rotation_x * ratio, rotation_y * ratio, rotation_z * ratio)

func handleUntriggered():
	triggered -= 1
	if ( triggered < total && ran ):
		ran = false
		animate(0,0,0,0,0,0)
	if ( !ran && incremental ):
		var ratio = float(triggered) / float(total)
		animate(animate_distance_x * ratio, animate_distance_y * ratio, animate_distance_z * ratio, rotation_x * ratio, rotation_y * ratio, rotation_z * ratio)

func animate(x, y, z, rx, ry, rz):
	if tween:
		tween.kill()
	tween = create_tween()
	var hinge = get_node("Hinge")
	
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
