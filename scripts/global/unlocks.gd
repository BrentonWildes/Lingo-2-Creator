extends Node

var keys_file_name = "keys"
var collectables_file_name = "collectables"
var data_file_name = "data"

var keys = {
	" " : 0,
	"a" : 0,
	"b" : 0,
	"c" : 0,
	"d" : 0,
	"e" : 0,
	"f" : 0,
	"g" : 0,
	"h" : 0,
	"i" : 0,
	"j" : 0,
	"k" : 0,
	"l" : 0,
	"m" : 0,
	"n" : 0,
	"o" : 0,
	"p" : 0,
	"q" : 0,
	"r" : 0,
	"s" : 0,
	"t" : 0,
	"u" : 0,
	"v" : 0,
	"w" : 0,
	"x" : 0,
	"y" : 0,
	"z" : 0,
	"@" : 0,
	"insert": 1,
	"capslock": 1,
	"backspace": 1,
	"delete": 1
}

var collectables = {
	"smiley" : 0
}

var data = {
	"color" : "",
	"theBetweenPainting" : "",
	"theTreePainting" : "",
	"eyesPainting" : "",
	"desertPainting" : "", #mint/white
	"graveyardPainting" : "", #black
	"towerPainting" : "", #red
	"wordsPainting" : "", #blue
	"cubesPainting" : "", #green
	"templePainting" : "", #purple
	"castlePainting" : "", #orange
	"colorfulPainting" : "", #gray
	"wonderlandPainting" : "", #plum
	"rainbowPainting" : "", #gold
	"trianglePainting" : "",
	"butterflyPainting" : "",
	"darkroomPainting" : "",
	"unyieldingPainting" : "",
	"rte_the_entry" : "unlocked",
	"rte_the_gallery" : "",
	"rte_control_center" : "",
	"rte_daedalus" : "",
	"rte_the_plaza" : "",
	"double_letters": "",
	"lavender_cubes": "",
	"grave_maze": "",
	"grave_doors": "",
	"grave_keen": "",
	"grave_beast": "",
	"grave_tree": "",
	"grave_landscapes": "",
	"grave_magnet": "",
	"grave_whole": "",
	"free_ending": "",
	"white_ending": "",
	"black_ending": "",
	"red_ending": "",
	"blue_ending": "",
	"green_ending": "",
	"yellow_ending": "",
	"orange_ending": "",
	"purple_ending": "",
	"gray_ending": "",
	"mint_ending": "",
	"cyan_ending": "",
	"plum_ending": "",
	"gold_ending": "",
	"butterfly_mastery": "",
	"doublesided_mastery": "",
	"hive_mastery": "",
	"invisible_mastery": "",
	"lunar_mastery": "",
	"plaza_mastery": "",
	"relentless_mastery": "",
	"repetitive_mastery": "",
	"sirenic_mastery": "",
	"symbolic_mastery": "",
	"tenacious_mastery": "",
	"unyielding_mastery": "",
	"wise_mastery": ""
}

signal unlocked_key( key )

func directoryHelper( filename, access ):
	var path = "user://users/" + global.user + "/" + global.universe + "/unlocks/"
	var _directory = global.directoryFindOrNew( path )
	var file = FileAccess.open( path + filename + ".save", access )
	return file

func unlockKey( key, level ):
	var file = directoryHelper( keys_file_name, FileAccess.WRITE )
	keys[key] = level
	file.store_var( keys )
	file.close()
	unlocked_key.emit( key )
	
	# filters out the special non-letter keys
	if key.length() == 1:
		autosplitter.setLatestUnlockedKey(key, level)

func loadKeys():
	var file = directoryHelper( keys_file_name, FileAccess.READ )
	if (file):
		keys = file.get_var()
		for key in keys:
			unlocked_key.emit( key )
		file.close()

func resetKeys():
	for key in keys:
		if ( key && key != "insert" && key != "capslock" && key != "backspace" && key != "delete"):
			keys[key] = 0
			
func resetCollectables():
	for collectable in collectables:
		collectables[collectable] = 0

func resetData():
	for datum in data:
		if ( datum != "rte_the_entry"):
			data[datum] = ""

func unlockCollectable( type ):
	var file = directoryHelper( collectables_file_name, FileAccess.WRITE )
	collectables[type] += 1
	file.store_var( collectables )
	file.close()
	
func loadCollectables():
	var file = directoryHelper( collectables_file_name, FileAccess.READ )
	if (file):
		collectables = file.get_var()
		file.close()

func setData( key, value ):
	var file = directoryHelper( data_file_name, FileAccess.WRITE )
	data[key] = value
	file.store_var( data )
	file.close()
	
	autosplitter.setLatestUnlockedCollectible(key)
	
func loadData():
	var file = directoryHelper( data_file_name, FileAccess.READ )
	if ( file ):
		var loaded = file.get_var()
		for key in data.keys():
			if loaded.has(key):
				data[key] = loaded[key]
		file.close()

# If key=="", all keys are matched.
func _visitKeyholders(key="", remove_key=false, unlock_key=false):
	var path = "user://users/" + global.user + "/" + global.universe + "/maps/"
	var matches = []
	for dir in DirAccess.get_directories_at(path):
		var filename = path + dir + "/keyholders.save"
		var file = FileAccess.open( filename, FileAccess.READ )
		if file:
			var kh_data = file.get_var( true )
			file.close()
			var index = -1
			var perform_changes = false
			for datum in kh_data:
				index = index + 1
				if ( dir == "the_congruent" && datum[0] == ^"/root/scene/Components/KeyHolders/keyHolder" && datum[1] == "c1"):
					continue
				elif ( dir == "the_congruent" && datum[0] == ^"/root/scene/Components/KeyHolders/keyHolder2" && datum[1] == "g1"):
					continue
				elif ( datum[1] != null && datum[1] != ""):
					var held_key = datum[1].substr(0,1)
					var held_level = int(datum[1].substr(1))
					if key != "" && held_key != key:
						continue
					matches.push_back([held_key, held_level, dir, datum[0]])
					if remove_key:
						perform_changes = true
						kh_data[index][1] = ""
					if unlock_key:
						unlocks.unlockKey(held_key, held_level)
			if ( perform_changes ):
				file = FileAccess.open( filename, FileAccess.WRITE )
				file.store_var(kh_data)
				file.close()
	return matches

func destroyKeyholderKey(key):
	_visitKeyholders(key, true, false)

func unlockAllKeyholders():
	return _visitKeyholders("", true, true)

func getAllKeyholders():
	return _visitKeyholders("", false, false)
