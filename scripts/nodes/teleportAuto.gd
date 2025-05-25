extends Receiver
class_name TeleportAuto

@export var target:Node
@export_enum ( "ignore", "key_pressed", "key_unpressed" ) var teleport_with_press: String = "ignore"
@export var key:String = ""

@export var require_positive_x:bool = false
@export var require_positive_z:bool = false
@export var require_negative_x:bool = false
@export var require_negative_z:bool = false

var enabled = true
var do_warp = true
var trigger_ran = false

signal trigger
signal untrigger

func _ready():
	get_node("MeshInstance3D").queue_free()
	get_node("MeshInstance3D2").queue_free()
	get_node("MeshInstance3D3").queue_free()
	super._ready()
	self.body_entered.connect(bodyEntered)

func bodyEntered(body):
	if body.is_in_group("player"):
		if not enabled:
			return
		
		#requirements checking
		do_warp = true
		
		#direction checking
		if ( require_positive_z && body.get_transform().basis.x.x > 0):
			do_warp = false
		if ( require_negative_z && body.get_transform().basis.x.x < 0):
			do_warp = false
		if ( require_positive_x && body.get_transform().basis.x.z < 0):
			do_warp = false
		if ( require_negative_x && body.get_transform().basis.x.z > 0):
			do_warp = false
		
		#keypress checking
		if ( teleport_with_press == "key_pressed" && !Input.is_action_pressed( key ) ):
			do_warp = false
		if ( teleport_with_press == "key_unpressed" && Input.is_action_pressed( key ) ):
			do_warp = false
		
		#requirements checking return
		if !do_warp:
			return
		
		var origbasis = self.global_transform.basis
		var newbasis = target.global_transform.basis
		
		var direction = Basis.looking_at(self.global_position-body.global_position, self.global_transform.basis.y)
		var distance = body.global_position.distance_to(self.global_position)
		
		body.velocity =  newbasis.orthonormalized()*origbasis.inverse().orthonormalized() * body.velocity
		direction =  newbasis.orthonormalized()*origbasis.inverse().orthonormalized() * direction 
		body.global_transform.basis =  newbasis.orthonormalized()* origbasis.inverse().orthonormalized() * body.global_transform.basis 

		body.global_position = target.global_position + (distance*direction.z)
		
		if !trigger_ran:
			trigger_ran = true
			emit_signal("trigger")
		else:
			trigger_ran = false
			emit_signal("untrigger")
			
func handleTriggered():
	triggered += 1
	if ( triggered >= total):
		enabled = false

func handleUntriggered():
	triggered -= 1
	if ( triggered < total ):
		enabled = true
