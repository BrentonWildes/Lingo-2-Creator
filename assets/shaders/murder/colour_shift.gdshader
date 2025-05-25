shader_type spatial;
uniform sampler2D colours : repeat_enable, filter_linear, source_color;
uniform float speed = 1.0;
#include "res://assets/libraries/murder/HSV_RGB_converters.gdshaderinc"

void fragment() {
	ALBEDO = texture(colours, vec2(TIME*speed,0.5)).xyz;
}

