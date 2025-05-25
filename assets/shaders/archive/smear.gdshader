shader_type spatial;

uniform sampler2D noise;
uniform mat4 lag_transform;

void vertex(){
	// a parameter determining magnitude of the displacement
	float t = pow(texture(noise, UV * 5.0).x, 6.5) * 2.0;
	
	// linearly interpolate between the current transform and the laggy transform in world space
	MODELVIEW_MATRIX = MODEL_MATRIX + (lag_transform - MODEL_MATRIX)*t;
	
	// puts it into view space
	MODELVIEW_MATRIX = VIEW_MATRIX * MODELVIEW_MATRIX;
}