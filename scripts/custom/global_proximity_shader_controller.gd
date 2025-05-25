class_name GlobalProximityShaderController extends GlobalShaderController

func _ready():
	if shader_node:
		shader = get_node(shader_node)
	else:
		self.set_process(false)
		print("Shading node at: " + str(get_path()) + " has no shader assigned")
	
func _process(_delta):
	shader.material.set_shader_parameter("vignette", vignette)
	var distance = (player.global_position.distance_to(global.entry_point))
	set_shader_params(distance)
	
	

