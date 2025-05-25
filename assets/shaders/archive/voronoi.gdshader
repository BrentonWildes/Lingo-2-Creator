/*
	ボロノイ神経風 背景シェーダー by あるる（きのもと 結衣） @arlez80
	Voronoi Synapse-ish Background Shader by Yui Kinomoto @arlez80

	MIT License
*/
shader_type canvas_item;

uniform vec2 pixel_size = vec2( 0.001, 0.001 );

uniform float voronoi_scale = 20.0;
uniform float voronoi_seed = 0.0;

uniform float electric_scale = 20.0;
uniform float electric_speed = 1.0;
uniform float electric_power = 3.0;

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
	vec2 v = uv * voronoi_scale + vec2( voronoi_seed, voronoi_seed );
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

			min_p = mix( min_p, ( v + diff - v_fract ) / voronoi_scale, float( d < min_dist ) );
			min_dist = min( min_dist, d );
		}
	}

	return min_p;
}

vec2 sobel_coord_conv( vec2 v, int x, int y )
{
	return v + vec2( float( x-1 ), float( y-1 ) ) * pixel_size;
}

float sobel( vec2 uv )
{
	vec2 sobel[9] = {
		voronoi( sobel_coord_conv( uv, 0, 0 ) )
	,	voronoi( sobel_coord_conv( uv, 1, 0 ) )
	,	voronoi( sobel_coord_conv( uv, 2, 0 ) )
	,	voronoi( sobel_coord_conv( uv, 0, 1 ) )
	,	vec2( 0.0 )	// 未使用
	,	voronoi( sobel_coord_conv( uv, 2, 1 ) )
	,	voronoi( sobel_coord_conv( uv, 0, 2 ) )
	,	voronoi( sobel_coord_conv( uv, 1, 2 ) )
	,	voronoi( sobel_coord_conv( uv, 2, 2 ) )
	};
	vec2 sobel_src_x = (
		sobel[0] * -1.0
	+	sobel[3] * -2.0
	+	sobel[6] * -1.0
	+	sobel[2] * 1.0
	+	sobel[5] * 2.0
	+	sobel[8] * 1.0
	);
	vec2 sobel_src_y = (
		sobel[0] * -1.0
	+	sobel[1] * -2.0
	+	sobel[2] * -1.0
	+	sobel[6] * 1.0
	+	sobel[7] * 2.0
	+	sobel[8] * 1.0
	);

	return length( sqrt( sobel_src_x * sobel_src_x + sobel_src_y * sobel_src_y ) );
}

float electric( vec2 uv )
{
	return clamp( sobel( uv ) * mod( ( uv.x - uv.y ) * electric_scale / 3.0 - TIME * electric_speed, 1.0 ) * electric_power, 0.0, 1.0 );
}

void fragment( )
{
	COLOR = vec4( vec3( electric( UV + TIME * 0.1 ), electric( UV * 0.5 + TIME * 0.1 ), electric( UV * 0.25 + TIME * 0.1 ) ), 1.0 );
}