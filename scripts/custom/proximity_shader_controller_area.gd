class_name ProximityShaderControllerArea extends ShaderControllerArea

func _ready():
	if shader_node:
		shader = get_node(shader_node)
		shader.visible = false
	else:
		print("Shading node at: " + str(get_path()) + "has no shader assigned")

	self.set_process(false)
	max_distance = $CollisionShape3D.shape.radius

func _process(_delta):
	var distance = self.global_position.distance_to(player.global_position)
	set_shader_params(distance)

func _on_body_entered(body):
	if body.is_in_group("player") and is_instance_valid(shader):
		player = body
		shader.material.set_shader_parameter("vignette", vignette)
		shader.visible = true
		self.set_process(true)

func _on_body_exited(body):
	if body.is_in_group("player") and is_instance_valid(shader):
		shader.visible = false
		self.set_process(false)
