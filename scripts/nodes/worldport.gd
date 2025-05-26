extends Node3D
class_name Worldport

@export var exit:String
@export var entry_point:Vector3 = Vector3(0,0,0)
@export var entry_rotate:Vector3 = Vector3(0,0,0)
@export var sets_entry_point:bool = true
@export var invisible:bool = false
@export var fades:bool = false

func _ready():
	self.body_entered.connect(bodyEntered)
	if settings.worldport_visible == "never" || (settings.worldport_visible == "default" && invisible):
		get_node("MeshInstance3D").hide()
	
	switcher.preload_map("res://objects/scenes/" + exit + ".tscn")

func bodyEntered(body):
	if body.is_in_group("player"):
		global.map = exit
		global.entry_point = entry_point
		global.entry_rotate = entry_rotate
		global.entry_pivot = body.get_node("pivot").rotation
		global.entry_player_rotate = body.rotation
		global.sets_entry_point = sets_entry_point
		
		#offsets - position and velocity
		var diff_x = 0
		var diff_y = 0
		var diff_z = 0
		if ( entry_rotate.y == 0 ):
			diff_x = body.global_position.x - self.global_position.x
			diff_y = body.global_position.y - self.global_position.y
			diff_z = body.global_position.z - self.global_position.z
			global.entry_point.x += diff_x
			global.entry_point.y += diff_y
			global.entry_point.z += diff_z
			
		if ( entry_rotate.y == 180 ):
			diff_x = body.global_position.x - self.global_position.x
			diff_y = body.global_position.y - self.global_position.y
			diff_z = body.global_position.z - self.global_position.z
			global.entry_point.x -= diff_x
			global.entry_point.y += diff_y
			global.entry_point.z -= diff_z
			body.velocity = body.velocity.rotated(Vector3(0,1,0), PI)
		
		if ( entry_rotate.y == 90):
			diff_x = body.global_position.x - self.global_position.x
			diff_y = body.global_position.y - self.global_position.y
			diff_z = body.global_position.z - self.global_position.z
			global.entry_point.x += diff_z
			global.entry_point.y += diff_y
			global.entry_point.z -= diff_x
			body.velocity = body.velocity.rotated(Vector3(0,1,0), PI / 2)
		
		if ( entry_rotate.y == 270):
			diff_x = body.global_position.x - self.global_position.x
			diff_y = body.global_position.y - self.global_position.y
			diff_z = body.global_position.z - self.global_position.z
			global.entry_point.x -= diff_z
			global.entry_point.y += diff_y
			global.entry_point.z += diff_x
			body.velocity = body.velocity.rotated(Vector3(0,1,0), 3 * PI / 2)
		
		#global.entry_diff = Vector3(diff_x, diff_y, diff_z)
		global.entry_velocity = body.velocity
		
		call_deferred( "changeScene" )

func changeScene():
	var path = global.scenes[exit].path if global.scenes.has(exit) else "res://objects/scenes/" + exit + ".tscn"

	if settings.worldport_fades == "always" || (settings.worldport_fades == "default" && fades):
		fader._fade_start( path )
	else:
		switcher.switch_map( path )
