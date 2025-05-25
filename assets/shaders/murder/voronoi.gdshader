shader_type canvas_item;
uniform sampler2D peek: hint_screen_texture;
uniform float intensity = 1;
uniform float vignette_intensity = 1;
uniform sampler2D vignette;
uniform float number_of_cells = 100;
uniform vec3 base_colour = vec3(0,0,100);
uniform float data_field_1 = 0;
uniform bool data_1_is_speed = true;
uniform float data_field_2 = 0;
uniform bool data_2_is_colour_variation = true;
uniform float data_field_3 = 0;
uniform bool data_3_is_smear_mix = true;
uniform float tone_intensity = 0.;

#include "res://assets/libraries/murder/random.gdshaderinc"


void fragment() {
	vec2 uv = SCREEN_UV;
	float vignette_factor = mix(0.0, texture(vignette, UV).w, vignette_intensity);
	float x_cell = floor(uv.x * number_of_cells);
	float y_cell = floor(uv.y * number_of_cells);

	float closest = 10000.;
	vec3 cell_id;
	vec3 centre;
	float closest2D;
	
	for (int i = -1; i < 2; i++) {
		for (int j = -1; j < 2; j++) {
			for (int k = -1; k < 2; k++) {
			
				vec2 cell_uv2 = vec2((x_cell+float(i))/number_of_cells, (y_cell+float(j))/number_of_cells);
				vec3 cell_uv = vec3(cell_uv2, (floor(TIME*data_field_1 + random2Dto1D(cell_uv2)) + float(k))/number_of_cells);
				vec3 random = random3Dto3D(cell_uv+3.);

				vec3 cell_centre = cell_uv + random / number_of_cells;
				float dist = distance(vec3(uv,TIME*data_field_1/number_of_cells),cell_centre);
				if (dist < closest && random3Dto1D(cell_uv+4.) < 0.5){
					closest = dist;
					closest2D = distance(uv,cell_centre.xy);
					cell_id = cell_uv;
					centre = cell_centre;
				}
			} 
		}
	}
	float max_dist = distance(vec2(0,0),vec2(1./number_of_cells, 1./number_of_cells));

	vec3 colour = mix(base_colour/255., random2Dto3D(cell_id.xy+vec2(3.,3.)) * base_colour/255., data_field_2);
	colour *= 1. - closest2D/max_dist;
	
	vec2 direction = normalize(random2Dto2D(cell_id.xy+vec2(3.,3.)));
	direction *= intensity/100. * clamp((0.5 - closest2D/max_dist),0.,1.);
	vec2 central_direct = normalize(vec2(0.5,0.5)-centre.xy) * intensity/100.;
	
	direction = mix(direction, central_direct, data_field_3);
	
	uv += direction * clamp(1.-vignette_factor,0.,1.); 
	
	vec3 output = texture(peek, uv).rgb;
	output = mix(output, colour, tone_intensity * clamp(1.-vignette_factor,0.,1.));

	COLOR = vec4(output.rgb,1.);
}
