extends WorldEnvironment

#Some things had to be defined in this script:
#- moving celestial bodies, so that the sky renderer isn't forced to update every frame and the update rate can be controlled
#- and controlling the directional lights in sync with the celestial bodies
#So to avoid confusion over what parameters are modified where, I exposed them all in this script. 

#For convenience, I've also provided a quick "change sky shader parameter" function for calling from other scripts if so desired.
#But do note that good practice would be also changing the property on this node.
#If you end up using that a lot, consider making setgets for each property on this node that also update the shader 
#Note that everytime you change a uniform on a sky shader, it will FORCE the sky AND radiance map to update.
#So consider not doing that too often.

#I didn't realize till late that directional light's attributes could be accessed into sky shaders with LIGHT0, LIGHT1, etc.
#Would've changed my code slightly.

#To freeze time, set time resolution to 0
#To set time to a given value, set input_set_time
#These can work together.

var time_of_day:float = 0 : set = toggle_time_flow
@export var input_set_time:float : set = set_time

@export var time_resolution_ms = 1000
@export_group("Clouds")
@export var cloud_speed = 30;
@export_range(0,1) var cloud_density:float = 0.1;
@export_range(0,1) var cloud_amount:float = 0.1;
@export_range(0,1) var cloud_horizon_density:float = 0.1;
@export_range(0,1) var cloud_horizon_amount:float = 0.1;
@export_range(0,1) var cloud_distance:float = 0.5;
@export_range(0,1) var cloud_horizon_height:float = 0.5;
@export var cloud_direction:Vector2 = Vector2(1,0);
@export var cloud_direction2:Vector2 = Vector2(sqrt(2)/2, sqrt(2)/2);
@export var cloud_direction3:Vector2 = Vector2(-sqrt(2)/2, sqrt(2)/2);
@export var cloud_scale:float = 2.0
@export var cloud_scale2:float = 8.0
@export var cloud_scale3:float = 4.0
@export var cloud_noise:Texture
@export var cloud_noise2:Texture
@export var cloud_noise3:Texture
@export_group("Stars")
@export var star_starting_position:Vector3 = Vector3.UP
@export var star_axis:Vector3 = Vector3.RIGHT
@export var star_image:Texture
@export var star_day_length:float = 60.
@export var star_brightness:float = 0.1;
@export var star_scale:float = 1
@export var star_time_offset:float =0
@export var star_twinkle:float = 1
@export var star_color_variation = 0.5;
@export_group("Sun")
@export var sun_starting_position:Vector3 = Vector3.UP
@export var sun_axis:Vector3 = Vector3.RIGHT
@export var sun_color:Color = Color.YELLOW
@export var sun_day_length:float = 60.
@export var sun_brightness:float = 5;
@export var sun_directional_light_power:float = 1;
@export var sun_size:float = 5
@export var sun_time_offset:float =0

@export_group("Sun2")
@export var sun2_starting_position:Vector3 = Vector3.UP
@export var sun2_axis:Vector3 = Vector3.FORWARD
@export var sun2_color:Color = Color.RED
@export var sun2_day_length:float = 35.
@export var sun2_brightness:float = 5;
@export var sun2_directional_light_power:float = 1;
@export var sun2_size:float = 3
@export var sun2_time_offset:float =0

@export_group("Moon")
@export var moon_starting_position:Vector3 = Vector3.UP
@export var moon_axis:Vector3 = Vector3(sqrt(2.0)/2.0,sqrt(2.0)/2.0,0)
@export var moon_color:Color = Color.SILVER
@export var moon_day_length:float = 160.
@export var moon_brightness:float = 5;
@export var moon_directional_light_power:float = 1;
@export var moon_size:float = 2
@export var moon_time_offset:float =0
@export var moon_texture:Texture
@export_group("Ground")
@export var ground_horizon_color:Color
@export var ground_bottom_color:Color
@export_exp_easing var ground_curve:float
@export var ground_energy:float
@export var enable_ground = true
@export_exp_easing var ground_reflecitivy_curve:float
@export_group("Atmosphere")
@export var atmosphere_density:float = 1;
@export var planet_radius_to_atmosphere_radius:float = 64.0;
@export var atmosphere_ozone_richness:float = 1.0;

var sun_position:Vector3
var sun2_position:Vector3
var moon_position:Vector3
var star_position:Vector3

var sun:DirectionalLight3D
var sun2:DirectionalLight3D
var moon:DirectionalLight3D


#this is duplicated in the sky shader because it is also needed to calculate the colour of sun_shine, which is also direction dependent
func scatter_light(color:Color, pos:Vector3)->Color:
	var horizon_nearness:float = pow(clamp(1.-pos.y,0,1.0),2.0);
	var red_scatter:float = clamp(1. - (0.05 + horizon_nearness * 0.55),0,1);
	var green_scatter:float = clamp(1.- (0.1 + horizon_nearness * 0.95),0,1);
	var blue_scatter:float = clamp(1.- (0.25 + horizon_nearness * 1.25),0,1);
	

	var ret_color:Color = color;
	ret_color.r *= red_scatter;
	ret_color.g *= green_scatter;
	ret_color.b *= blue_scatter;
	return ret_color;
	

func calculate_body_position(daylength:float, daytime:float, axis:Vector3, starting_pos:Vector3, offset:float)->Vector3:
	#time of day from 0 to 2PI
	var time:float = 2.0*PI*fmod(daytime/1000.+offset, daylength)/daylength
	var body_axis:Vector3 = axis.normalized()
	var rotation:Vector3 = starting_pos.rotated(body_axis, time)
	return rotation

func change_sky_shader_parameter(property:String, value)->void:
	self.environment.sky.sky_material.set_shader_parameter(property, value);



func _ready():
	if time_resolution_ms == 0:
		self.set_process(false)
	sun_position = sun_starting_position
	sun2_position = sun2_starting_position
	moon_position = moon_starting_position
	sun = get_node_or_null("Sun")
	moon = get_node_or_null("Moon")
	sun2 = get_node_or_null("Sun2")
	if sun != null:
		if sun_brightness < 0:
			sun.light_negative = true
		sun.light_energy = sun_directional_light_power
		sun.light_color = scatter_light(sun_color, sun_position)
	if sun2 != null:
		if sun2_brightness < 0:
			sun2.light_negative = true
		sun2.light_energy = sun2_directional_light_power
		sun2.light_color = scatter_light(sun2_color, sun2_position)
	if moon != null:
		if moon_brightness < 0:
			moon.light_negative = true
		moon.light_energy = sun_directional_light_power
		moon.light_color = scatter_light(moon_color, moon_position)
	self.environment.sky.sky_material.set_shader_parameter("sun_size", sun_size)
	self.environment.sky.sky_material.set_shader_parameter("moon_size", moon_size)
	self.environment.sky.sky_material.set_shader_parameter("sun2_size", sun2_size)	
	self.environment.sky.sky_material.set_shader_parameter("sun_color", sun_color)	
	self.environment.sky.sky_material.set_shader_parameter("sun2_color", sun2_color)
	self.environment.sky.sky_material.set_shader_parameter("moon_color", moon_color)
	self.environment.sky.sky_material.set_shader_parameter("moon_image", moon_texture)
	self.environment.sky.sky_material.set_shader_parameter("moon_axis", moon_axis)	
	self.environment.sky.sky_material.set_shader_parameter("moon_start", moon_starting_position)		
	self.environment.sky.sky_material.set_shader_parameter("cloud_density", cloud_density)
	self.environment.sky.sky_material.set_shader_parameter("cloud_amount", cloud_amount)
	self.environment.sky.sky_material.set_shader_parameter("cloud_horizon_density", cloud_horizon_density)
	self.environment.sky.sky_material.set_shader_parameter("cloud_horizon_amount", cloud_horizon_amount)
	self.environment.sky.sky_material.set_shader_parameter("cloud_distance", cloud_distance)
	self.environment.sky.sky_material.set_shader_parameter("cloud_horizon_height", cloud_horizon_height)
	self.environment.sky.sky_material.set_shader_parameter("cloud_speed", cloud_speed)	
	self.environment.sky.sky_material.set_shader_parameter("cloud_scale", cloud_scale)	
	self.environment.sky.sky_material.set_shader_parameter("cloud_scale2", cloud_scale2)	
	self.environment.sky.sky_material.set_shader_parameter("cloud_scale3", cloud_scale3)
	self.environment.sky.sky_material.set_shader_parameter("cloud_direction", cloud_direction)
	self.environment.sky.sky_material.set_shader_parameter("cloud_direction2", cloud_direction2)
	self.environment.sky.sky_material.set_shader_parameter("cloud_direction3", cloud_direction3)
	self.environment.sky.sky_material.set_shader_parameter("cloud_noise", cloud_noise)
	self.environment.sky.sky_material.set_shader_parameter("cloud_noise_2", cloud_noise2)
	self.environment.sky.sky_material.set_shader_parameter("cloud_noise_3", cloud_noise3)
	self.environment.sky.sky_material.set_shader_parameter("ground_horizon_color", ground_horizon_color)
	self.environment.sky.sky_material.set_shader_parameter("ground_bottom_color", ground_bottom_color)
	self.environment.sky.sky_material.set_shader_parameter("ground_curve", ground_curve)
	self.environment.sky.sky_material.set_shader_parameter("ground_energy", ground_energy)
	self.environment.sky.sky_material.set_shader_parameter("enable_ground", enable_ground)
	self.environment.sky.sky_material.set_shader_parameter("atmosphere_density", atmosphere_density)
	self.environment.sky.sky_material.set_shader_parameter("planet_radius_to_atmosphere_radius", planet_radius_to_atmosphere_radius)
	self.environment.sky.sky_material.set_shader_parameter("atmosphere_ozone_richness", atmosphere_ozone_richness)
	self.environment.sky.sky_material.set_shader_parameter("star_image", star_image)
	self.environment.sky.sky_material.set_shader_parameter("star_brightness", star_brightness)
	self.environment.sky.sky_material.set_shader_parameter("star_scale", star_scale)
	self.environment.sky.sky_material.set_shader_parameter("star_twinkle", star_twinkle)
	self.environment.sky.sky_material.set_shader_parameter("star_color_variation", star_color_variation)
	
	set_directional_lights()
	set_shader_bodies()

func set_directional_lights():
	#+0.2, or "keep shining for a bit below the horizon". Both so that the upper half doesn't disappear above the horizon level, and also so that the sunshine persists slightly after sunset
	var sun_pow=pow(clamp(sun_directional_light_power * (sun_position.y+0.2),0,1),3.0)
	var sun2_pow=pow(clamp(sun2_directional_light_power * (sun2_position.y+0.2),0,1),3.0)
	var moon_pow=pow(clamp(moon_directional_light_power * (moon_position.y+0.2),0.01,1),3.0)
	if sun: 
		sun.light_color = scatter_light(sun_color, sun_position)
		sun.global_transform.basis = Basis.looking_at(sun_position, sun_axis)
		sun.global_transform.basis.z *= -1
		sun.light_energy = sun_pow
	if sun2: 
		sun2.light_color = scatter_light(sun2_color, sun2_position)
		sun2.global_transform.basis = Basis.looking_at(sun2_position, sun2_axis)
		sun2.global_transform.basis.z *= -1
		sun2.light_energy = sun2_pow
	if moon: 
		moon.light_color = scatter_light(moon_color, moon_position)
		moon.global_transform.basis = Basis.looking_at(moon_position, moon_axis)
		moon.global_transform.basis.z *= -1
		moon.light_energy = moon_pow

func set_shader_bodies():
	self.environment.sky.sky_material.set_shader_parameter("sun_pos", sun_position)
	self.environment.sky.sky_material.set_shader_parameter("sun2_pos", sun2_position)
	self.environment.sky.sky_material.set_shader_parameter("moon_pos", moon_position)
	self.environment.sky.sky_material.set_shader_parameter("star_pos", star_position)
	var sun_pow = sun_brightness * pow(clamp(sun_position.y+0.2,0,1),1.2)
	var sun2_pow = sun2_brightness * pow(clamp(sun2_position.y+0.2,0,1),1.2)
	var moon_pow = moon_brightness * pow(clamp(moon_position.y+0.2,0,1),1.2)
	self.environment.sky.sky_material.set_shader_parameter("sun_power", sun_pow)
	self.environment.sky.sky_material.set_shader_parameter("sun2_power", sun2_pow)
	self.environment.sky.sky_material.set_shader_parameter("moon_power", moon_pow)

func _process(_delta):
	if Time.get_ticks_msec() > time_of_day + time_resolution_ms:
		time_of_day = Time.get_ticks_msec()
		sun_position = calculate_body_position(sun_day_length, time_of_day, sun_axis, sun_starting_position, sun_time_offset)
		sun2_position = calculate_body_position(sun2_day_length, time_of_day, sun2_axis, sun2_starting_position, sun2_time_offset)
		moon_position = calculate_body_position(moon_day_length, time_of_day, moon_axis, moon_starting_position, moon_time_offset)
		star_position = calculate_body_position(star_day_length, time_of_day, star_axis, star_starting_position, star_time_offset)
		set_directional_lights()
		set_shader_bodies()
		
func set_time(value):
	time_of_day = value
	sun_position = calculate_body_position(sun_day_length, time_of_day, sun_axis, sun_starting_position, sun_time_offset)
	sun2_position = calculate_body_position(sun2_day_length, time_of_day, sun2_axis, sun2_starting_position, sun2_time_offset)
	moon_position = calculate_body_position(moon_day_length, time_of_day, moon_axis, moon_starting_position, moon_time_offset)
	set_directional_lights()
	set_shader_bodies()
			
func toggle_time_flow(value):
	time_of_day = value
	if value == 0:
		self.set_process(false)
	else:
		self.set_process(true)
