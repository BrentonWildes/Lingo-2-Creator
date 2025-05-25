extends Node3D
class_name Collectable

@export_enum ("key", "smiley") var unlock_type:String = "key"
@export var unlock_key:String = "@"
@export var display:String = "@"
@export var level = 1
@export var material_override:Material = load("res://assets/materials/purple.material")

var is_complete = false
var play_sfx = true

signal trigger
signal untrigger #I can't currently imagine how this could be implemented
signal sfx_pickup

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Area3D").body_entered.connect(bodyEntered)
	$AnimationPlayer.play("rise")
	get_node("MeshInstance3D").mesh.text = display
	var mesh = get_node("MeshInstance3D")
	var material = material_override.duplicate()
	material.transparency = 1
	mesh.set_surface_override_material(0, material)
	if play_sfx:
		connect("sfx_pickup", sfxPlayer.sfx_play.bind("pickup"))

func bodyEntered( body ):
	if body.is_in_group("player"):
		if unlock_type == "key":
			if ( level == -1 ):
				unlocks.unlockKey(unlock_key, 0)
				unlocks.destroyKeyholderKey(unlock_key)
				pickedUp()
			elif global.dev_cheats || level == 1 || ( level == 2 && unlocks.keys[unlock_key] == 1 ) || ( level == 2 && ( unlock_key == "g" || unlock_key == "c" ) ):
				unlocks.unlockKey( unlock_key, level )
				pickedUp()
			elif ( level == 2 && global.allow_extra_pickups):
				pickedUp()
		else:
			unlocks.loadCollectables()
			unlocks.unlockCollectable( unlock_type )
			pickedUp()

func pickedUp():
	if play_sfx && !is_complete:
		emit_signal("sfx_pickup")
	is_complete = true
	emit_signal("trigger")
	var tween = create_tween()
	tween.tween_property(get_node("MeshInstance3D"), "transparency", 1.0, 0.5)
	tween.tween_callback( remove )

func loadData( _discard ):
	emit_signal("trigger")
	remove()

func remove():
	hide()
	position.y = -1000
