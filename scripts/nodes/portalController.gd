extends Node
var warps = []
@onready var player = get_node("/root/scene/player")
var main_viewport
var main_cam:Camera3D = null
var portal_viewport 
var portal_cam
var gone_through_ready = false

func get_warps_recursive(node):
	var warpreturn = []
	for thing in node.get_children():
		warpreturn += get_warps_recursive(thing)
		if thing is MurderPortal: warpreturn += [thing]
	return warpreturn

func _ready():
	warps = get_warps_recursive(self)
	main_viewport = get_viewport()
	main_cam = get_viewport().get_camera_3d()
	portal_viewport = $PortalCam
	portal_cam = $PortalCam/Camera3D
	call_deferred("_deferred_ready")

func _deferred_ready():
	for warp in warps:
		var thing = warp.get_node("MurderPortal")
		thing.mesh.material.set_shader_parameter("myalbedo", $PortalCam.get_texture())
		thing.mesh.material.set_shader_parameter("simdata", $Simulation.get_texture())
				
				
	$Simulation/Sim.material.set_shader_parameter("sim_tex", $SimulationBuffer.get_texture())
	$SimulationBuffer/Buffer.material.set_shader_parameter("myalbedo", $Simulation.get_texture())
	gone_through_ready = true

func _process(_delta):
	if gone_through_ready:
		var shortestdistance = warps[0].global_position.distance_to(player.global_position) + 1000
		var shortport = warps[0]
		for warp in warps:
			warp.is_active = false
			if warp.hide_me: warp.visible = false
			if warp.global_position.distance_to(player.global_position) < shortestdistance && player.global_position.direction_to(warp.global_position).angle_to(-player.global_transform.basis.z) < deg_to_rad(main_cam.fov):
				shortestdistance = warp.global_position.distance_to(player.global_position)
				shortport = warp
				print(rad_to_deg(warp.global_position.direction_to(player.global_position).angle_to(-player.global_transform.basis.z) ))

		var entrance = shortport
		var exit = get_node(str(self.get_path_to(entrance)) + "/"+ str(entrance.warp_to))
		entrance.is_active = true
		if entrance.get_node("Timer").is_stopped():
			entrance.visible = true
		var temp_scale = entrance.scale
		entrance.scale = Vector3(1,1,1)
		var temp_scale2 = exit.scale
		exit.scale = Vector3(1,1,1)
		var newbasis = exit.global_transform.basis
		var origbasis = entrance.global_transform.basis.orthonormalized()
		
		portal_viewport.size = main_viewport.size
		portal_cam.environment = main_cam.environment
		portal_cam.fov = main_cam.fov
		

		portal_cam.global_transform.basis = newbasis.orthonormalized()* origbasis.orthonormalized().inverse() * main_cam.global_transform.basis 
		portal_cam.global_transform.origin = exit.to_global(entrance.to_local(main_cam.global_transform.origin))
		portal_cam.near = clamp(portal_cam.global_transform.origin.distance_to(exit.global_transform.origin)-1.5, 0.05, 500)
		entrance.scale = temp_scale
		exit.scale = temp_scale2
