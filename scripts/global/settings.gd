extends Node

var fields = [
	"sound_effects", #0
	"music", #1
	"sound_effects_volume", #2
	"music_volume", #3
	"autorun", #4
	"invert_y", #5
	"mouse_sensitivity", #6
	"bigger_crosshair", #7
	"fullscreen_mode", #8
	"walk_speed", #9
	"hidden_crosshair", #10
	"show_map_names", #11
	"textures", #12
	"key_forward", #13
	"key_left", #14
	"key_back", #15
	"key_right", #16
	"resolution_scaling", #17
	"potato_mode", #18
]

#audio settings
var sound_effects = true
var music = true
var sound_effects_volume = 100
var music_volume = 100

#gameplay settings
var autorun = false
var invert_y = false
var mouse_sensitivity = 20
var bigger_crosshair = false
var hidden_crosshair = false
var worldport_visible = "default" #always, default, never
var worldport_fades = "never" #always, default, never
var walk_speed = 12
var show_map_names = false
var key_forward = "W"
var key_left = "A"
var key_back = "S"
var key_right = "D"

#graphics settings
var fullscreen_mode = true
var textures = "default"
var texture_options = [ "default", "deusovis_colorblind_pack", "kmills_lingo_textures", "kiribatis_mellow_pack", "custom" ]
var resolution_scaling = 100
var potato_mode = false

var stored_env = null

func _ready():
	var time = 0
	for dir in DirAccess.get_directories_at("user://users/"):
		var filename = "user://users/" + dir + "/" + global.universe + "/settings/settings.save"
		var modded = FileAccess.get_modified_time( filename )
		if ( modded > time ):
			time = modded
			global.user = dir
	loadSettings()
	applySettings()

func applySettings():
	get_viewport().scaling_3d_scale = resolution_scaling / 100.0
	
	# Audio Settings
	AudioServer.set_bus_volume_db( AudioServer.get_bus_index("Music"), linear_to_db(music_volume/100.0) )
	AudioServer.set_bus_volume_db( AudioServer.get_bus_index("SFX"), linear_to_db(sound_effects_volume/100.0) )
	
	if (music):
		if (!musicPlayer.get_playback_position() > 0):
			musicPlayer.play()
	else:
		if (musicPlayer.get_playback_position() > 0):
			musicPlayer.stop()
	
	# Gameplay Settings
	var player = get_node_or_null("/root/scene/player")
	if ( player != null ):
		player.mouse_sensitivity = float(mouse_sensitivity) / float(10000)
		player.walk_speed = walk_speed
		player.run_speed = walk_speed + 12
		if (settings.hidden_crosshair):
			player.get_node("pivot/camera/crosshair").hide()
			player.get_node("pivot/camera/bigger_crosshair").hide()
		elif (settings.bigger_crosshair):
			player.get_node("pivot/camera/crosshair").hide()
			player.get_node("pivot/camera/bigger_crosshair").show()
		else:
			player.get_node("pivot/camera/crosshair").show()
			player.get_node("pivot/camera/bigger_crosshair").hide()
		load_user_textures()
	mapKeys()
	mapArrowKeys()
	potatoMode()
	
	# Graphics Settings
	if (settings.fullscreen_mode):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func potatoMode():
	var fast_env = load("res://assets/environments/fast.tres")
	var env = get_node_or_null("/root/scene/WorldEnvironment")
	if ( env != null ):
		if env.environment != fast_env:
			stored_env = env.environment
	var inspired_shader = get_node_or_null("/root/scene/inspired")
	if potato_mode:
		Engine.max_fps = 30
		if ( env != null ):
			env.environment = fast_env
		if ( inspired_shader != null ):
			inspired_shader.hide()
		get_viewport().set_msaa_3d(Viewport.MSAA_DISABLED)
	else:
		Engine.max_fps = 60
		if ( env != null ):
			env.environment = stored_env
		if ( inspired_shader != null ):
			inspired_shader.show()
		get_viewport().set_msaa_3d(Viewport.MSAA_4X)

func initSettingsMenu( nodepath ):
	var container = get_node( nodepath )
	
	# Audio Settings
	container.get_node("Audio/sound_effects").button_pressed = sound_effects
	container.get_node("Audio/music").button_pressed = music
	container.get_node("Audio/sfx_volume").value = sound_effects_volume
	container.get_node("Audio/music_volume").value = music_volume
	
	# Gameplay Settings
	container.get_node("Gameplay/autorun").button_pressed = autorun
	container.get_node("Gameplay/invert_y").button_pressed = invert_y
	container.get_node("Gameplay/mouse_sensitivity").value = mouse_sensitivity
	container.get_node("Gameplay/walk_speed").value = walk_speed
	container.get_node("Gameplay/show_map_names").button_pressed = show_map_names
	container.get_node("Gameplay/key_forward").text = key_forward
	container.get_node("Gameplay/key_left").text = key_left
	container.get_node("Gameplay/key_back").text = key_back
	container.get_node("Gameplay/key_right").text = key_right

	# Graphics Settings
	container.get_node("Graphics/fullscreen_mode").button_pressed = fullscreen_mode
	container.get_node("Graphics/hidden_crosshair").button_pressed = hidden_crosshair
	container.get_node("Graphics/bigger_crosshair").button_pressed = bigger_crosshair
	container.get_node("Graphics/potato_mode").button_pressed = potato_mode
	createDropdown( container.get_node("Graphics/textures"), texture_options, textures )
	container.get_node("Graphics/resolution_scaling").value = resolution_scaling
	unmapKeys()

func storeSettings( nodepath ):
	var container = get_node( nodepath )
	
	# Audio Settings
	sound_effects = container.get_node("Audio/sound_effects").button_pressed
	music = container.get_node("Audio/music").button_pressed
	sound_effects_volume = container.get_node("Audio/sfx_volume").value
	music_volume = container.get_node("Audio/music_volume").value

	# Gameplay Settings
	autorun = container.get_node("Gameplay/autorun").button_pressed
	invert_y = container.get_node("Gameplay/invert_y").button_pressed
	mouse_sensitivity = container.get_node("Gameplay/mouse_sensitivity").value
	walk_speed = container.get_node("Gameplay/walk_speed").value
	show_map_names = container.get_node("Gameplay/show_map_names").button_pressed
	key_forward = container.get_node("Gameplay/key_forward").text.capitalize()
	key_left = container.get_node("Gameplay/key_left").text.capitalize()
	key_back = container.get_node("Gameplay/key_back").text.capitalize()
	key_right = container.get_node("Gameplay/key_right").text.capitalize()
	
	# Graphics Settings
	fullscreen_mode = container.get_node("Graphics/fullscreen_mode").button_pressed
	hidden_crosshair = container.get_node("Graphics/hidden_crosshair").button_pressed
	bigger_crosshair = container.get_node("Graphics/bigger_crosshair").button_pressed
	potato_mode = container.get_node("Graphics/potato_mode").button_pressed
	textures = readDropdown( container.get_node("Graphics/textures") )
	resolution_scaling = container.get_node("Graphics/resolution_scaling").value
	
	saveSettings()
	applySettings()

func saveSettings():
	var path = "user://users/" + global.user + "/" + global.universe + "/settings/"
	var _directory = global.directoryFindOrNew( path )
	var file = FileAccess.open( path + "settings.save", FileAccess.WRITE )
	
	var data = []
	for i in fields.size():
		data.insert(i, get(fields[i]) )

	file.store_var( data )
	
func loadSettings():
	var path = "user://users/" + global.user + "/" + global.universe + "/settings/"
	var _directory = global.directoryFindOrNew( path )
	var file = FileAccess.open( path + "settings.save", FileAccess.READ )
	if file:
		var data = file.get_var( true )
		file.close()
		
		if typeof(data) != TYPE_ARRAY:
			global._print("Settings file is corrupted")
			data = []
		
		for i in fields.size():
			if ( data.size() > i ):
				set(fields[i], data[i])

func createDropdown( node, options, selected ):
	node.clear()
	var i = 0
	for option in options:
		node.add_item( option, i )
		if option == selected:
			node.select( node.get_item_index(i) )
		i = i + 1

func readDropdown( node ):
	return node.get_item_text( node.get_selected_id() )

func load_user_textures():
	var path = ""
	var directory = DirAccess.open("res://assets/materials")
	for material in directory.get_files():
		ResourceLoader.load("res://assets/materials/" + material, "", ResourceLoader.CACHE_MODE_REPLACE)
	if ( textures == "default"):
		return
	elif textures == "custom":
		path = OS.get_user_data_dir() + "/textures"
		global.directoryFindOrNew(path)
	else:
		if texture_options.has(textures):
			path = "res://assets/textures/packs/" + textures
		#else:
		#	if Steam.getItemState(textures) & Steam.ITEM_STATE_INSTALLED:
		#		path = Steam.getItemInstallInfo(textures)["folder"]+"/"

	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var image
				if ( textures == "custom" ):
					image = Image.new()
					var err = image.load(path + "/" + file_name)
					if err != OK:
						global._print("Failed to load user texture: " + str(err))
						file_name = dir.get_next()
						continue
				else:
					image = load(path + "/" + file_name.replace(".import", ""))
					if image != null:
						image = image.get_image()
					else:
						file_name = dir.get_next()
						continue
				var texture = ImageTexture.create_from_image(image)
				#var flags = Texture.FLAGS_DEFAULT | Texture.FLAG_ANISOTROPIC_FILTER
				var transparent_image = image.detect_alpha() != Image.ALPHA_NONE
				
				# transparent materials go in a transparent subfolder
				var mat_path = "res://assets/materials/"
				if file_name.begins_with('transparent'):
					mat_path = "res://assets/materials/transparent/"
				
				var material = load(mat_path + file_name.replace(".import","").replace(".png","") + ".material")
				if material != null && material is BaseMaterial3D:
					if image.get_width() <= 64 && image.get_height() <= 64:
						material.texture_filter = false
						material.texture_repeat = true
					# Handle cut-out transparency (no full-alpha support)
					if false && transparent_image:
						#turn this off for now, not sure what replaces it
						if false: #material.flags_transparent:
							# Keep the existing material and render on top of it
							var wrapper = material.duplicate()
							wrapper.flags_transparent = false
							material.params_grow = true
							material.params_grow_amount = -0.0009
							material.next_pass = wrapper
							material = wrapper
						material.params_use_alpha_scissor = true
						material.params_alpha_scissor_threshold = 0.98
						material.params_grow = true
						material.params_grow_amount = -0.0005
						material.params_cull_mode = BaseMaterial3D.CULL_DISABLED
					material.flags_transparent = false
					# Remove existing color, or it will tint the texture.
					material.albedo_color = Color.WHITE
					material.albedo_texture = texture
					# Project texture globally, ignoring cube size and rotation.
					# This is kinda weird for paintings and anything oddly rotated.
					material.uv1_scale = Vector3(1, 1, 1)
					material.uv1_triplanar = true
					material.uv1_world_triplanar = true
					# Use some average PBR material defaults.
					# Maybe make customizable later?
					material.roughness = 0.75
					material.metallic_specular = 0
					material.metallic = 0
			file_name = dir.get_next()

func mapArrowKeys():
	var key_event_forward = InputEventKey.new()
	key_event_forward.keycode = KEY_UP
	InputMap.action_add_event( "move_forward", key_event_forward )
	
	var key_event_back = InputEventKey.new()
	key_event_back.keycode = KEY_DOWN
	InputMap.action_add_event( "move_back", key_event_back )
	
	var key_event_left = InputEventKey.new()
	key_event_left.keycode = KEY_LEFT
	InputMap.action_add_event( "move_left", key_event_left )
	
	var key_event_right = InputEventKey.new()
	key_event_right.keycode = KEY_RIGHT
	InputMap.action_add_event( "move_right", key_event_right )

func mapKeys():
	if key_forward == "":
		key_forward = "W"
	if key_back == "":
		key_back = "S"
	if key_left == "":
		key_left = "A"
	if key_right == "":
		key_right = "D"
	
	var key_event_forward = InputEventKey.new()
	key_event_forward.keycode = OS.find_keycode_from_string( key_forward )
	InputMap.action_add_event( "move_forward", key_event_forward )
	
	var key_event_back = InputEventKey.new()
	key_event_back.keycode = OS.find_keycode_from_string( key_back )
	InputMap.action_add_event( "move_back", key_event_back )
	
	var key_event_left = InputEventKey.new()
	key_event_left.keycode = OS.find_keycode_from_string( key_left )
	InputMap.action_add_event( "move_left", key_event_left )
	
	var key_event_right = InputEventKey.new()
	key_event_right.keycode = OS.find_keycode_from_string( key_right )
	InputMap.action_add_event( "move_right", key_event_right )
	
func unmapKeys():
	var key_event_forward = InputEventKey.new()
	key_event_forward.keycode = OS.find_keycode_from_string( key_forward )
	InputMap.action_erase_event( "move_forward", key_event_forward )
	
	var key_event_back = InputEventKey.new()
	key_event_back.keycode = OS.find_keycode_from_string( key_back )
	InputMap.action_erase_event( "move_back", key_event_back )
	
	var key_event_left = InputEventKey.new()
	key_event_left.keycode = OS.find_keycode_from_string( key_left )
	InputMap.action_erase_event( "move_left", key_event_left )
	
	var key_event_right = InputEventKey.new()
	key_event_right.keycode = OS.find_keycode_from_string( key_right )
	InputMap.action_erase_event( "move_right", key_event_right )
