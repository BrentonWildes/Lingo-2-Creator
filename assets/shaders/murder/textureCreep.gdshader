shader_type canvas_item;
uniform float intensity = 1;
uniform float vignette_intensity = 1;
uniform float blue_start_at_intensity = 1;
uniform float red_start_at_intensity = 2;
uniform float green_start_at_intensity = 3;
uniform float blue_max_at_intensity = 2;
uniform float red_max_at_intensity = 3;
uniform float green_max_at_intensity = 4;
uniform float corona_lines_start_at_intensity = 4;
uniform float corona_lines_max_at_intensity = 5;
uniform vec3 red_colour = vec3(255,0,0);
uniform vec3 green_colour = vec3(0,255,0);
uniform vec3 blue_colour = vec3(0,0,255);
uniform float data_field_1 = 24;
uniform bool speed_is_data_1 = true;
uniform float data_field_2 = 2;
uniform bool grid_size_is_data_2 = true;
uniform float data_field_3 = 5;
uniform bool coronal_segments_is_data_3 = true;
uniform sampler2D vignette;
uniform float random_seed = 1.;
uniform sampler2D tex;
uniform vec3 coronal_colour_1 = vec3(45,45,45);
uniform vec3 coronal_colour_2 = vec3(50,35,0);
uniform vec3 coronal_colour_3 = vec3(40,2,2);
uniform int base_coronal_lines= 5;
uniform float spread_factor = 0.5;
uniform float line_thickness = 0.01;

#include "res://assets/libraries/murder/random.gdshaderinc"

float map_to(float x, float a, float b) {return (x-a)/(b-a);}


void fragment() {
	float vignette_factor = mix(0.0, texture(vignette, UV).w, vignette_intensity);
	float red_intense = clamp(map_to(intensity, red_start_at_intensity, red_max_at_intensity), 0.0, 1.0);
	float green_intense = clamp(map_to(intensity, green_start_at_intensity, green_max_at_intensity), 0.0, 1.0);
	float blue_intense = clamp(map_to(intensity, blue_start_at_intensity, blue_max_at_intensity),  0.0, 1.0);
	float corona_intense = clamp(map_to(intensity, corona_lines_start_at_intensity, corona_lines_max_at_intensity),  0.0, 10000.0);

	float dist = distance(SCREEN_UV, vec2(0.5,0.5)) + data_field_1*TIME/50.;

	vec2 uv = data_field_2* dist * normalize(SCREEN_UV - vec2(0.5,0.5)) + vec2(0.5,0.5);
	uv = mod(uv, vec2(1.,1.));
	float visible_channel = 1.- (texture(tex,uv).r);
	vec4 colour = vec4(0,0,0,0);
	
	if (red_intense > 0.0){
	colour = vec4(red_intense*red_colour/255., red_intense * min(visible_channel,1.-vignette_factor));
	}
	
	if( green_intense >0.){
	dist = distance(SCREEN_UV, vec2(0.5,0.5)) - data_field_1*TIME/50.;
	uv = data_field_2* dist * normalize(SCREEN_UV - vec2(0.5,0.5)) + vec2(0.5,0.5);
	uv = mod(uv, vec2(1.,1.));
	visible_channel = 1.- (texture(tex,uv).g);
	colour += vec4(texture(tex,uv).g*green_colour*green_intense/255.0, green_intense*min(visible_channel,1.-vignette_factor));
	}
	
	if (blue_intense > 0.){
	dist = distance(SCREEN_UV, vec2(0.5,0.5)) + sin(data_field_1*TIME/50.);
	uv = data_field_2* dist * normalize(SCREEN_UV - vec2(0.5,0.5)) + vec2(0.5,0.5);
	uv = mod(uv, vec2(1.,1.));
	visible_channel = 1.- (texture(tex,uv).b);
	colour += vec4(blue_intense*texture(tex,uv).b*blue_colour/255.0, blue_intense*min(visible_channel,1.-vignette_factor));
	}
	
	vec3 col1 = coronal_colour_1/255.;
	vec3 col2 = coronal_colour_2/255.;
	vec3 col3 = coronal_colour_3/255.;
	
	if (corona_intense > 0.0){
		if (corona_intense >3.0){corona_intense += TIME;}
		for (int i = 0; i < base_coronal_lines; i++) {
			float seed = random(random_seed*float(i+1)*3248327.);
				//and convert from [0,1] to [0.5,1] since we'll be using it to multiply and 0 ain't fun
			seed = seed/2. + 0.5;
			float randomy = random(seed *  12000.* float(i))/float(base_coronal_lines) + float(i)/float(base_coronal_lines); 
			float y_line = randomy + cos(sin(TIME) + sin(TIME) * abs(SCREEN_UV.x-0.5)*TIME + float(i))/float(base_coronal_lines) + (0.5 - abs(SCREEN_UV.x -0.5)) * sin(TIME*float(i))/float(base_coronal_lines);
			float coronal_segments = data_field_3;
			float approach;
			float segment;
			float double_approach;
			float double_segment;
			if (SCREEN_UV.x > 0.5){
			approach = 1.-fract(SCREEN_UV.x * coronal_segments - TIME);
			segment = floor(SCREEN_UV.x * coronal_segments- TIME);
			} else{
			approach = fract(SCREEN_UV.x * coronal_segments + TIME);
			segment = floor(SCREEN_UV.x * coronal_segments + TIME);
			}
			if (SCREEN_UV.x > 0.5){
			double_approach = 1.-fract(SCREEN_UV.x * coronal_segments * coronal_segments - TIME);
			double_segment = floor(SCREEN_UV.x * coronal_segments * coronal_segments- TIME);
			} else{
			double_approach = fract(SCREEN_UV.x * coronal_segments * coronal_segments + TIME);
			double_segment = floor(SCREEN_UV.x * coronal_segments * coronal_segments + TIME);
			}
			
			
			float segment_y; 
			if (mod(segment, 2.) < 1.0){
			segment_y = y_line + spread_factor * pow(approach,2.0);
			} else{
			segment_y = y_line - spread_factor * pow(approach,2.0);
			}
			
			float double_segment_y;
			if (mod(double_segment, 2.) < 1.0){
			double_segment_y = segment_y + spread_factor * pow(double_approach,2.0);
			} else{
			double_segment_y = segment_y - spread_factor * pow(double_approach,2.0);
			}
			
			float compare = min(abs(SCREEN_UV.y- y_line),abs(SCREEN_UV.y - segment_y)/ (1.-approach));
			compare = min(compare, abs(SCREEN_UV.y - double_segment_y)/(1.-approach));
			
			float corona_intense2 = mod(corona_intense,3.);
			if ( compare < line_thickness){
			corona_intense2 -= (abs(SCREEN_UV.y- y_line))/line_thickness;
			vec3 mix1 = mix(col1, col2, clamp(corona_intense2, 0.0,1.0));
			vec3 mix2 = mix(mix1, col3, clamp(corona_intense2 -1., 0.0,1.0));
			vec3 mix3 = mix(mix2, col1, clamp(corona_intense2 -2., 0.0,1.0));
			colour += vec4(mix3, 1.-vignette_factor);
			}
			
		}
	}
	
	COLOR = colour;
	}
