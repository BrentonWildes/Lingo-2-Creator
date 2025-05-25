extends Node3D
class_name signScoreLookup

@export var replace = "{{score}}"
@export var score_path:String = ""
@export var complete_at:int = 0

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred( "_readier" )

func _readier():
	var mesh = get_parent().get_node("MeshInstance3D").mesh
	if mesh.text.contains( replace ):
		var path = "user://users/" + global.user + "/" + global.universe + "/" + score_path
		var _directory = global.directoryFindOrNew( path )
		var file = FileAccess.open( path, FileAccess.READ )
		if file:
			var data = file.get_var( true )
			file.close()
			for datum in data:
				if datum[1]:
					score += 1
		if complete_at > 0 and score > complete_at:
			mesh.text = mesh.text.replace(replace, complete_at)
		else:
			mesh.text = mesh.text.replace(replace, score)
