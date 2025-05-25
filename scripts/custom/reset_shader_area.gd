class_name ResetShaderControllerArea extends Area3D

@export var controllers:Array[Node]
@export var select_directory:bool = false
@export var exclude:Array[Node]
@export var processArray:Array[Node]

var list_of_controllers:Array[Node]
@onready var player = "/root/scene/player"

func _ready():
	if select_directory:
		for node in controllers:
			for child in node.get_children():
				if not child in exclude and (child is  ShaderControllerArea or child is GlobalShaderController): 
					list_of_controllers += [child]
	else:
		for node in controllers:
			if not node in exclude: 
				list_of_controllers += [node]
			

func _process(_delta):
	var keep_going = false
	for controller in list_of_controllers:
		var options = controller.shader_options
		
		var vig_mix = lerp(controller.shader.material.get_shader_parameter("vignette_intensity"), options.vignette_control.intensity_range.x, options.vignette_control.lerp_speed)
		var intens_mix = lerp(controller.shader.material.get_shader_parameter("intensity"),  options.intensity_control.intensity_range.x, options.intensity_control.lerp_speed)
		var data_1_mix = lerp(controller.shader.material.get_shader_parameter("data_field_1"),  options.data_field_1_control.intensity_range.x, options.data_field_1_control.lerp_speed)
		var data_2_mix = lerp(controller.shader.material.get_shader_parameter("data_field_2"), options.data_field_2_control.intensity_range.x, options.data_field_2_control.lerp_speed)
		var data_3_mix = lerp(controller.shader.material.get_shader_parameter("data_field_3"), options.data_field_3_control.intensity_range.x, options.data_field_3_control.lerp_speed)
		
		controller.shader.material.set_shader_parameter("vignette_intensity", vig_mix)
		controller.shader.material.set_shader_parameter("intensity", intens_mix)
		controller.shader.material.set_shader_parameter("data_field_1", data_1_mix)
		controller.shader.material.set_shader_parameter("data_field_2", data_2_mix)
		controller.shader.material.set_shader_parameter("data_field_3", data_3_mix)
		
		if abs(intens_mix - options.intensity_control.intensity_range.x) < 0.01:
			controller.shader.visible = false
		else:
			keep_going = true
			
	if not keep_going:
		self.set_process(false)
		for controller in processArray:
			controller.set_process(true)

func _on_body_entered(body):
	if body.is_in_group("player") and not self.is_processing():
		processArray = []
		player = body
		self.set_process(true)
		for controller in list_of_controllers:
			if controller.is_processing():
				processArray.append(controller)
				controller.set_process(false)
				


