shader_type canvas_item;
uniform float intensity = 1;
uniform float data_field_1 = 11.5;
uniform bool squiggle_period_is_data_1 = true;
uniform float data_field_2 = 1.2;
uniform bool squiggle_amount_is_data_2 = true;
uniform float speed = 0.25;
uniform float data_field_3 = 0.35;
uniform bool rise_speed_is_data_3 = true;
uniform vec2 max_size = vec2(1,1);
uniform float vignette_intensity = 1;
uniform sampler2D vignette;
uniform sampler2D peek: hint_screen_texture;
uniform float chance_of_wave_per_cell = 0.1;
uniform float number_of_cells = 10;

#include "res://assets/libraries/murder/random.gdshaderinc"

void fragment() {
	vec2 uv = SCREEN_UV;
	//int number = int(float(max_waves) * intensity);
	float vignette_factor = mix(0.0, texture(vignette, UV).w, vignette_intensity);

	vec4 colour = vec4(0,0,0,0);
	float alpha = 0.;
	float speed_factor = speed/100.;

	float x_cell = floor(uv.x * number_of_cells);
	float y_cell = floor(uv.y * number_of_cells);

	float closest = 10000.;
	vec2 cell_id;
	vec2 centre;
	float closest2D;

	for (int i = -2; i < 3; i++) {
		for (int j = -2; j < 3; j++) {

			vec2 cell_uv = vec2((x_cell+float(i))/number_of_cells, (y_cell+float(j))/number_of_cells);

			vec2 cell_centre = cell_uv + random2Dto2D(cell_uv) / number_of_cells;

		 	cell_centre.x += max_size.x * sin(TIME*2.2818*speed_factor*20. * random2Dto1D(cell_uv))/number_of_cells;
			cell_centre.y -= max_size.y * mod(TIME*data_field_3 + random2Dto1D(cell_uv), 1.0);


			float dist = distance(uv,cell_centre);
			if (dist < closest && random2Dto1D(cell_uv) < chance_of_wave_per_cell){
				closest = dist;
				closest2D = distance(uv,cell_centre.xy);
				cell_id = cell_uv;
				centre = cell_centre;

			}
		}
	}


	float y_bound_down = uv.y + max_size.y/number_of_cells;
	float y_bound_up = uv.y;

	float curly = speed_factor * 20.*(mod(TIME + random2Dto1D(cell_id) *data_field_1/2.0, data_field_1/2.0) - data_field_1/4.0);
	float x_bound = uv.x + intensity * max_size.x/number_of_cells * sin(curly *number_of_cells* uv.y*5.) * data_field_2;

	float x_factor = 2.*abs(centre.y-y_bound_up)/(max_size.y/number_of_cells);
	float x_variance = clamp(-pow(x_factor,2.0) + 2.*x_factor, 0.1,0.9);
	float x_bound_left = x_bound - x_variance*max_size.x/number_of_cells;
	float x_bound_right= x_bound + x_variance*max_size.x/number_of_cells ;//+ max_size.x/1920. * abs((randomy-y_bound_up)-max_size.y/1080.)/ (max_size.y/1080.);

	if (y_bound_up < centre.y && y_bound_down > centre.y && x_bound_left < centre.x && x_bound_right  > centre.x ){
		float central = clamp(min(centre.x-x_bound_left, x_bound_right-centre.x)/max_size.x/number_of_cells, 0.25, 1.0);
		uv.x += intensity * central * max_size.x/number_of_cells * sin(centre.y - uv.y + speed_factor*TIME)/4.0;
		uv.y += intensity * central * max_size.y/number_of_cells * floor(x_variance * 10.)/40.;
		alpha = x_variance;
		//colour.r = 1.- x_variance;
		//colour.r += 0.1;
		}




	colour += vec4(texture(peek,uv).rgb, min(1.-vignette_factor, alpha));


	COLOR = colour;
	}
