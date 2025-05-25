extends Node3D

signal trigger
signal untrigger

var is_focused = false
var has_key = false
var held_key = ""
var held_level = 0
var is_complete #yeah this is bad maybe I'll get enthused and fix it

@onready var purple = load("res://assets/materials/purple.material")
@onready var cyan = load("res://assets/materials/purple.material")
@onready var tmint = load("res://assets/materials/transparent/transparentMint.material")
@onready var tcyan = load("res://assets/materials/transparent/transparentCyanPastel.material")
#@onready var tpurple = load("res://assets/materials/transparent/transparentPurple.material")
#@onready var tcyanp = load("res://assets/materials/transparent/transparentCyan.material")

func _ready():
	setMaterial()

func passedInput(key):
	if ( is_focused ):
		if ( !has_key && unlocks.keys.has(key) && unlocks.keys[key]):
			if ( key == "a" || key == "b" || key == "c" || key == "d" || key == "e" || key == "f" || key == "g" || key == "h" || key == "i" || key == "j" || key == "k" || key == "l" || key == "m" || key == "n" || key == "o" || key == "p" || key == "q" || key == "r" || key == "s" || key == "t" || key == "u" || key == "v" || key == "w" || key == "x" || key == "y" || key == "z"):
				addKey(key)
		elif ( has_key ):
			if ( key == "a" || key == "b" || key == "c" || key == "d" || key == "e" || key == "f" || key == "g" || key == "h" || key == "i" || key == "j" || key == "k" || key == "l" || key == "m" || key == "n" || key == "o" || key == "p" || key == "q" || key == "r" || key == "s" || key == "t" || key == "u" || key == "v" || key == "w" || key == "x" || key == "y" || key == "z") && unlocks.keys.has(key) && unlocks.keys[key]:
				removeKey()
				addKey(key)
			elif ( key == "backspace" || key == "delete" || held_key == key ):
				removeKey()

func addKey( key ):
	get_node("Hinge/Letter").mesh.text = key
	get_node("Hinge/Letter2").mesh.text = key
	has_key = true
	held_key = key
	held_level = unlocks.keys[key]
	setMaterial()
	unlocks.unlockKey(key, 0)
	is_complete = held_key + str(held_level)
	emit_signal("trigger")
	

func removeKey():
	unlocks.unlockKey(held_key, held_level)
	has_key = false
	held_key = ""
	held_level = 0
	setMaterial()
	get_node("Hinge/Letter").mesh.text = "-"
	get_node("Hinge/Letter2").mesh.text = "-"
	is_complete = ""
	emit_signal("untrigger")

func loadData( data ):
	has_key = true
	is_complete = data
	held_key = data.substr(0,1)
	held_level = int(data.substr(1))
	get_node("Hinge/Letter").mesh.text = held_key
	get_node("Hinge/Letter2").mesh.text = held_key
	setMaterial()
	emit_signal("trigger")

func focus():
	is_focused = true
	get_node("Hinge/MeshInstance3D").mesh.material = tcyan
	
func unfocus():
	is_focused = false
	get_node("Hinge/MeshInstance3D").mesh.material = tmint
	
func setMaterial():
	if held_level == 2:
		get_node("Hinge/Letter").mesh.material = cyan
	else:
		get_node("Hinge/Letter").mesh.material = purple
