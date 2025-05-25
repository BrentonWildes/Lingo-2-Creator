class_name GlobalSignalledShaderController extends GlobalShaderController

var active = false

func _ready():
	if shader_node:
		shader = get_node(shader_node)
	else:
		print("Shading node at: " + str(get_path()) + "has no shader assigned")
	self.set_process(false)

func _process(_delta):
	shader.material.set_shader_parameter("vignette", vignette)
	var distance = 1.
	if not active: distance = 0.
	set_shader_params(distance)

	

func _toggle_signal():
	active = not active
	self.set_process(true)
	
func _on_signal():
	active = true
	self.set_process(true)
	
func _off_signal():
	active = false
	self.set_process(true)

