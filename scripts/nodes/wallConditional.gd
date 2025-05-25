extends Node3D

@export_enum ( "ignore", "key_pressed", "key_unpressed" ) var passable_with_press: String = "ignore"
@export var key:String = ""

@export var require_positive_x:bool = false
@export var require_positive_y:bool = false
@export var require_positive_z:bool = false
@export var require_negative_x:bool = false
@export var require_negative_y:bool = false
@export var require_negative_z:bool = false

@export var material_override:Material = load("res://assets/materials/turquoise.material")
@export var transparent_material_override:Material = load("res://assets/materials/transparent/transparentTurquoise.material")

@export var sensitivity:float = 0.9

func _ready():
	if get_node_or_null("Hinge/MeshInstance3D") != null:
		var mesh = self.get_node("Hinge/MeshInstance3D")
		mesh.set_surface_override_material(0, material_override)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var body = get_node("/root/scene/player")
	#requirements checking
	var is_passable = true
	
	#direction checking
	if ( require_positive_z && body.get_transform().basis.x.x > -sensitivity):
		is_passable = false
	if ( require_negative_z && body.get_transform().basis.x.x < sensitivity):
		is_passable = false
	if ( require_positive_x && body.get_transform().basis.x.z < sensitivity):
		is_passable = false
	if ( require_negative_x && body.get_transform().basis.x.z > -sensitivity):
		is_passable = false
	if ( require_positive_y && body.get_transform().basis.x.y < sensitivity):
		is_passable = false
	if ( require_negative_y && body.get_transform().basis.x.y > -sensitivity):
		is_passable = false
	
	#keypress checking
	if ( passable_with_press == "key_pressed" && !Input.is_action_pressed( key ) ):
		is_passable = false
	if ( passable_with_press == "key_unpressed" && Input.is_action_pressed( key ) ):
		is_passable = false
		
	if is_passable:
		get_node("Hinge").set_surface_override_material(0, transparent_material_override)
		get_node("Hinge/StaticBody3D/CollisionShape3D").disabled = true
	else:
		get_node("Hinge").set_surface_override_material(0, material_override)
		get_node("Hinge/StaticBody3D/CollisionShape3D").disabled = false
		
