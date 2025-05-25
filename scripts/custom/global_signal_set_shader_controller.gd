class_name GlobalSignalSetShaderController extends GlobalShaderController

var active = false
var distance

func _ready():
	if shader_node:
		shader = get_node(shader_node)
	else:
		print("Shading node at: " + str(get_path()) + "has no shader assigned")
	self.set_process(false)

func _process(_delta):
	shader.material.set_shader_parameter("vignette", vignette)
	if not active: distance = 0
	set_shader_params(distance)
	

func _toggle_signal(sig:float):
	active = not active
	self.set_process(true)
	distance = sig
	print("toggled?")

	
func _on_signal(sig:float):
	active = true
	self.set_process(true)
	distance = sig
	
func _off_signal(sig:float):
	active = false
	self.set_process(true)
	distance = sig
	
func _adjust_level_signal(sig:float):
	distance = sig
	print("adjusted?")
	

