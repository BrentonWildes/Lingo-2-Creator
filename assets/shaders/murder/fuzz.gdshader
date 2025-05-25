shader_type canvas_item;
uniform float intensity = 1;
uniform float data_field_1 = 1;
uniform bool speed_is_data_1 = true;
uniform vec3 colour = vec3(0,0,1);
uniform float data_field_2 = 0.25;
uniform bool colour_variation_is_data_2 = true;
uniform float data_field_3 = 1.;
uniform bool square_multiplier_is_data_3 = true;
uniform vec2 number_of_squares = vec2(192,108);
uniform float vignette_intensity = 1;
uniform sampler2D vignette;

void fragment() {
	float seed_x = floor(UV.x*number_of_squares.x*data_field_3) - floor(0.5*number_of_squares.x*data_field_3);
	float seed_y = floor(UV.y*number_of_squares.y*data_field_3) - floor(0.5*number_of_squares.y*data_field_3);
	if (abs(seed_x) < 0.001){seed_x = 1000.;}
	if (abs(seed_y) < 0.001){seed_y = 1000.;}

	float seed = seed_x * seed_y;
	float time = floor(mod(TIME, 1000.)*data_field_1)/(1000.*data_field_1);
	float random = fract(abs(sin(seed * time * 100000.)));
	vec3 variation = vec3(fract(abs(sin(seed*time * 80000.))),fract(abs(sin(seed*time * 110000.))), fract(abs(sin(seed*time * 120000.))));
	variation = mix(vec3(1.0,1.0,1.0), variation, data_field_2);

	float vignette_factor = mix(0.0, texture(vignette, UV).w, vignette_intensity);

	vec4 colour_output = vec4(1.- variation.x*random*(1.- colour.x/255.), 1.-variation.y*random*(1.-colour.y/255.), 1.-variation.z*random*(1.0-colour.z/255.), (1.-vignette_factor)*clamp((intensity*random),0.,1.0));


	COLOR = colour_output;
	}
