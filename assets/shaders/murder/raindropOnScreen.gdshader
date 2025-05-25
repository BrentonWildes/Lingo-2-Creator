shader_type canvas_item;
uniform float intensity = 1;
uniform float data_field_1 = 11.5;
uniform bool deflection_is_data_1 = true;
uniform float data_field_2 = 25.;
uniform bool max_drops_is_data_2 = true;
uniform float data_field_3 = 0.35;
uniform bool dry_speed_is_data_3 = true;
uniform float max_size = 40.;
uniform float vignette_intensity = 1;
uniform sampler2D vignette;
uniform sampler2D peek: hint_screen_texture;
uniform float random_seed = 1.;

#include "res://assets/libraries/murder/random.gdshaderinc"

void fragment() {
	vec2 uv = SCREEN_UV;
	//int number = int(float(max_waves) * intensity);
	float vignette_factor = mix(0.0, texture(vignette, UV).w, vignette_intensity);
	
	COLOR = vec4(0,0,0,0);
	float alpha = 0.;
	
	float seed;
	float minx;
	float miny;
	float seed_of_min;
	float dist = 5.0;
	float lifetime;

	for (int i = 0; i < int(data_field_2); i++) {
		seed = random(random_seed*(float(i+1)+ floor(TIME*intensity*20.)));
		vec2 random = random1Dto2D(seed);
		if (distance(random,uv) < dist){
			seed_of_min = seed;
			dist = distance(random,uv);
			minx = random.x;
			miny = random.y;
			lifetime = float(i);
		}
	}
	
	if (distance(uv, vec2(minx,miny)) < max_size/500. || (distance(uv.y, miny)/2.0 + distance(uv.x,minx) < max_size/500. && uv.y - miny < 0.)){
		vec2 dist = uv - vec2(minx,miny);
		uv += (1.-vignette_factor) * dist * data_field_1/ ((data_field_2-lifetime)*data_field_3);
		NORMAL = normalize(vec3(dist, 0.05));
		COLOR = vec4(texture(peek,uv).rgb, 1.-length(dist)/(max_size/125.));
		}

	}
