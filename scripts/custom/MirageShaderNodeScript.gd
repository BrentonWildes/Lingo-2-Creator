extends ColorRect

@export var camera:Camera3D
@onready var player = $/root/scene/player
@export var to_render:Node
@export var to_look:Node
@export var near_clip_offset = 1.5

func _ready():
	self.material.set_shader_parameter("peek", camera.get_parent().get_texture())


func _process(_delta):
	var main_cam = get_viewport().get_camera_3d()
	camera.get_viewport().size = get_viewport().size
	camera.environment = main_cam.environment
	camera.fov = main_cam.fov
	
	camera.global_position = to_render.to_global(to_look.to_local(player.get_node("pivot/camera").global_position))
	camera.near = clamp(to_render.global_transform.origin.distance_to(camera.global_transform.origin)-near_clip_offset, 0.05, 500)
	camera.global_transform.basis = to_render.global_transform.basis.orthonormalized()* to_look.global_transform.basis.orthonormalized().inverse() * player.get_node("pivot/camera").global_transform.basis 
	camera.far = camera.near + 2.*near_clip_offset
