extends Area3D
class_name MurderPortal

@export var warp_to:NodePath
@export var hide_me:bool = true
@export var ripple_shader:bool = false
@export var just_a_window:bool = false
var RAY_LENGTH = 1000
var is_active = false

var prev_col:Vector3

func _ready():
	self.body_entered.connect(_body_entered)
	$MurderPortal.mesh.material = $MurderPortal.mesh.material.duplicate()
	$MurderPortal.mesh.material.set_shader_parameter("ripple_shader", ripple_shader)
	
	$Pointer.queue_free()

func _body_entered(body):
	if warp_to != null and body.is_in_group("player") and not just_a_window and $Timer.is_stopped():
		var target = get_node(warp_to)
		if target is MurderPortal:
			target.get_node("Timer").start()
			target.visible = false
		var temp_scale = self.scale
		self.scale = Vector3(1,1,1)
		var temp_scale2 = target.scale
		target.scale = Vector3(1,1,1)
		
		var origbasis = self.global_transform.basis
		var newbasis = target.global_transform.basis
		body.velocity =  newbasis.orthonormalized()*origbasis.inverse().orthonormalized() * body.velocity
		body.global_transform.basis = newbasis.orthonormalized()* origbasis.inverse().orthonormalized() * body.global_transform.basis 
		body.global_position = target.to_global(self.to_local(body.global_transform.origin))
		self.scale = temp_scale
		target.scale = temp_scale2

func _process(_delta):
	if is_active and ripple_shader:
		# use global coordinates, not local to node
		var cam = get_viewport().get_camera_3d()
		var mousepos = get_viewport().get_mouse_position()
		var origin = cam.project_ray_origin(mousepos)
		var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end, 8)
		#3rd argument is the collision_mask
		query.collide_with_areas = true
		query.collide_with_bodies = true
		var result = get_world_3d().direct_space_state.intersect_ray(query)
	
		if result and result["collider"] == self:
			var pos = to_local(result["position"])
			pos.x = (pos.x + 3.0/2.0)/3.0
			pos.y /= 3.0 
			$"../Simulation/Sim".material.set_shader_parameter("col", Vector2(pos.x,1.0-pos.y))
