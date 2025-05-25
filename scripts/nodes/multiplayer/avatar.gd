extends Node3D

var steam_id
var steam_name = "name"
var said_hi = false
var material = "gold"

# Movement interpolation
var _previous_move_time
var _previous_global_transform
var _latest_move_time
var _latest_global_transform
const max_interpolation_distance_squared = 4 * 4

func _ready():
	# Initialize movement interpolation
	_previous_move_time = 0
	_latest_move_time = 1
	_previous_global_transform = global_transform
	_latest_global_transform = global_transform
	# Hide players by default until they have a known location.
	# hide()
	# Disable colliders buried inside signs.
	for static_body in global.getNodesOfType(self, "CollisionObject3D"):
		static_body.collision_mask = 0
		static_body.collision_layer = 0

func _interpolate_movement():
	var time_since_latest = Time.get_ticks_usec() - _latest_move_time
	var lerp_length = max(1, _latest_move_time - _previous_move_time)
	var lerp_progress = min(1.0, float(time_since_latest) / float(lerp_length))
	global_transform = _previous_global_transform.interpolate_with(_latest_global_transform, lerp_progress)
	
func _process(_delta):
	_interpolate_movement()

func global_move_to(new_global_transform):
	_interpolate_movement()
	var distance = _latest_global_transform.origin.distance_squared_to(new_global_transform.origin)
	if distance > max_interpolation_distance_squared:
		global_transform = new_global_transform
	_previous_move_time = _latest_move_time
	_previous_global_transform = global_transform
	_latest_move_time = Time.get_ticks_usec()
	_latest_global_transform = new_global_transform

func set_steam_name(new_steam_name):
	steam_name = new_steam_name
	get_node("name").text = steam_name

func set_material(new_material):
	material = new_material
	$BodyMesh.set_surface_material(0, load("res://assets/materials/" + material + ".material"))
