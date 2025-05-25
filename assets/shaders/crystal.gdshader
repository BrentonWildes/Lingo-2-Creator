shader_type canvas_item;

uniform float angle = 45;
uniform float pos_multiplier = 10.0;
uniform float alpha_clamp = 0.1;
uniform float edge_multiplier = 2.0;
uniform float distance_multiplier = 10.0;

uniform vec4 color_start = vec4(0.75, 0.75, 0.75, 1.0);
uniform vec4 color_end = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    float aspect = (1.0 / SCREEN_PIXEL_SIZE).y / (1.0 / SCREEN_PIXEL_SIZE).x;

    vec2 uv = FRAGCOORD.xy.xy / (1.0 / SCREEN_PIXEL_SIZE).x - vec2(0.25, 0.25 * aspect);

    float sin_angle = sin(radians(angle));
    float cos_angle = cos(radians(angle));

    uv = vec2(uv.x * cos_angle - uv.y * sin_angle, uv.x * sin_angle + uv.y * cos_angle) + vec2(0.15, 0.25 * aspect);
    uv.y += 0.5 * (1.0 - aspect);

    vec2 repetition = fract(pos_multiplier * uv);
    float dist = 0.25 * min(min(repetition.x, 1.0 - repetition.x), min(repetition.y, 1.0 - repetition.y));
    float square_distance = length((floor(pos_multiplier * uv) + vec2(0.5)) - vec2(5.0));

    float edge = sin(TIME - square_distance * 0.5) * 0.5 + 0.5;
    edge = (TIME - square_distance * 0.5) * 0.5;
    edge = edge_multiplier * fract(edge * 0.25);

	float value = fract(dist * distance_multiplier);
    value = mix(value, 1.0 - value, step(1.0, edge));
    edge = pow(abs(1.0 - edge), 2.0);
    value = smoothstep(edge - 0.10, edge, 0.90 * value);
    value += square_distance * 0.15;

    COLOR = mix(color_start, color_end, value);
    COLOR.a = alpha_clamp * clamp(value, 0.0, 1.0);
}