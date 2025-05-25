extends Node3D
class_name signColorKeyCheckReader 

var mesh

signal trigger_letter

func _ready():
	get_parent().hide()
	mesh = get_parent().get_node("MeshInstance3D").mesh
	var _watcher = get_node("/root/scene/Components/KeyHolderChecker").trigger_letter.connect( _update )

func _update( letter, correct ):
	if ( letter == mesh.text ):
		get_parent().show()
		if ( !correct ):
			mesh.material = load("res://assets/materials/redBright.material")
	
	#if ( mesh.text == letter ):
	#	mesh.material = load("res://assets/materials/green.material")
	#else:
	#	mesh.material = load("res://assets/materials/redBright.material")
