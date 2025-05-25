shader_type canvas_item;
uniform sampler2D myalbedo;
render_mode unshaded;

void fragment() {
	COLOR = texture(myalbedo, SCREEN_UV);
	}