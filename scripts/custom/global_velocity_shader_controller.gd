class_name GlobalVelocityShaderController extends GlobalShaderController

func _ready():
	if shader_node:
		shader = get_node(shader_node)
	else:
		self.set_process(false)
		print("Shading node at: " + str(get_path()) + "has no shader assigned")
	

func _process(_delta):
	shader.material.set_shader_parameter("vignette", vignette)
	var velo = player.velocity.length()
	set_shader_params(velo)
	

