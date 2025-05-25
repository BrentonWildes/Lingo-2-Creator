class_name WhileInsideShaderControllerArea extends ShaderControllerArea

@export var distance_inside_before_starting:float = 1.5

@export var toggle_speed = 1.5
var distance:float = 0
var exiting:bool = false

func _ready():
	if shader_node:
		shader = get_node(shader_node)
		shader.visible = false
	else:
		self.set_process(false)
		print("Shading node at: " + str(get_path()) + "has no shader assigned")
	

	self.set_process(false)

func _process(_delta):
	if exiting:
		distance = lerp(distance, 0., toggle_speed)
	elif self.global_position.distance_to(player.global_position) + distance_inside_before_starting < max_distance:
		distance = lerp(distance, 1., toggle_speed)
	
	if exiting and distance < 0.01:
		distance = 0
	
	set_shader_params(distance)

	if not exiting: shader.visible = true
	
	if exiting and distance == 0:
		shader.visible = false
		self.set_process(false)
	
	
func _on_body_entered(body):
	if body.is_in_group("player") and is_instance_valid(shader):
		player = body
		self.set_process(true)
		shader.material.set_shader_parameter("vignette", vignette)
		max_distance = self.global_position.distance_to(player.global_position)
		exiting = false

func _on_body_exited(body):
	if body.is_in_group("player") and is_instance_valid(shader):
		exiting = true
