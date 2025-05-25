shader_type canvas_item;
uniform sampler2D peek: hint_screen_texture;
uniform float intensity = 1;
uniform float vignette_intensity = 1;
uniform sampler2D vignette;
uniform float data_field_1 = 0;
uniform bool data_1_is_x = true;
uniform float data_field_2 = 0;
uniform bool data_2_is_y = true;
uniform float data_field_3 = 0;
uniform bool data_3_is_transparency = true;

void fragment() {
	vec2 uv = SCREEN_UV;
	float vignette_factor = mix(0.0, texture(vignette, UV).w, vignette_intensity);

	vec2 direction = normalize(vec2(data_field_1,data_field_2)-uv) * intensity/100.;

	direction = mix(vec2(0,0), direction, 1.- abs(2.0* abs(length(uv - vec2(0.5,0.5)))/0.707 -1.0));

	uv += direction * clamp(1.-vignette_factor,0.,1.);

	vec3 output = texture(peek, uv).rgb;
	COLOR = vec4(output.rgb,1.-data_field_3);
}
