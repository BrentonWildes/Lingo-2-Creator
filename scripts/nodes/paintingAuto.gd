extends Receiver
class_name AutoPainting

@export var activate_on_sender_complete = false
@export var target_path:Node
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
	
	if all_senders.size() > 0:
		enabled = not activate_on_sender_complete
		if not enabled:
			var particles = get_node("Hinge/paintingColliders/TeleportParticles")
			if particles and not hide_particles:
				#already set to true above if hide_particles is false, so we only need to undo
				particles.emitting = false


func _looked_at(body, _painting):
	if not enabled:
		return
	if ( _painting.get_path() != get_node("Hinge/paintingColliders").get_path() ):
		return

	#this stops any ramps from finishing a transform
	if body.flipped:
		body.flipped = false

	var distance = self.to_local(body.global_transform.origin)
	body.global_transform.origin = target.to_global(distance)
	body.global_transform.basis = target.global_transform.basis * self.global_transform.basis.inverse() * body.global_transform.basis
	body.velocity = target.global_transform.basis * self.global_transform.basis.inverse() * body.velocity

	if !is_complete:
		is_complete = true
		emit_signal("trigger")
		
		is_complete = false

func handleTriggered():
	triggered += 1
	if ( triggered >= total):
		enabled = activate_on_sender_complete
		var particles = get_node("Hinge/paintingColliders/TeleportParticles")
		if enabled:
			if particles and not hide_particles:
				particles.emitting = true
		else:
			if particles:
				particles.emitting = false

func handleUntriggered():
	triggered -= 1
	if ( triggered < total ):
		enabled = not activate_on_sender_complete
		var particles = get_node("Hinge/paintingColliders/TeleportParticles")
		if enabled:
			if particles and not hide_particles:
				particles.emitting = true
		else:
			if particles:
				particles.emitting = false
