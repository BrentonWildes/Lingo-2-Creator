extends Area3D

enum gravity_snaps{Default_gravity, Normal_to_floor, Custom_axis}
@export var snap_gravity:gravity_snaps = gravity_snaps.Normal_to_floor
@export var custom_axis:Vector3
var player
var desirerotation:Vector3 = Vector3(0,0,0)
var on_floor:bool = false
var desirebasis:Basis
var count:int = 0
var orig_basis

func _ready():
	self.set_process(false)
	$Locator.queue_free()
	$Arrow.queue_free()
	if snap_gravity == gravity_snaps.Default_gravity:
		desirerotation = Vector3.UP
	elif snap_gravity == gravity_snaps.Custom_axis:
		desirerotation = custom_axis
	elif snap_gravity == gravity_snaps.Normal_to_floor:
		desirerotation = self.basis.y

func _process(_delta):
	var location = player.get_node("cshape").global_transform.origin
	_rotate_to_basis(desirebasis)
	var location2 = player.get_node("cshape").global_transform.origin
	player.global_transform.origin += location -location2

func _rotate_to_basis(dbasis, _force=false):
	dbasis = dbasis.orthonormalized()
	if player.flipped:
		player.basis = orig_basis.slerp(dbasis,float(count)/30.0).orthonormalized()
		count += 1
		#this is an abuse of "distance_to"
		if count > 30 or (player.basis.y.distance_to(dbasis.y)<0.1 and player.basis.x.distance_to(dbasis.x)<0.1):
			player.basis = desirebasis.orthonormalized()
			on_floor = false
			self.set_process(false)
			count = 0
			player.flipped = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		on_floor = true
		self.set_process(true)
		player.flipped = true
		orig_basis = player.basis
		
		var tempbasis:Basis
		var tempbasis2:Basis
		var basis1:Basis
		var basis2:Basis
		
		if abs(desirerotation.dot(player.basis.z)) < 0.95:
			tempbasis = Basis.looking_at(desirerotation, player.basis.z)
			basis1 = Basis(tempbasis.x, -tempbasis.z, tempbasis.y)
			desirebasis = basis1

		if abs(desirerotation.dot(player.basis.x)) < 0.95:
			tempbasis2 = Basis.looking_at(desirerotation, player.basis.x)
			basis2 = Basis(tempbasis2.y, -tempbasis2.z, -tempbasis2.x)
			desirebasis = basis2
			
		if abs(desirerotation.dot(player.basis.z)) < 0.95 and abs(desirerotation.dot(player.basis.x)) < 0.95:
			var angle_normalized = sin(player.basis.z.abs().angle_to(tempbasis.y.abs()))
			if angle_normalized < 0.1:
				angle_normalized = 0
			elif angle_normalized > 0.9:
				angle_normalized = 1
			
			desirebasis = basis1.slerp(basis2,angle_normalized) 
