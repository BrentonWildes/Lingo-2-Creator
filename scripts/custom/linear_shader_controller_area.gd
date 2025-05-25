class_name LinearShaderControllerArea extends ShaderControllerArea

var x_least:float
var x_most:float
@export var margin:float = 1.5

func _ready():
	if shader_node:
		shader = get_node(shader_node)
		shader.visible = false
	else:
		print("Shading node at: " + str(get_path()) + "has no shader assigned")
	self.set_process(false)

	x_least = $CollisionShape3D.transform.origin.x - $CollisionShape3D.shape.size.x/2. +margin 
	x_most =  $CollisionShape3D.transform.origin.x + $CollisionShape3D.shape.size.x/2. -margin

func _process(_delta):
	var distance = clamp((self.to_local(player.global_position).x -x_least)/(x_most-x_least),0,1.)
	if distance > 0: 
		shader.visible = true
	else: 
		shader.visible = false
	set_shader_params(distance)
	
func _on_body_entered(body):
	if body.is_in_group("player") and is_instance_valid(shader):
		player = body
		self.set_process(true)
		shader.material.set_shader_parameter("vignette", vignette)


func _on_body_exited(body):
	if body.is_in_group("player") and is_instance_valid(shader):
		self.set_process(false)
		player = body
