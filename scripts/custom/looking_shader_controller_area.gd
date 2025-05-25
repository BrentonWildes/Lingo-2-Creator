class_name LookingShaderControllerArea extends ShaderControllerArea

@export var max_angle = 90;
@export var distance_far:float
@export var distance_near:float

func _ready():
	if shader_node:
		shader = get_node(shader_node)
		shader.visible = false
		assert(is_instance_valid(shader_options), "Shading control at " + str(get_path()) + "does not have options assigned")
		#if is_instance_valid(shader_options):
		#	for child in shader_options.get_property_list():
		#		assert(is_instance_valid(shader_options.get(child)), "Shading control at " + str(get_path()) + "does not have its " +str(child) + " options assigned")
	else:
		self.set_process(false)
		assert(false,("Shading controller at: " + str(get_path()) + "has no shader assigned"))
	

	max_distance = $CollisionShape3D.shape.radius
	
func _process(_delta):
	var angle = player.global_position.direction_to(self.global_position).angle_to(-player.get_node("pivot").global_transform.basis.z)
	angle = rad_to_deg(angle)
	if angle > max_angle:
		angle = 361.
	var distance = player.global_position.distance_to(self.global_position)
	distance = 1.0 - clamp((distance - distance_near)/(distance_far-distance_near), 0, 1)
	angle = lerp(361., angle, distance)
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
