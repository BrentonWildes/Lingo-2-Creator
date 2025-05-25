shader_type canvas_item;
uniform sampler2D vignette;
uniform sampler2D vignette2;
uniform float vignette_intensity = 0;
uniform float intensity = 0;
uniform vec2 centre_of_transformation = vec2(0.5,0.5);
uniform bool data_1_is_rotation_speed = true;
uniform float data_field_1 = 0;
uniform bool data_2_is_translation_speed_modifier = true;
uniform float data_field_2 = 1;
uniform vec2 translation_speed = vec2(0,0);
uniform bool data_3_is_scaling_speed_modifier = true;
uniform float data_field_3 = 1;
uniform vec2 scaling_speed = vec2(0,0); 
uniform float zoom_in = 1.;

void fragment() {
	vec2 uv = SCREEN_UV;
	float time = mod(TIME, 6.28);

	
	vec2 direction = uv - centre_of_transformation;
	
	uv.x = zoom_in * (direction.x * cos(time * data_field_1) - direction.y * sin(time*data_field_1));
	uv.y = zoom_in*(direction.y * cos(time * data_field_1) + direction.x * sin(time*data_field_1));
	

	uv += centre_of_transformation;
	
	direction = uv - centre_of_transformation;
	float dist = distance(uv, centre_of_transformation);
	uv += normalize(direction) * (dist * (time* scaling_speed * data_field_3));	
	uv += data_field_2 * translation_speed * time;
	
	uv = mod(uv, vec2(1.0,1.0));
	
	float alpha = texture(vignette, uv).w;
	float vignette_factor = mix(0.0, texture(vignette2, SCREEN_UV).w, vignette_intensity);

	COLOR = vec4(0,0,0, clamp(1. - alpha * (1.- clamp(vignette_factor, 0.0,1.0)), 0.0, 1.0));
}

