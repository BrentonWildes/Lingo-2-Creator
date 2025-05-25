extends Node3D

@export_range(5, 7200, 5) var degrees_of_rotation= 90
@export var skew:float

enum gravity_snaps{Nearest_by_degree, Favour_Base_by_degree, Favour_Wall_by_degree, Nearest_by_distance, Favour_Base_by_distance, Favour_Wall_by_distance, Custom_Up, Do_Not_Snap, Snap_To_Nearest_Cube_face}
@export var snap_gravity_on_leaving_ramp:gravity_snaps = gravity_snaps.Nearest_by_degree
@export var custom_up:Vector3 = Vector3(0,1,0)

enum velocity_grabs{Only_walking, Walking_and_running, Always}
@export var velocity_restrictions:velocity_grabs = velocity_grabs.Walking_and_running
var velocity_restrictions_numeric:float

@export var gravity_inside_points_towards_centre:bool = false
enum angle_grabs{Within_30, Within_45, Within_90, Always}
@export var angle_restrictions:angle_grabs = angle_grabs.Within_30
var angle_restrictions_numeric
@export var ramp_cannon:bool = false

var player_on_inside:bool = false
var player_on_outside:bool = false

@onready var player:Node = $"/root/scene/player"
var snapping_to:Vector3
var startingbasis:Basis
var startinginsidevector:Vector3
var endinginsidevector:Vector3
var startingoutsidevector:Vector3
var endingoutsidevector:Vector3
var startingpoint:Vector3
var endingpoint:Vector3

var desireup:Vector3
var desirebasis:Basis
var gone_through_ready:bool = false
var default_gravity


func _ready()->void:
	default_gravity = player.gravity
	startingpoint = self.global_position
	endingpoint = $Pivot.to_global($Pivot.to_local(startingpoint).rotated($Pivot.transform.basis.z.normalized(), deg_to_rad(-degrees_of_rotation))) + skew * $Pivot.basis.z

	startinginsidevector = ($Pivot.global_position - self.global_position).normalized()
	endinginsidevector = startinginsidevector.rotated($Pivot.global_transform.basis.z.normalized(), deg_to_rad(-degrees_of_rotation)).normalized()

	startingoutsidevector = -($Pivot.global_position - self.global_position).normalized()
	endingoutsidevector = startingoutsidevector.rotated($Pivot.global_transform.basis.z.normalized(), deg_to_rad(-degrees_of_rotation)).normalized()

	
	if angle_restrictions == angle_grabs.Within_30:
		angle_restrictions_numeric = deg_to_rad(30)
	elif angle_restrictions == angle_grabs.Within_45:
		angle_restrictions_numeric = deg_to_rad(45)
	elif angle_restrictions == angle_grabs.Within_90:
		angle_restrictions_numeric = deg_to_rad(90)
	elif angle_restrictions == angle_grabs.Always:
		angle_restrictions_numeric = 2*PI 
		
	if velocity_restrictions == velocity_grabs.Only_walking:
		velocity_restrictions_numeric = min(player.walk_speed + 1, 15)
	elif velocity_restrictions == velocity_grabs.Walking_and_running:
		velocity_restrictions_numeric = min(player.run_speed + 1, 30)
	elif velocity_restrictions == velocity_grabs.Always:
		velocity_restrictions_numeric = player.terminal_velocity + 1
		
	$Timer.timeout.connect(_timer_stops)
	$ActivationInside.body_entered.connect(player_enters_inside_ramp)
	$ActivationInside.body_exited.connect(player_leaves_inside_ramp)
	$ActivationOutside.body_entered.connect(player_enters_outside_ramp)
	$ActivationOutside.body_exited.connect(player_leaves_outside_ramp)
	
		
	gone_through_ready = true

func find_desired_up_vector() -> Vector3:
	var modifiedplayerpos = get_player_pos_rel_to_pivot() - 1*player.basis.y
	desireup = ($Pivot.global_position - modifiedplayerpos).normalized()
	if (gravity_inside_points_towards_centre and player_on_inside) or player_on_outside:
		desireup = -desireup
	return desireup
			
func find_angle_to_pivot(point:Vector3) -> float:
	var temp = Vector2($Pivot.to_local(point).x,$Pivot.to_local(point).y).angle()
		
	if temp > 0: temp = 2*PI - temp
	if temp < 0: 
		temp = -temp 
		if temp < PI/2:
			temp += 2*PI
	
	temp -= PI/2
	
	return temp 


func get_player_pos_rel_to_pivot() -> Vector3:
	return player.global_position - player.global_position.project($Pivot.global_transform.basis.z) + $Pivot.global_position.project($Pivot.global_transform.basis.z)

func check_player_pos():
	if player_on_inside or player_on_outside or player.velocity.length() < velocity_restrictions_numeric:
		var modifiedplayerpos = get_player_pos_rel_to_pivot()
		if modifiedplayerpos.distance_to($Pivot.global_position) < 4 * self.scale.x:
			if find_desired_up_vector().angle_to(player.basis.y) < angle_restrictions_numeric:
				if $ActivationInside.get_overlapping_bodies().has(player):
					player_on_inside = true
					player.flipped = true
					self.set_physics_process(true)
					
		elif modifiedplayerpos.distance_to($Pivot.global_position) > 4 * self.scale.x:
			#need the minus here because we are not yet on the outside of the ramp
			if find_desired_up_vector().angle_to(-player.basis.y) < angle_restrictions_numeric:
				if $ActivationOutside.get_overlapping_bodies().has(player):
					player_on_outside = true
					player.flipped = true
					self.set_physics_process(true)
	

func _physics_process(_delta)->void:
	if player.flipped == false:
		#then it must have been turned off by something else, and the ramp should drop control
		player.gravity = default_gravity
		if player_on_inside:
			player_on_inside = false
			select_exit_up_inside()
		if player_on_outside:
			player_on_outside = false
			select_exit_up_outside()
		
		#force the snap:
		_rotate_to_basis(snapping_to, true)
		set_physics_process(false)
		$Timer.stop()

	#If we are on the ramp, have no yet left, and therefore the timer isn't running)
	if (player_on_inside or player_on_outside) and $Timer.is_stopped():
		var thing = find_angle_to_pivot(player.global_position)
		var upvec = find_desired_up_vector()
		if degrees_of_rotation < 360 and thing > deg_to_rad(degrees_of_rotation):
			upvec = player.global_transform.basis.y
		_rotate_to_basis(upvec)
	
	#If we are in the process of leaving the ramp, and therefore the timer is triggered:
	if not snapping_to == null and !player_on_inside and !player_on_outside and !$Timer.is_stopped():
		desireup = snapping_to
		_rotate_to_basis(desireup)
		#And if we're close to the final, then just snap to it immediately and skip the timer
		if player.basis.y.angle_to(desireup) < deg_to_rad(5.0):
			_rotate_to_basis(desireup,true)
			$Timer.stop()
			player.flipped = false
			set_physics_process(false)
			player.gravity = default_gravity

	

func _timer_stops()->void:
	#This just ensures that we aren't left slightly off-level if the timer is stopped for a frame before process is processed
	_rotate_to_basis(desireup, true)
	player.gravity = default_gravity
	#and enable the player to enter another ramp
	player.flipped = false

func _rotate_to_basis(desire, force=false)->void:
	if not player.flipped:
		set_physics_process(false)
	else: 
		var location = player.get_node("cshape").global_transform.origin
		#we'll use this after the player is rotated in order to set the player location, and thus rotate around the player's centre-of-mass, rather than the feet
		
		var distance_from_centre = $Pivot.global_position - get_player_pos_rel_to_pivot()
		var tempaxis:Vector3 = player.basis.y.cross(desire).normalized()
		var tempdegrees = player.basis.y.angle_to(desire)
		if tempaxis != null and tempaxis != Vector3.ZERO:
			var dbasis = player.basis.rotated(tempaxis.normalized(), tempdegrees).orthonormalized()			
			#1 = instant
			var slerpingspeed = 1
			if !$Timer.is_stopped():
				slerpingspeed = 0.1
			if player.basis.y.angle_to(desire) > deg_to_rad(20):
				slerpingspeed = 0.2
			if tempdegrees > deg_to_rad(15):
				slerpingspeed = 0.1
			if $Timer.is_stopped() and gravity_inside_points_towards_centre and distance_from_centre.length() > 1:
				slerpingspeed = 0.01
				player.gravity = default_gravity/4.0
				if ramp_cannon and (player.velocity).length() < player.terminal_velocity:
						player.velocity -= 5 * $Pivot.global_transform.basis.z
			if $Timer.is_stopped() and (!$SlowRotationTimer.is_stopped() or (gravity_inside_points_towards_centre and (distance_from_centre).length() < 1)):
				slerpingspeed = 0.01
				player.gravity = 0
				$SlowRotationTimer.start()
				if ramp_cannon and (player.velocity).length() < player.terminal_velocity:
						player.velocity -= 5 * $Pivot.global_transform.basis.z
			else:
				player.gravity = default_gravity
				var origbasis = player.basis
				player.basis = player.basis.slerp(dbasis,slerpingspeed).orthonormalized()
				player.velocity = player.basis * origbasis.inverse() * player.velocity

			if force or ($SlowRotationTimer.is_stopped() and player.basis.y.angle_to(dbasis.y)<deg_to_rad(1) and (distance_from_centre - player.basis.y).length() > 2):
				var origbasis = player.basis
				player.basis = dbasis
				player.velocity = player.basis * origbasis.inverse() * player.velocity
		
			if Input.is_action_just_pressed("jump"):
				$JumpTimer.start()

			if player_on_outside and $JumpTimer.is_stopped():
				player.global_position = player.global_position.lerp(player.global_position + distance_from_centre + player.basis.y * (4 * self.scale.x + 0.1), 0.1)   
				
				
			if force:
				player_on_inside = false
				player_on_outside = false
				self.set_physics_process(false)
		#this will be different from location1 if the player has been rotated since
		var location2 = player.get_node("cshape").global_transform.origin
		player.global_transform.origin += location - location2
		
func player_enters_inside_ramp(body)->void:
	if body.is_in_group("player") and $Timer.is_stopped() and !player.flipped and player.velocity.length() < velocity_restrictions_numeric:
		check_player_pos()

			
func select_nearest_cube_face():
	var closest = 360
	closest = player.basis.y.angle_to(Vector3(0,1,0))
	snapping_to = Vector3(0,1,0)
	var test_for = [Vector3(-1,0,0), Vector3(1,0,0), Vector3(0,-1,0), Vector3(0,0,-1), Vector3(0,0,1)]
	for up in test_for:
		if player.basis.y.angle_to(up) < closest:
			closest = player.basis.y.angle_to(up)
			snapping_to = up
	
	


func select_exit_up_inside():
	if snap_gravity_on_leaving_ramp == gravity_snaps.Nearest_by_degree:
		if player.transform.basis.y.angle_to(startinginsidevector) > player.transform.basis.y.angle_to(endinginsidevector):
				snapping_to = endinginsidevector
		else: 
				snapping_to = startinginsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Favour_Base_by_degree:
		if player.transform.basis.y.angle_to(startinginsidevector) > 2* player.transform.basis.y.angle_to(endinginsidevector):
			snapping_to = endinginsidevector
		else: 
			snapping_to = startinginsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Favour_Wall_by_degree:
		if player.transform.basis.y.angle_to(startinginsidevector) *2 > player.transform.basis.y.angle_to(endinginsidevector):
			snapping_to = endinginsidevector
		else: 
			snapping_to = startinginsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Nearest_by_distance:
		if player.global_position.distance_to(startingpoint) > player.global_position.distance_to(endingpoint):
			snapping_to = endinginsidevector
		else: 
			snapping_to = startinginsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Favour_Base_by_distance:
		if player.global_position.distance_to(startingpoint) > 2* player.global_position.distance_to(endingpoint):
			snapping_to = endinginsidevector
		else: 
			snapping_to = startinginsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Favour_Wall_by_distance:
		if player.global_position.distance_to(startingpoint)* 2 > player.global_position.distance_to(endingpoint):
			snapping_to = endinginsidevector
		else: 
			snapping_to = startinginsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Custom_Up:
		snapping_to = custom_up
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Snap_To_Nearest_Cube_face:
		select_nearest_cube_face()

func select_exit_up_outside():
	if snap_gravity_on_leaving_ramp == gravity_snaps.Nearest_by_degree:
		if player.transform.basis.y.angle_to(startingoutsidevector) > player.transform.basis.y.angle_to(endingoutsidevector):
				snapping_to = endingoutsidevector
		else: 
				snapping_to = startingoutsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Favour_Base_by_degree:
		if player.transform.basis.y.angle_to(startingoutsidevector) > 2* player.transform.basis.y.angle_to(endingoutsidevector):
			snapping_to = endingoutsidevector
		else: 
			snapping_to = startingoutsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Favour_Wall_by_degree:
		if player.transform.basis.y.angle_to(startingoutsidevector) *2 > player.transform.basis.y.angle_to(endingoutsidevector):
			snapping_to = endingoutsidevector
		else: 
			snapping_to = startingoutsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Nearest_by_distance:
		if player.global_position.distance_to(startingpoint) > player.global_position.distance_to(endingpoint):
			snapping_to = endingoutsidevector
		else: 
			snapping_to = startingoutsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Favour_Base_by_distance:
		if player.global_position.distance_to(startingpoint) > 2* player.global_position.distance_to(endingpoint):
			snapping_to = endingoutsidevector
		else: 
			snapping_to = startingoutsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Favour_Wall_by_distance:
		if player.global_position.distance_to(startingpoint)* 2 > player.global_position.distance_to(endingpoint):
			snapping_to = endingoutsidevector
		else: 
			snapping_to = startingoutsidevector
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Custom_Up:
		snapping_to = custom_up
	elif snap_gravity_on_leaving_ramp == gravity_snaps.Snap_To_Nearest_Cube_face:
		select_nearest_cube_face()


func player_leaves_inside_ramp(body)->void:
	if body.is_in_group("player") and player_on_inside:
		player.gravity = default_gravity
		player_on_inside = false
		if !snap_gravity_on_leaving_ramp == gravity_snaps.Do_Not_Snap:
			$Timer.start()
			select_exit_up_inside()
		if ramp_cannon:
			player.velocity = Vector3.ZERO

func player_enters_outside_ramp(body)->void:
	if body.is_in_group("player") and $Timer.is_stopped() and !player_on_inside and !player.flipped and player.velocity.length() < velocity_restrictions_numeric:
		check_player_pos()

		
func player_leaves_outside_ramp(body)->void:
	if body.is_in_group("player") and player_on_outside:
		player.gravity = default_gravity
		player_on_outside = false
		if !snap_gravity_on_leaving_ramp == gravity_snaps.Do_Not_Snap:
			$Timer.start()
			select_exit_up_outside()
		if ramp_cannon:
			player.velocity = Vector3.ZERO
