/*
	ガードエフェクト by あるる（きのもと 結衣）
	Guard Effect by Yui Kinomoto @arlez80

	MIT License
*/
shader_type spatial;
render_mode blend_mix, cull_back, diffuse_burley, specular_schlick_ggx, unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float radius : hint_range( 0.0, 1.0 ) = 0.5;
uniform vec4 color : source_color;
uniform float scale = 32.0;
uniform float alpha : hint_range( 0.0, 1.0 ) = 1.0;
uniform float power = 3.0;

vec2 random( vec2 pos )
{ 
	return fract(
		sin(
			vec2(
				dot(pos, vec2(12.9898,78.233))
			,	dot(pos, vec2(-148.998,-65.233))
			)
		) * 43758.5453
	);
}

vec2 voronoi( vec2 uv )
{
	
	vec2 v = uv * scale;
	vec2 v_floor = floor( v );
	vec2 v_fract = fract( v );

	vec2 min_p = vec2( 0.0, 0.0 );
	float min_dist = 2.0;

	for( int y = -1; y <= 1; y ++ ) {
		for( int x = -1; x <= 1; x ++ ) {
			vec2 n = vec2( float( x ), float( y ) );
			vec2 p = random( v_floor + n );
			vec2 diff = p + n;
			float d = distance( v_fract, diff );

			min_p = mix( min_p, ( v + diff - v_fract ) / scale, float( d < min_dist ) );
			min_dist = min( min_dist, d );
		}
	}

	return min_p;
}

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec2 conv_uv = voronoi( UV );
	float f = clamp( 1.0 - abs( distance( conv_uv, vec2( 0.5, 0.5 ) ) - radius ) * power, 0.0, 1.0 );

	ALBEDO = mix( textureLod( SCREEN_TEXTURE, conv_uv, 0.0 ).rgb, color.rgb, color.a );
	ALPHA = f * alpha;
}