extends Receiver

@export var desired_rotation:Vector3 = Vector3(0,1,0)
@onready var player = get_parent()
var on_floor:bool = false
var desirebasis:Basis
var count:int = 0

var ran = false

signal trigger
signal untrigger

func _ready():
	super._ready()

func _process(_delta):
	_rotate_to_basis(desirebasis)

func _rotate_to_basis(dbasis, _force=false):
	dbasis = dbasis.orthonormalized()
	if player.flipped:
		player.basis = player.basis.slerp(dbasis,0.1)
		count += 1
		#this is an abuse of "distance_to"
		if count > 30 or (player.basis.y.distance_to(dbasis.y)<0.1 and player.basis.x.distance_to(dbasis.x)<0.1):
			player.basis = desirebasis
			on_floor = false
			self.set_process(false)
			count = 0

func handleTriggered():
	triggered += 1
	if ( triggered >= total && !ran):
		_handleGravity()
		ran = true
		
func handleUntriggered():
	triggered -= 1
	if ( triggered < total && ran):

		ran = false
		
func _handleGravity():
	on_floor = true
	self.set_process(true)
	player.flipped = true
	
	var tempbasis:Basis
	var tempbasis2:Basis
	var basis1:Basis
	var basis2:Basis
	
	if abs(desired_rotation.dot(player.basis.z)) < 0.95:
		tempbasis = Basis.looking_at(desired_rotation, player.basis.z)
		basis1 = Basis(tempbasis.x, -tempbasis.z, tempbasis.y)
		desirebasis = basis1

	if abs(desired_rotation.dot(player.basis.x)) < 0.95:
		tempbasis2 = Basis.looking_at(desired_rotation, player.basis.x)
		basis2 = Basis(tempbasis2.y, -tempbasis2.z, -tempbasis2.x)
		desirebasis = basis2
		
	if abs(desired_rotation.dot(player.basis.z)) < 0.95 and abs(desired_rotation.dot(player.basis.x)) < 0.95:
		var angle_normalized = sin(player.basis.z.abs().angle_to(tempbasis.y.abs()))
		if angle_normalized < 0.1:
			angle_normalized = 0
		elif angle_normalized > 0.9:
			angle_normalized = 1
		
		desirebasis = basis1.slerp(basis2,angle_normalized) 
