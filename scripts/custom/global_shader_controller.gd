class_name GlobalShaderController extends Node3D

enum scaling {linear, power, stepped, pulsing}

@export var shader_node:NodePath = ""
@export var vignette:Texture
var shader:ColorRect
@onready var player = $/root/scene/player
var max_distance:float

@export var shader_options:shader_control_datatype 

func percentage(value:float, options:shader_field_control_datatype):
	var temp = (value-options.progress_range.x)/(options.progress_range.y - options.progress_range.x)
	if options.type_of_scaling == options.scaling.linear:
		pass
	elif options.type_of_scaling == options.scaling.power:
		temp =  temp**options.scaling_variable
	elif options.type_of_scaling == options.scaling.stepped:
		temp = floor(temp*options.scaling_variable)/options.scaling_variable
	elif options.type_of_scaling == options.scaling.pulsing:
		temp = temp * (sin(fmod(options.scaling_variable*Time.get_ticks_msec()/1000., 6.28))+1)/2.
	temp = clamp(temp, 0.0, 1.0)
	return temp
	
func calc_shader_param(distance:float, options:shader_field_control_datatype, shader_parameter:String): 
	var mix = lerp(options.intensity_range.x, options.intensity_range.y,percentage(distance, options))
	var temp:float = shader.material.get_shader_parameter(shader_parameter)
	mix = lerp(temp, mix, options.lerp_speed)
	return mix

func set_shader_params(distance:float):
	var vig_mix = calc_shader_param(distance, shader_options.vignette_control, "vignette_intensity")
	var intens_mix = calc_shader_param(distance, shader_options.intensity_control, "intensity")
	var data_1_mix = calc_shader_param(distance, shader_options.data_field_1_control, "data_field_1")
	var data_2_mix = calc_shader_param(distance, shader_options.data_field_2_control, "data_field_2")
	var data_3_mix = calc_shader_param(distance, shader_options.data_field_3_control, "data_field_3")


	if shader_options.vignette_control.lerp_speed > 0: shader.material.set_shader_parameter("vignette_intensity", vig_mix)
	if shader_options.intensity_control.lerp_speed > 0: shader.material.set_shader_parameter("intensity", intens_mix)
	if shader_options.data_field_1_control.lerp_speed > 0: 	shader.material.set_shader_parameter("data_field_1", data_1_mix)
	if shader_options.data_field_2_control.lerp_speed > 0: 	shader.material.set_shader_parameter("data_field_2", data_2_mix)
	if shader_options.data_field_3_control.lerp_speed > 0: 	shader.material.set_shader_parameter("data_field_3", data_3_mix)



func _ready():
	if shader_node:
		shader = get_node(shader_node)
		shader.visible = false
	else:
		self.set_process(false)
		print("Shading node at: " + str(get_path()) + "has no shader assigned")

