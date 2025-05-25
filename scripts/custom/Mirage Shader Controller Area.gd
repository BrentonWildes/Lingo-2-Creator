class_name MirageShaderControllerArea extends ShaderControllerArea

@export var distance_far:float = 20.
@export var distance_near:float = 10.
@export var maximum_at:float = 15.
@export var distance_power:float = 1.

func _ready():
	if shader_node:
		shader = get_node(shader_node)
		shader.visible = false
		assert(is_instance_valid(shader_options), "Shading control at " + str(get_path()) + "does not have options assigned")
	else:
		self.set_process(false)
		assert(false,("Shading controller at: " + str(get_path()) + "has no shader assigned"))
	

	max_distance = $CollisionShape3D.shape.radius
	
func _process(_delta):
	var angle = player.global_position.direction_to(self.global_position).angle_to(-player.get_node("pivot").global_transform.basis.z)
	angle = rad_to_deg(angle)
	var distance = player.global_position.distance_to(self.global_position)
	var dist = distance - maximum_at
	if dist < 0:
		dist /= distance_near-maximum_at
	else:
		dist /= distance_far-maximum_at
	dist = clamp(1.0 - dist, 0.0, 1.0)
	dist = pow(dist, distance_power)
	
	angle = lerp(shader_options.vignette_control.progress_range.x, angle, dist)
	set_shader_params(angle)
	
func _on_body_entered(body):
	if body.is_in_group("player") and shader_node:
		self.set_process(true)
		player = body
		shader.material.set_shader_parameter("vignette", vignette)
		shader.visible = true

func _on_body_exited(body):
	if body.is_in_group("player") and shader_node:
		self.set_process(false)
		shader.visible = false
