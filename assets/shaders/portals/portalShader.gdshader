shader_type spatial;
uniform sampler2D myalbedo: source_color;
uniform sampler2D simdata: hint_default_black;
uniform bool ripple_shader = false;
render_mode unshaded;


uniform float reflection_strength = 0.1;
uniform int normal_sampler_spread = 1;
uniform float normal_strength = 20.0;

vec4 displacement(sampler2D inputtexture, float dx, float dy, vec2 uv){
	float v1 = texture(inputtexture, uv + vec2(dx,0)).y;
	float v2 = texture(inputtexture, uv + vec2(-dx,0)).y;
	float v3 = texture(inputtexture, uv + vec2(0,dy)).y;
	float v4 = texture(inputtexture, uv + vec2(0,-dy)).y;
	return vec4(v1,v2,v3,v4);
}

void fragment() {
	if (ripple_shader){
	//The auto-sizing code doesn't work on viewport textures, apparently
	//ivec2 size = textureSize(simdata,1);
	//float sizex = 2.0/float(size.x);
	//float sizey = 2.0/float(size.y);
	float sizex = 1.0/1000.;
	float sizey = 1.0/1000.;
	
	float divisor = float((2*normal_sampler_spread)*(2*normal_sampler_spread+1)/2) -float((normal_sampler_spread)*(normal_sampler_spread+1)/2);
	float summand = float(2*(normal_sampler_spread));
	vec4 v = vec4(0,0,0,0);
	for (int i = 0; i < normal_sampler_spread; i++) {
		sizey = 1.0 / 1000.0 * float(i+1);
		sizex = 1.0 / 1000.0 * float(i+1);
		vec4 p = displacement(simdata, sizex, sizey, UV); 
		v += p * (summand - float(i+1)) / divisor;
	}
	
	float strength = 1.0/normal_strength;
	vec3 normal = normalize(vec3(v.x - v.y, v.z - v.w, strength));
	
	NORMAL = normal;
	SPECULAR = normal.z;
	ROUGHNESS =1.-normal.z;

	vec2 uv = SCREEN_UV + reflection_strength * normal.xy;
	vec3 colour = texture(myalbedo, uv).xyz;
	colour += vec3(1,1,1) * (normal.x+normal.y);
	ALBEDO = colour;
	//this breaks the shadows
	ALPHA = 1.0;
	}
	else{ ALBEDO = texture(myalbedo, SCREEN_UV).xyz;
	//this breaks the shadows
	ALPHA = 1.0;
	}
	
}