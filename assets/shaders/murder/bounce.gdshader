shader_type canvas_item;
uniform sampler2D tex: hint_default_white;
uniform float intensity = 1;
uniform float vignette_intensity = 1;
uniform sampler2D vignette;
uniform float data_field_1 = 0;
uniform bool data_1_is_x_size_of_tex = true;
uniform float data_field_2 = 0;
uniform bool data_2_is_y_size_of_tex = true;
uniform float data_field_3 = 0;
uniform bool data_3_is_speed = true;


void fragment() {
	vec2 uv = SCREEN_UV;
	float vignette_factor = mix(0.0, texture(vignette, UV).w, vignette_intensity);

	//vec4 = texture(tex, uv);
	float x_dim = (1.-data_field_1);
	float y_dim = (1.-data_field_2);
	
	float tot_x = mod(data_field_3 * TIME, 2.*x_dim);
	float tot_y = mod(data_field_3 * TIME * 1.314, 2.*y_dim);
	
	if (tot_x > x_dim){
		tot_x = 2.*x_dim - tot_x;
	}
	
	if (tot_y > y_dim){
		tot_y = 2.*y_dim - tot_y;
	}
	COLOR = vec4(0,0,0,0);
	
	if (uv.x > tot_x && uv.x < tot_x + data_field_1 && uv.y > tot_y && uv.y < tot_y + data_field_2){
		uv.x = (uv.x - tot_x)/(data_field_1);
		uv.y = (uv.y - tot_y)/(data_field_2);
		COLOR = vec4(texture(tex, uv).xyz, 1.-vignette_factor);
		}

}
