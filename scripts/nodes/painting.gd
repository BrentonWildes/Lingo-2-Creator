extends Receiver
class_name Painting

enum rotations{None = 0, Left = 90, Behind = 180, Right = 270}
@export var rotate_player:rotations = rotations.None
@export var target_path:Node
@export var change_vertical:bool = false
enum directions{X, Y, Z}
@export var axis_of_rotation:directions = directions.X
@export var vertical_rotation:float = 180
@export var hide_particles:bool = false

var actual_axis:Vector3

var target
var enabled = true
var is_complete = false

signal trigger
signal untrigger

func _ready():
	super._ready()
	if target_path != null:
		target = target_path.get_node("Hinge/paintingColliders/AreaExit")
		get_node("/root/scene/player").looked_at.connect(_looked_at)
		var particles = get_node("Hinge/paintingColliders/TeleportParticles")
		if particles and not hide_particles:
			particles.emitting = true

func _looked_at(body, _painting):
	if not enabled:
		return
	if ( _painting.get_path() != get_node("Hinge/paintingColliders").get_path() ):
		return

	if axis_of_rotation == directions.X:
		actual_axis = Vector3(1,0,0)
	if axis_of_rotation == directions.Y:
		actual_axis = Vector3(0,1,0)
	if axis_of_rotation == directions.Z:
		actual_axis = Vector3(0,0,1)

	var distance = body.global_position.distance_to(self.global_position)
	var direction = self.global_position.direction_to(body.global_position)
	var rotateme = deg_to_rad(float(rotate_player))
	body.velocity = body.velocity.rotated(body.transform.basis.y, rotateme)
	direction = direction.rotated(body.transform.basis.y, rotateme)
	body.transform.basis = body.transform.basis.rotated(body.transform.basis.y, rotateme)
	if change_vertical:
		body.transform.basis = body.transform.basis.rotated(actual_axis, deg_to_rad(vertical_rotation))
		direction = direction.rotated(actual_axis, deg_to_rad(vertical_rotation))
		body.velocity = body.velocity.rotated(actual_axis, deg_to_rad(vertical_rotation))
	body.global_position = target.global_position + (direction * distance)

	if !is_complete:
		is_complete = true
		emit_signal("trigger")
		
		is_complete = false

func handleTriggered():
	triggered += 1
	if ( triggered >= total):
		enabled = false

func handleUntriggered():
	triggered -= 1
	if ( triggered < total ):
		enabled = true
