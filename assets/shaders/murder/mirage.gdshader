shader_type canvas_item;
uniform float vignette_intensity = 1;
uniform float intensity = 1;
uniform float data_field_1 = 0.8;
uniform bool maximum_alpha_is_data_1 = true;
uniform float data_field_2 = 0.2;
uniform bool thres_alpha_is_data_2 = true;
uniform float data_field_3 = 0.35;
uniform bool waviness_is_data_3 = true;
uniform float speed = 2.5;
uniform sampler2D vignette;
uniform sampler2D peek;


void fragment() {
	vec2 uv = SCREEN_UV;
	//int number = int(float(max_waves) * intensity);
	uv.x += data_field_3 * sin(speed * TIME + intensity * uv.y * 5.0);

	float vignette_factor = mix(0.0, texture(vignette, uv).w, vignette_intensity);
	vignette_factor = min(vignette_factor, data_field_1);
	if (vignette_factor > 0.01){
		vignette_factor = max(data_field_2, vignette_factor);
	}
	
	COLOR = vec4(0,0,0,0);
	COLOR = vec4(texture(peek,uv).rgb, vignette_factor);
	}
