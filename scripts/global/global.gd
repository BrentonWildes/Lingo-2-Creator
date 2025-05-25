extends Node

var dev_cheats = true

#demo flag
var is_demo = false
var allow_extra_pickups = true
var allow_numbers = false

#temporary useful
var selected = "h"
var solving = false
var can_enter_solve = true
var active_panel = null
var hints = 1000
var loaded = false

#user
var user = "you"
var steam_username: String = "you"
var is_on_steam_deck = false
var steam_enabled = true
var using_keyboard = false

#world change stuff
var map = "demo"
var universe = "lingo_custom"
var sets_entry_point = false
var entry_point = Vector3(0,0,0)
var entry_rotate = Vector3(0,0,0)
var entry_pivot = Vector3(0,0,0)
var entry_player_rotate = Vector3(0,0,0)
#var entry_diff = Vector3(0,0,0)
var entry_velocity = Vector3(0,0,0)

var scenes = {}
var reserved_scenes = { 
	"control_center": "control_center", 
	"daedalus": "daedalus",
	"demo": "demo",
	"four_rooms": "four_rooms", 
	"icarus": "icarus",
	"murder_she_wrote": "murder_she_wrote", 
	"new_template": "new_template", 
	"parabox": "parabox", 
	"test": "test", 
	"the_ancient": "the_ancient",
	"the_advanced": "the_advanced", 
	"the_bearer": "the_bearer", 
	"the_between": "the_between", 
	"the_butterfly": "the_butterfly", 
	"the_charismatic": "the_charismatic", 
	"the_colorful": "the_colorful", 
	"the_congruent": "the_congruent", 
	"the_crystalline": "the_crystalline", 
	"the_darkroom": "the_darkroom", 
	"the_digital": "the_digital", 
	"the_door": "the_door", 
	"the_double_sided": "the_double_sided", 
	"the_entry": "the_entry", 
	"the_extravagant": "the_extravagant", 
	"the_fuzzy": "the_fuzzy", 
	"the_gallery": "the_gallery", 
	"the_gold": "the_gold", 
	"the_graveyard": "the_graveyard", 
	"the_great": "the_great", 
	"the_hinterlands": "the_hinterlands",
	"the_hive": "the_hive",
	"the_house": "the_house", 
	"the_impressive": "the_impressive", 
	"the_invisible": "the_invisible", 
	"the_jubilant": "the_jubilant", 
	"the_keen": "the_keen",
	"the_liberated": "the_liberated", 
	"the_linear": "the_linear",
	"the_lionized": "the_lionized", 
	"the_literate": "the_literate",
	"the_lively": "the_lively", 
	"the_nuanced": "the_nuanced", 
	"the_oct": "the_oct", 
	"the_orb": "the_orb", 
	"the_owl": "the_owl", 
	"the_parthenon": "the_parthenon", 
	"the_partial": "the_partial", 
	"the_perceptive": "the_perceptive", 
	"the_plaza": "the_plaza", 
	"the_quiet": "the_quiet", 
	"the_relentless": "the_relentless", 
	"the_repetitive": "the_repetitive",
	"the_representative": "the_representative", 
	"the_revitalized": "the_revitalized", 
	"the_shop": "the_shop",
	"the_sirenic": "the_sirenic",
	"the_stellar": "the_stellar",
	"the_stormy": "the_stormy", 
	"the_sturdy": "the_sturdy", 
	"the_sun_temple": "the_sun_temple", 
	"the_sweet": "the_sweet", 
	"the_symbolic": "the_symbolic",
	"the_talented": "the_talented", 
	"the_tenacious": "the_tenacious", 
	"the_three_doors": "the_three_doors", 
	"the_tower": "the_tower", 
	"the_tree": "the_tree", 
	"the_unkempt": "the_unkempt", 
	"the_unyielding": "the_unyielding", 
	"the_wise": "the_wise", 
	"the_wondrous": "the_wondrous", 
	"the_words": "the_words"
}

var personal_scenes = {
	"icely": "the_advanced",
	"star": "the_stellar",
	"kirby": "the_stellar",
	"hatkirby": "the_stellar",
	"quartz": "the_crystalline",
	"q": "the_crystalline",
	"souvey": "the_charismatic",
	"kiwi": "the_fuzzy",
	"gongus": "the_fuzzy",
	#"brendangelo": "the_representative",
	#"brenton": "the_sturdy"
}

var letters_array = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
var numbers_array = ["1","2","3","4","5","6","7","8","9","0"]

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	initializeSteam()

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func initializeSteam():
	var initialize_response: Dictionary = Steam.steamInitEx()
	if initialize_response['status'] > 0:
		steam_enabled = false
		_print("Failed to initialize Steam. Some functionality may not work as intended. %s" % initialize_response)
		#get_tree().quit()
	else:
		steam_username = Steam.getPersonaName()
		is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()
		using_keyboard = Steam.isSteamRunningOnSteamDeck()
		#user = steam_username

func directoryFindOrNew( directory ):
	var dir = DirAccess.open( directory )
	if ( !dir ):
		DirAccess.make_dir_recursive_absolute( directory )
		dir = DirAccess.open( directory )
	return dir

func listFiles( path ):
	var files = []
	var dir = directoryFindOrNew(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			files.append(path + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	return files

func _print( text ):
	print( text )

func setViewportMaterial( _display_mesh : MeshInstance3D, _sub_viewport : SubViewport, _surface_id : int = 0 ):
	var _mat : StandardMaterial3D = StandardMaterial3D.new()
	_mat.albedo_texture = _sub_viewport.get_texture()
	_display_mesh.set_surface_override_material(_surface_id, _mat)

func multiplayerCheck():
	if user.to_lower().ends_with("_mp"):
		var existing = getNodesOfType(get_node("/root/scene"), "Multiplayer")
		if existing.size() == 0:
			var multiplayer_check = load("res://objects/nodes/multiplayer/multiplayer.tscn").instantiate()
			multiplayer_check.instance_per_save_name = true
			get_node("/root/scene").add_child(multiplayer_check)
		else:
			existing[0].instance_per_save_name = true
			existing[0].ghost_mode = true
			existing[0].hide_avatars = false

func getNodesOfType(node: Node, type, result = []) -> Array:
	if node.get_class() == type:
		result.push_back(node)
	for child in node.get_children():
		var _ignore = getNodesOfType(child, type, result)
	return result

func findScenes():
	scenes = {}
	# Built-in scenes.
	var scene_name = "demo"
	var scene = {
		"name": "demo",
		"path": "res://objects/scenes/demo.tscn",
		"title": "demo"
	}
	scenes[scene_name] = scene
	
	# Manually-installed custom maps.
	directoryFindOrNew("user://maps/")
	_findCustomScenes("user://maps/", ConfigFile.new())
	# Steam Workshop custom maps.
	
	if steam_enabled:
		for item in Steam.getSubscribedItems():
			if Steam.getItemState(item) & Steam.ITEM_STATE_INSTALLED:
				var folder = Steam.getItemInstallInfo(item)["folder"]+"/"
				var metadata = ConfigFile.new()
				metadata.load(folder + "metadata.txt")
				_findCustomScenes(folder, metadata)

func _findCustomScenes(root, metadata):
	for path in listFiles(root):
		if not path.get_extension() in ["tscn", "scn"]:
			continue
		var scene_name = path.get_basename().get_file()
		if scene_name in reserved_scenes:
			print("Ignoring map " + path + " with reserved name")
			continue
		var scene = {
			"name": scene_name,
			"title": scene_name.replace("_", " "),
			"path": path,
			"custom": true,
		}
		if metadata.has_section_key("steam", "title"):
			scene["title"] = metadata.get_value("steam", "title")
		if metadata.has_section_key("map", "hidden_filenames"):
			scene["hidden"] = path.get_file() in metadata.get_value("map", "hidden_filenames")
			if scene["hidden"]:
				scene["title"] += " (" + scene_name + ")"
		if metadata.has_section_key("steam", "preview"):
			var preview = root + metadata.get_value("steam", "preview")
			scene["image"] = preview
		if scene_name in scenes && !OS.has_feature("standalone"):
			# In editor, the local scene should take precedence.
			scene["path"] = scenes[scene_name]["path"]
		scenes[scene_name] = scene

func achieve(achievement):
	var _stat_int = Steam.setStatInt(achievement + "_stat", 1)
	var _achieveable = Steam.setAchievement(achievement)
	var _stats = Steam.storeStats()
