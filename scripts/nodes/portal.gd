extends Node3D

@export var offset:Vector3 = Vector3(0,0,0)
@onready var player = get_node("/root/scene/player")
@onready var camera = get_node("Viewport/Camera3D")

func _ready():
	_set_viewport_mat($quad, $Viewport)
	$exit.global_position.x = global_position.x + offset.x
	$exit.global_position.y = global_position.y + offset.y
	$exit.global_position.z = global_position.z + offset.z

func _set_viewport_mat(_display_mesh : MeshInstance3D, _sub_viewport : SubViewport, _surface_id : int = 0):
	var _mat : StandardMaterial3D = StandardMaterial3D.new()
	_mat.albedo_texture = _sub_viewport.get_texture()
	_display_mesh.set_surface_override_material(_surface_id, _mat)

func _physics_process(_delta):
	camera.global_position.x = global_position.x + offset.x
	camera.global_position.y = global_position.y + offset.y + 2.5
	camera.global_position.z = global_position.z + offset.z
	#camera.global_rotation.x = player.global_rotation.x
	camera.global_rotation.y = player.global_rotation.y
	#camera.global_rotation.z = player.global_rotation.z
