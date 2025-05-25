shader_type canvas_item;
uniform sampler2D tex: hint_default_white;
uniform float intensity = 1;
uniform float vignette_intensity = 1;
uniform sampler2D vignette;
uniform float data_field_1 = 0;
uniform bool data_1_is_horizontal_scroll = true;
uniform float data_field_2 = 0;
uniform bool data_2_is_vertical_scroll = true;
uniform float data_field_3 = 0;
uniform bool data_3_is_speed = true;


void fragment() {
	vec2 uv = SCREEN_UV;
	float vignette_factor = mix(0.0, texture(vignette, UV).w, vignette_intensity);
	
	uv.x += data_field_1 * data_field_3 * TIME;
	uv.y += data_field_2 * data_field_3 * TIME;
	
	uv = mod(uv, vec2(1.0,1.0));

	COLOR = vec4(texture(tex, uv));
	COLOR.w *= 1.-vignette_factor;
	//this prevents a screen flash in some circumstances
	COLOR.w *= intensity;

}
