shader_type canvas_item;
render_mode unshaded;
uniform sampler2D sim_tex;
uniform vec2 col;
uniform float phase = 0.2;
uniform float lifetime = 1000;
uniform int deltaUV = 3;
uniform float clamping_constant = 0.01;
uniform float cursor_size = 0.025;
uniform float collision_impact = 1.0;


vec4 displacement(sampler2D inputtexture, float dx, float dy, vec2 uv){
	float v1 = texture(inputtexture, uv - vec2(dx,0)).r;
	float v2 = texture(inputtexture, uv + vec2(dx,0)).r;
	float v3 = texture(inputtexture, uv - vec2(0,dy)).r;
	float v4 = texture(inputtexture, uv + vec2(0,dy)).r;
	return vec4(v1,v2,v3,v4);
}

void fragment() {
	vec3 c = texture(sim_tex, SCREEN_UV).rgb;
	float damping = 1.- 1.0/lifetime;
	float p = damping * (2.0 * c.r -c.g + phase * -4.0 * c.r); 
	
	float sizey = 1.0 / 1000.0;
	float sizex = 1.0 / 1000.0;

	vec4 v = displacement(sim_tex, sizex, sizey, SCREEN_UV);
	//These allow us to add arbitrary amounts of distance, but normalize all the additions to 1
	//So our wave neither fades faster or slower as a result of deltaUV
	float divisor = pow(float(deltaUV),2) + float((deltaUV)*(deltaUV+1)/2);
	float summand = float(2*(deltaUV));
	p += phase * (v.x + v.y + v.z + v.w) * damping * summand / divisor;
	
	for (int i = 1; i < deltaUV; i++) {
		sizey = 1.0 / 1000.0 * float(i+1);
		sizex = 1.0 / 1000.0 * float(i+1);
		v = displacement(sim_tex, sizex, sizey, SCREEN_UV); 
		p += phase * (v.x + v.y + v.z + v.w) * damping * (summand - float(i+1)) / divisor;
	}
	

	float prevCol = texture(sim_tex, SCREEN_UV).b;
	float curCol;

	curCol = 0.0; 
	if (distance(SCREEN_UV, col) < cursor_size){curCol = sqrt(distance(SCREEN_UV, col));}
	
	if (curCol > 0. && prevCol < 0.0001) {
		p += curCol * collision_impact;
	}
	if (prevCol > 0.0 && curCol < 0.0001) {
		p -= prevCol * collision_impact;
	}
	
	p = clamp(p, 0.0, 1.0);
	
	if (abs(p) < clamping_constant){
		p *= 0.75;
	}
	
	COLOR = vec4(p, c.r, curCol, 1);
}