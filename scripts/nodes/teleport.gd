extends Receiver
class_name Teleport

@export var exit:NodePath
@export_enum ( "0", "90", "180", "270" ) var rotate_degrees: String = "0"
@export_enum ( "ignore", "key_pressed", "key_unpressed" ) var teleport_with_press: String = "ignore"
@export var key:String = ""

@export var require_positive_x:bool = false
@export var require_positive_z:bool = false
@export var require_negative_x:bool = false
@export var require_negative_z:bool = false

@export var flip_vertical:bool = false

signal trigger
signal untrigger

var enabled = true
var do_warp = true
var trigger_ran = false

func _ready():
	get_node("MeshInstance3D").queue_free()
	get_node("MeshInstance3D2").queue_free()
	get_node("MeshInstance3D3").queue_free()
	super._ready()
	self.body_entered.connect(bodyEntered)

func bodyEntered(body):
	if body.is_in_group("player"):
		#disabled by solves
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
		
		var target = get_node(exit)

		if ( rotate_degrees == "0" ):
			var diff_x = body.global_position.x - self.global_position.x
			var diff_y = body.global_position.y - self.global_position.y
			var diff_z = body.global_position.z - self.global_position.z
			body.global_position.x = target.global_position.x + diff_x * body.scale.y
			body.global_position.y = target.global_position.y + diff_y
			body.global_position.z = target.global_position.z + diff_z * body.scale.y
			if (body.flipped):
				body.velocity = body.velocity.rotated(Vector3(0,1,0), PI)
		
		if ( rotate_degrees == "180" ):
			var diff_x = body.global_position.x - self.global_position.x
			var diff_y = body.global_position.y - self.global_position.y
			var diff_z = body.global_position.z - self.global_position.z
			body.global_position.x = target.global_position.x - diff_x * body.scale.y
			body.global_position.y = target.global_position.y + diff_y
			body.global_position.z = target.global_position.z - diff_z * body.scale.y
			body.rotate_y(PI)
			if (!body.flipped):
				body.velocity = body.velocity.rotated(Vector3(0,1,0), PI)
		
		if ( rotate_degrees == "90"):
			var diff_x = body.global_position.x - self.global_position.x
			var diff_y = body.global_position.y - self.global_position.y
			var diff_z = body.global_position.z - self.global_position.z
			body.global_position.x = target.global_position.x + diff_z * body.scale.y
			body.global_position.y = target.global_position.y + diff_y
			body.global_position.z = target.global_position.z - diff_x * body.scale.y
			body.rotate_y( PI / 2 )
			if body.flipped:
				body.velocity = body.velocity.rotated(Vector3(0,1,0), 3 * PI / 2)
			else:
				body.velocity = body.velocity.rotated(Vector3(0,1,0), PI / 2)
		
		if ( rotate_degrees == "270"):
			var diff_x = body.global_position.x - self.global_position.x
			var diff_y = body.global_position.y - self.global_position.y
			var diff_z = body.global_position.z - self.global_position.z
			body.global_position.x = target.global_position.x - diff_z * body.scale.y
			body.global_position.y = target.global_position.y + diff_y
			body.global_position.z = target.global_position.z + diff_x * body.scale.y
			body.rotate_y(3 * PI / 2 )
			if body.flipped:
				body.velocity = body.velocity.rotated(Vector3(0,1,0), PI / 2)
			else:
				body.velocity = body.velocity.rotated(Vector3(0,1,0), 3 * PI / 2)

		if (flip_vertical):
			body.gravity = -body.gravity
			if (body.flipped):
				body.flipped = false
				body.set_scale( Vector3(1,1,1))
			else:
				body.flipped = true
				body.set_scale( Vector3(1,-1,1))
		
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
