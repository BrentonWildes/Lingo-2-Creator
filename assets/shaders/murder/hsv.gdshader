shader_type canvas_item;
uniform sampler2D peek: hint_screen_texture;
uniform float intensity = 1;
uniform float vignette_intensity = 1;
uniform sampler2D vignette;
uniform float data_field_1 = 0;
uniform bool data_1_is_hue_shift = true;
uniform float data_field_2 = 0;
uniform bool data_2_is_saturation_shift = true;
uniform bool wrap_saturation = false;
uniform float data_field_3 = 0;
uniform bool data_3_is_value_shift = true;
uniform bool wrap_value = false;

#include "res://assets/libraries/murder/HSV_RGB_converters.gdshaderinc"

void fragment() {
	vec2 uv = SCREEN_UV;
	float vignette_factor = mix(0.0, texture(vignette, UV).w, vignette_intensity);
	vec4 screen = texture(peek,uv);
	vec3 hsv = rgb2hsv(fromLinear(screen).rgb);
	vec3 hsv_orig = hsv;
	hsv.x = mix(hsv.x, 1. - hsv.x, data_field_1);
	if (wrap_saturation){hsv.y = mod(hsv.y+data_field_2, 1.0);}
	else{hsv.y = mix(0., 1., hsv.y*data_field_2);}
	if (wrap_value){hsv.z = mod(hsv.z+data_field_3, 1.);}
	else{hsv.z = mix(0., 1., hsv.z*data_field_3);}
	hsv = mix(hsv_orig,hsv, intensity);
	vec3 rgb = toLinear(vec4(hsv2rgb(hsv),1.)).rgb;
	COLOR = vec4(rgb, 1.-vignette_factor);
}









