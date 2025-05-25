shader_type sky;
render_mode use_quarter_res_pass, use_debanding;
group_uniforms atmosphere;
uniform float atmosphere_density = 1;
uniform float planet_radius_to_atmosphere_radius = 64.0;
uniform float atmosphere_ozone_richness = 1.0;
group_uniforms sun;
uniform vec3 sun_pos;
uniform vec3 sun_color:source_color ;
uniform float sun_power = 5;
uniform float sun_size = 1;
group_uniforms sun2;
uniform vec3 sun2_pos;
uniform vec3 sun2_color:source_color;
uniform float sun2_power = 3;
uniform float sun2_size = 0.75;
group_uniforms moon;
uniform vec3 moon_pos;
uniform vec3 moon_color:source_color;
uniform float moon_power = 5;
uniform float moon_size = 0.5;
uniform vec3 moon_axis;
uniform vec3 moon_start;
uniform sampler2D moon_image: hint_default_white;
group_uniforms clouds;
uniform sampler2D cloud_noise;
uniform sampler2D cloud_noise_2;
uniform sampler2D cloud_noise_3;
uniform float cloud_density;
uniform float cloud_amount;
uniform float cloud_horizon_density;
uniform float cloud_horizon_amount;
uniform float cloud_horizon_height;
uniform float cloud_distance;
uniform vec2 cloud_direction;
uniform vec2 cloud_direction2;
uniform vec2 cloud_direction3;
uniform float cloud_scale;
uniform float cloud_scale2;
uniform float cloud_scale3;
uniform float cloud_speed;



group_uniforms ground;
uniform vec3 ground_horizon_color: source_color;
uniform vec3 ground_bottom_color: source_color;
uniform float ground_curve;
uniform float ground_energy;
uniform float ground_reflectivity_curve;
uniform bool enable_ground = true;
group_uniforms stars;
uniform sampler2D star_image;
uniform vec3 star_pos;
uniform float star_brightness = 0.05;
uniform float star_twinkle = 1;
uniform float star_color_variation = 0.5;
uniform float star_scale = 10.;

#include "res://assets/libraries/murder/random.gdshaderinc"
#include "res://assets/libraries/murder/HSV_RGB_converters.gdshaderinc"

vec3 absorb_light(vec3 color, vec3 direction){
	//earth-like ozone absorption is 1% of green light, .1% of blue light, and 0.01% of red light
	//Most of earth's ozone is in a high layer with approximate concentration 15 ppm.
	//So you can go *quite large* in terms of ozone richness ratio to earth's
	float base_green_absorb = pow(1. - (0.01 * atmosphere_density), atmosphere_ozone_richness);
	float base_blue_absorb = pow(1. - (0.001 * atmosphere_density), atmosphere_ozone_richness);

	float max_green_absorb = pow(base_green_absorb, planet_radius_to_atmosphere_radius);
	float max_blue_absorb = pow(base_blue_absorb, planet_radius_to_atmosphere_radius);
	float horizon_nearness = pow(clamp(1. - direction.y, 0, 1.0), 2.0);

	float green_absorb = clamp(mix(base_green_absorb, max_green_absorb, horizon_nearness),0,1.0);
	float blue_absorb = clamp(mix(base_blue_absorb, max_blue_absorb, horizon_nearness),0,1.0);

	vec3 ret_color = color;
	ret_color.g *= green_absorb;
	ret_color.b *= blue_absorb;

	ret_color = max(ret_color, 0.);

	return ret_color;
}

vec3 scatter_light(vec3 color, vec3 pos){
	//earth-like rayleigh scattering is 5% of red, 10% of green, and 25% of blue light from direct sunlight at noon
	float base_red_scatter = 1.- 0.05 * atmosphere_density;
	float base_green_scatter = 1.- 0.1 * atmosphere_density;
	float base_blue_scatter = 1.- 0.25 * atmosphere_density;

	//Technically these are exponential equations, but we won't gain much from that, so some of these are just linear approximations
	float max_red_scatter = pow(base_red_scatter, planet_radius_to_atmosphere_radius/5.5);
	float max_green_scatter = pow(base_green_scatter, planet_radius_to_atmosphere_radius/5.5);
	float max_blue_scatter = pow(base_blue_scatter, planet_radius_to_atmosphere_radius/5.5);

	float horizon_nearness = pow(clamp(1. - pos.y, 0, 1.0), 2.0);

	float red_scatter = clamp(mix(base_red_scatter, max_red_scatter, horizon_nearness),0,1.0);
	float green_scatter = clamp(mix(base_green_scatter, max_green_scatter, horizon_nearness),0,1.0);
	float blue_scatter = clamp(mix(base_blue_scatter, max_blue_scatter, horizon_nearness),0,1.0);

	vec3 ret_color = color;
	ret_color.r *= red_scatter;
	ret_color.g *= green_scatter;
	ret_color.b *= blue_scatter;

	return ret_color;
	}


vec3 get_shine_colour(vec3 colour, vec3 direction, vec3 body_pos){
	vec3 direct_colour = colour - scatter_light(colour,body_pos);
	vec3 horizon = scatter_light(direct_colour,direction)*5.0;
	horizon = mix(horizon, direct_colour, pow(clamp(body_pos.y-0.2,0,1.0),2.0));
	horizon = mix(direct_colour, horizon, pow(dot(direction, body_pos),2.0));
	vec3 potent = rgb2hsv(horizon);
	potent.y = 1.0;
	potent = hsv2rgb(potent);
	horizon = mix(potent, horizon, pow(clamp(body_pos.y-0.2,0,1.0),2.0));
	return absorb_light(horizon, direction);
	}

vec2 sphere_uv(vec3 input, vec3 axis, vec3 locate){
	//for stability, we want the poles to be the moon's axis, NOT universal up and down.
	//So we don't want the built-in sky coords
	float u = atan(dot(input,locate),dot(input, cross(locate,axis)));
	float v = asin(dot(input, axis));
	u = 0.5 + u/(2.0*PI);
	v = 0.5 + v/(PI);
	return vec2(u,v);
	}


vec4 get_star_field(vec3 direction){
	vec2 uv = sphere_uv(direction, vec3(1.0,0.0,0), star_pos);
	vec4 color =texture(star_image,uv*star_scale);
	vec2 cell = vec2(floor(uv.x * 50.0)/50.0, floor(uv.y * 50.0)/50.0);
	float mix_strength = (color.r+color.b+color.g)/3.0 * color.a;

	color.rgb += mix(0.0, mix(0.0, random2Dto1D(floor(9.0*TIME)*cell), star_twinkle), mix_strength);
	uv = 2.0*abs(uv-0.5);
	color.rgb *= mix(vec3(1.0,1.0,1.0), vec3(random2Dto2D(cell), random2Dto1D(cell*5.71828)),star_color_variation * mix_strength);
	color *= star_brightness;
	//Scale the brightness by the brightness of celestial bodies
	color /= max(0.0, sun_power) + max(0.0,sun2_power) + max(0.0, moon_power) + 1.0;

	return color;
	}

vec3 get_sky_color(vec3 direction){
	vec3 color = vec3(0,0,0);
	vec4 stars = get_star_field(direction);

	color = mix(vec3(0,0,0), stars.rgb, stars.a);

	float sun_dot = max(dot(sun_pos,direction),0.0);
	float sun2_dot = max(dot(sun2_pos,direction),0.0);
	float moon_dot = max(dot(moon_pos,direction),0.0);
	vec3 direct = absorb_light(scatter_light(sun_color,sun_pos), direction);
	//this is the actual suns in the sky
	color += 4.0 * direct * sun_power * pow(sun_dot, pow(sun_pos.y*2.0 + 1.0, 2.0)* 900./sun_size);
	direct = absorb_light(scatter_light(sun2_color,sun2_pos),direction);
	color += 4.0 * direct * sun2_power * pow(sun2_dot, pow(sun2_pos.y*2.0 + 1.0, 2.0) * 900./sun2_size);

	if (moon_dot > 1.- moon_size/1000.){
		vec2 centre = sphere_uv(moon_pos, moon_axis, moon_start);
		vec2 pos = sphere_uv(direction, moon_axis, moon_start);
		pos -= centre;
		pos.x /= acos(1.-moon_size/15000.);
		pos.y /= acos(1.-moon_size/3750.);
		color = 0.2* moon_power * pow(moon_dot, 900.0/moon_size) * texture(moon_image, pos).xyz;
		}
	color = clamp(color, vec3(0,0,0), vec3(1.0,1.0,1.0));

	float moon_sun_dot = 1. - max(dot(sun_pos,moon_pos) - (1. - moon_size/1000.),0.0)/(moon_size/1000.);
	float moon_sun2_dot = 1. - max(dot(sun2_pos,moon_pos) - (1. - moon_size/1000.),0.0)/(moon_size/1000.);

	vec3 sun_shine = get_shine_colour(sun_color, direction, sun_pos);
	vec3 sun2_shine = get_shine_colour(sun2_color, direction, sun2_pos);
	vec3 moon_shine = get_shine_colour(moon_color, direction, moon_pos);
	//much more light will be scattered with a thicker atmosphere.
	//so we need to divide the power by the extra area covered
	//this is the impact these bodies have on the sky's general colour & brightness.
	color += moon_sun_dot * 1.0/sqrt(atmosphere_density) * sun_shine * clamp(pow((1.0+ dot(sun_pos,direction))/2.0,2.1),max(sun_pos.y,0),1.0) * sun_power / 10.0;
	color += moon_sun2_dot * 1.0/sqrt(atmosphere_density) *sun2_shine* clamp(pow((1.0+ dot(sun2_pos,direction))/2.0,3.0), max(0,sun2_pos.y),1.0) * sun2_power / 10.0;
	color += 1.0/sqrt(atmosphere_density) *moon_shine* clamp(pow((1.0+ dot(moon_pos,direction))/2.0,5.0), max(0,moon_pos.y),1.0) * moon_power / 10.0;
	//these are the immediate body's auras
	color += moon_sun_dot * 0.5 * sun_shine * sun_power * pow(sun_dot, 150./sun_size);
	color += moon_sun2_dot * 0.5 * sun2_shine * sun2_power * pow(sun2_dot, 150./sun2_size);
	color += 0.5 * moon_shine * moon_power * pow(moon_dot, 150./moon_size);


	return color;
}

vec4 screen(vec4 base, vec4 blend){
	vec4 result;
	result.r = 1.0 - (1.0 - base.r*base.a) * (1.0 - blend.r*blend.a);
	result.g = 1.0 - (1.0 - base.g*base.a) * (1.0 - blend.g*blend.a);
	result.b = 1.0 - (1.0 - base.b*base.a) * (1.0 - blend.b*blend.a);
	result.a = max(base.a, blend.a);
	return result;
}

vec4 generate_clouds(vec3 direction){
	vec2 uv = direction.xz/direction.y;
	vec4 cloud_fine = texture(cloud_noise, uv/cloud_scale+ cloud_direction* cloud_speed * TIME/1000.);
	vec4 cloud_rough = texture(cloud_noise_2, uv/cloud_scale2+ cloud_direction2* cloud_speed * TIME/1000.);
	vec4 cloud_rough2 = texture(cloud_noise_3, uv/cloud_scale3+ cloud_direction3* cloud_speed * TIME/1000.);

	cloud_rough = max(vec4(0.0,0.0,0.0,0.0),cloud_rough-cloud_rough2);
	cloud_rough.a = max(cloud_rough.a - 1.0 + cloud_amount, 0.0);
	cloud_fine.a = max(cloud_fine.a - 1.0 + cloud_density,0.0);
	cloud_rough.a = max(0.0, smoothstep(0.0, cloud_rough.a, direction.y + cloud_distance - 1.0));
	cloud_rough.a = mix(0,cloud_rough.a,cloud_fine.a);
	cloud_rough = clamp(cloud_rough, 0.0, 1.0);
	return cloud_rough;
}

vec4 generate_horizon_clouds(vec3 direction){
	vec2 uv = vec2(atan(direction.x, direction.z),direction.y);
	uv.x = min(uv.x, -uv.x);

	vec4 cloud_fine = texture(cloud_noise, uv/cloud_scale+ vec2(1,0)*cloud_direction.x* cloud_speed * TIME/1000.);
	vec4 cloud_rough = texture(cloud_noise_2, uv/cloud_scale2+vec2(-1,0)* cloud_direction2.x* cloud_speed * TIME/1000.);
	vec4 cloud_rough2 = texture(cloud_noise_3, uv/cloud_scale3+ vec2(1,0)*cloud_direction3.x* cloud_speed * TIME/1000.);
	cloud_rough = max(vec4(0,0,0,0), cloud_rough-cloud_rough2);
	cloud_rough.a = max(cloud_rough.a - 1.0 + cloud_horizon_amount, 0.0);
	cloud_fine.a = max(cloud_fine.a - 1.0 + cloud_horizon_density,0.0);
	cloud_rough.a = smoothstep(cloud_rough.a, 0.0, direction.y-2.0*cloud_horizon_height + 1.0);
	cloud_rough.a = mix(0,cloud_rough.a,cloud_fine.a);
	cloud_rough = clamp(cloud_rough, 0.0,1.0);
	return cloud_rough;
}


vec3 generate_ground_plane(vec3 direction){
	float c = (acos(clamp(direction.y, -1.0, 1.0)) - PI/2.0)/(PI/2.0);
	vec3 ground = mix(ground_horizon_color.rgb, ground_bottom_color.rgb, clamp(1.0 - pow(1.0 - c, 1.0 / ground_curve), 0.0, 1.0));
	//adjust brightness of ground for reflected light
	ground *= ground_energy + max(0.0,pow((sun_power/16.+sun2_power/16.+moon_power/16.)/3., ground_reflectivity_curve));

	return ground;
}


void sky() {
    if (AT_CUBEMAP_PASS) {
		//a not-true-black to allow ambient light regardless
        COLOR = vec3(0.01,0.01,0.01);
    } else if (AT_QUARTER_RES_PASS) {
        // Run cloud calculation for 1/4 of the pixels
        vec4 color = generate_clouds(EYEDIR);
		vec4 color2 = generate_horizon_clouds(EYEDIR);
		color = screen(color, color2);
		COLOR = color.rgb;
        ALPHA = color.a;
    }else {
        vec3 color = get_sky_color(EYEDIR);
		vec3 ground = generate_ground_plane(EYEDIR);
        color = mix(color, QUARTER_RES_COLOR.rgb, QUARTER_RES_COLOR.a);
		if (enable_ground){
			color = mix(ground, color, step(0.0, EYEDIR.y));
		}
		COLOR = color;

    }
}
