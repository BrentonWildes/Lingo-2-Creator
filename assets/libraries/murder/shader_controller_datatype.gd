class_name shader_field_control_datatype extends Resource

enum scaling {linear, power, stepped, pulsing}

@export var intensity_range:Vector2 = Vector2(0,1)
@export var progress_range: Vector2 = Vector2(10,0)
@export var type_of_scaling:scaling = scaling.linear
@export var scaling_variable:float = 0
@export var lerp_speed:float = 0
