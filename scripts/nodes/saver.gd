extends Receiver
class_name Saver

@export_enum ( "panels", "collectables", "keyholders" ) var type: String = "panels"

var path
var directory

func _ready():
	super._ready()
	path = "user://users/" + global.user + "/" + global.universe + "/maps/" + global.map + "/"
	directory = global.directoryFindOrNew( path )
	levelLoaded()
	
func levelLoaded():
	reload()

#this needs to run AFTER the rest of the objects are ready
func reload():
	# As a safeguard (and a required one when 'I' is stolen), uncollect any
	# key collectables that do not have a corresponding unlock or keyholder key. 
	var collected_keys = {}
	if type == "collectables":
		for key in unlocks.keys:
			collected_keys[key] = unlocks.keys[key]
		for keyholder in unlocks.getAllKeyholders():
			var key = keyholder[0]
			var level = keyholder[1]
			if key not in collected_keys or collected_keys[key] < level:
				collected_keys[key] = level
	var file = FileAccess.open( path + type + ".save", FileAccess.READ )
	if file:
		var data = file.get_var( true )
		file.close()
		for datum in data:
			var saveable = get_node_or_null(datum[0])
			if ( saveable != null ):
				saveable.is_complete = datum[1]
				if saveable.is_complete and saveable is Collectable:
					if saveable.unlock_type == "key" && collected_keys[saveable.unlock_key] < saveable.level:
						saveable.is_complete = false
				if saveable.is_complete:
					saveable.loadData( saveable.is_complete )

func save():
	var file = FileAccess.open( path + type + ".save", FileAccess.WRITE )
	var data = []
	for saveable in all_senders:
		var datum = [ saveable, get_node(saveable).is_complete ]
		data.push_back(datum)
	file.store_var( data )
	file.close()

func handleTriggered():
	if global.loaded:
		save()

func handleUntriggered():
	if global.loaded:
		save()
