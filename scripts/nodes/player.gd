extends CharacterBody3D

@export var gravity = -40.0
@export var walk_speed = 12.0
@export var run_speed = 24.0
@export var jump_speed = 10.0
@export var mouse_sensitivity = 0.002
@export var acceleration = 8.0
@export var friction = 16.0
@export var fall_limit = -500.0
@export var terminal_velocity = 64.0
@export var view_distance = 800

signal looked_at( player, painting )
signal player_jumped()
signal solve_start()
signal solve_end()
signal level_loaded()
signal key_pressed()

var pivot

var playable = false
var dir = Vector3.ZERO
var panel = null
var last_seen = null
var flipped = false

var default_entry_point
var default_entry_rotation

var failsafe_area_count = 0

func _ready():
	settings.applySettings()
	global.allow_numbers = false
	
	pivot = $pivot
	$pivot.add_excluded_object(self.get_rid())
	self.mouse_sensitivity = float(settings.mouse_sensitivity) / float(10000)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if (settings.hidden_crosshair):
		self.get_node("pivot/camera/crosshair").hide()
		self.get_node("pivot/camera/bigger_crosshair").hide()
	elif (settings.bigger_crosshair):
		self.get_node("pivot/camera/crosshair").hide()
		self.get_node("pivot/camera/bigger_crosshair").show()
	else:
		self.get_node("pivot/camera/crosshair").show()
		self.get_node("pivot/camera/bigger_crosshair").hide()
	
	default_entry_point = position
	default_entry_rotation = rotation
	# set this to true in our levelSwitcher to get it to skip setting it here...
	if ( global.sets_entry_point == false ):
		global.entry_point = position
		global.entry_rotate = rotation
	# or set that to false to reinitialize it for next time
	else:
		position = global.entry_point
		#rotation = Vector3(deg_to_rad(global.entry_rotate.x), deg_to_rad(global.entry_rotate.y), deg_to_rad(global.entry_rotate.z))
		get_node("pivot").rotation = global.entry_pivot
		rotation.x = global.entry_player_rotate.x + deg_to_rad(global.entry_rotate.x)
		rotation.y = global.entry_player_rotate.y + deg_to_rad(global.entry_rotate.y)
		rotation.z = global.entry_player_rotate.z + deg_to_rad(global.entry_rotate.z)
		velocity = global.entry_velocity
		global.sets_entry_point = false
	
	$pivot.get_node("camera").far = view_distance
	
	call_deferred("_loaded")

func _physics_process(delta):
	if global.can_enter_solve:
		if (Input.is_action_just_released("solve_click_close") and global.solving):
			solvingEnd()
		elif (Input.is_action_just_released("solve_click") and !global.solving):
			solving()
			
		if Input.is_action_just_released("solve") and !global.solving:
			solving()
		elif Input.is_action_just_released("solve_close") and global.solving:
			solvingEnd()
	global.can_enter_solve = true
		
	if ( global.solving == false ):
		var ray = self.get_node("pivot/camera/raycast_sight")
		if ( ray.is_colliding() ):
			panel = _get_panel_from_ray(ray)
			if panel != null:
				# set the last panel we interacted with back to defaults
				if ( last_seen != null && is_instance_valid(last_seen)):
					last_seen.unfocus()
				# store our new panel as last seen
				last_seen = panel
				panel.focus()
		else:
			if ( last_seen != null && is_instance_valid( last_seen ) ):
				last_seen.unfocus()

		var ray_sight_short = self.get_node("pivot/camera/raycast_sight_short")
		if ( ray_sight_short.is_colliding() ):
			emit_signal( "looked_at", self, ray_sight_short.get_collider().get_parent() )
		
		basis = basis.orthonormalized()
		up_direction = basis.y
		
		dir = Vector3.ZERO
		#var basis = global_transform.basis
		if Input.is_action_pressed("move_forward"):
			dir -= basis.z
		if Input.is_action_pressed("move_back"):
			dir += basis.z
		if Input.is_action_pressed("move_left"):
			dir -= basis.x
		if Input.is_action_pressed("move_right"):
			dir += basis.x
		dir = dir.normalized()

		var speed = walk_speed
		if settings.autorun:
			speed = run_speed

		if Input.is_action_pressed("run"):
			if settings.autorun:
				speed = walk_speed
			else:
				speed = run_speed

		if self.get_node("raycast_bottom_1").is_colliding() || self.get_node("raycast_bottom_2").is_colliding() || self.get_node("raycast_bottom_3").is_colliding() || self.get_node("raycast_bottom_4").is_colliding():
			#velocity += gravity * delta * basis.y # / 100.0
			if Input.is_action_just_pressed("jump"):
				var store_x
				var store_y
				var store_z
				if (round(basis.y.x) == 0):
					store_x = velocity.x
				if (round(basis.y.y) == 0):
					store_y = velocity.y
				if (round(basis.y.z) == 0):
					store_z = velocity.z
				velocity = ((-gravity/4) + ( gravity * delta )) * basis.y
				if (round(basis.y.x) == 0):
					velocity.x = store_x
				if (round(basis.y.y) == 0):
					velocity.y = store_y
				if (round(basis.y.z) == 0):
					velocity.z = store_z
		else:
			if velocity.project(basis.y).length() < terminal_velocity:
				velocity += gravity * delta * basis.y

		#var dotproduct = velocity.dot(basis.y)
		#if (dotproduct < -terminal_velocity):
		#	velocity += (-terminal_velocity+dotproduct) * basis.y
	
		var hvel = velocity
		hvel -= hvel.dot(basis.y) * basis.y

		var target = dir * speed
		var accel
		if dir.dot(hvel) > 0.0:
			accel = acceleration
		else:
			accel = friction
		hvel = hvel.lerp(target, accel * delta)
		velocity = velocity.dot(basis.y)*basis.y + hvel
		if playable:
			move_and_slide()

		if position.y < fall_limit and playable:
			call_deferred( "fellFromHeaven" )
		elif position.y > -fall_limit and playable:
			call_deferred( "fellToHeaven" )
			#emit_signal("player_jumped")
			
			#self.set_global_transform( Transform3D.IDENTITY )

#		var xAxis = Input.get_joy_axis(0,JOY_AXIS_3)
#		var yAxis = Input.get_joy_axis(0,JOY_AXIS_2)
#		var deadZone = 0.2
#		var speedMultiplier = 0.05
#		if abs(xAxis) > deadZone:
#			if (global.invert_y_axis):
#				pivot.rotate_x( speedMultiplier * xAxis)
#			else:
#				pivot.rotate_x( -speedMultiplier * xAxis)
#			pivot.rotation.x = clamp(pivot.rotation.x, -1.5, 1.5)
#		if abs(yAxis) > deadZone:
#			rotate_y( -speedMultiplier * yAxis)

func fellFromHeaven():
	unlocks.setData("graveyardPainting", "unlocked")
	global.map = "the_graveyard"
	switcher.switch_map("res://objects/scenes/the_graveyard.tscn")
	
func fellToHeaven():
	global.map = "icarus"
	switcher.switch_map("res://objects/scenes/icarus.tscn")

func _get_panel_from_ray(ray):
	var area = ray.get_collider() # Panel/Hinge/Quad/Area
	if area == null:
		return null
	var quad = area.get_parent() # Panel/Hinge/Quad
	if quad == null:
		return null
	var hinge = quad.get_parent() # Panel/Hinge
	if hinge == null:
		return null
	var p = hinge.get_parent() # Panel
	if p == null:
		return null
	return p

func _input(event):
	if (global.solving):
		if (panel != null):
			if (event is InputEventKey && event.is_pressed() && !event.is_echo()):
				press( OS.get_keycode_string(event.keycode).to_lower() )
				

func press( key ):
	if ( panel != null && get_node("pivot/camera/keyboard").visible ):
		panel.passedInput(key)
		emit_signal("key_pressed")

func _unhandled_input(event):
	autosplitter.setFirstMovementFlag(true)
	
	if event is InputEventMouseMotion and playable and !global.solving:
		self.transform.basis = self.transform.basis.rotated(basis.y,-event.relative.x * mouse_sensitivity ) 
		if (settings.invert_y):
			pivot.transform.basis = pivot.transform.basis.rotated(pivot.transform.basis.x, event.relative.y * mouse_sensitivity)
		else:
			pivot.transform.basis = pivot.transform.basis.rotated(pivot.transform.basis.x, -event.relative.y * mouse_sensitivity)
		pivot.rotation += pivot.transform.basis.x * (clamp(pivot.rotation.dot(pivot.transform.basis.x), -1.5, 1.5) - pivot.rotation.dot(pivot.transform.basis.x))

func solving():
	global.solving = true
	get_node("pivot/camera/keyboard").show()
	emit_signal("solve_start")
	
func solvingEnd():
	get_node("pivot/camera/keyboard").hide()
	velocity.x = 0
	velocity.z = 0
	await get_tree().create_timer(0.25).timeout
	global.solving = false
	emit_signal("solve_end")

func _loaded():
	_setup_failsafe_areas()
	global.loaded = true
	musicPlayer.loaded()
	emit_signal("level_loaded")
	if ( settings.show_map_names ):
		message( global.map.replace("_", " ") )
	global.multiplayerCheck()
	await get_tree().process_frame
	playable = true
	autosplitter.setLoadingFlag(false)
	
	switcher.preload_map("res://objects/scenes/the_graveyard.tscn")
	switcher.preload_map("res://objects/scenes/icarus.tscn")

func message( text ):
	var achievement_indicator = get_node("pivot/camera/achievement_label")
	achievement_indicator.text = text
	#achievement_indicator.visible = true
	var tween = create_tween()
	tween.tween_property(achievement_indicator, "modulate:a", 1.0, 2)
	tween.tween_callback( _after_message_fadein )

func _after_message_fadein():
	var achievement_indicator = get_node("pivot/camera/achievement_label")
	var tween = create_tween()
	tween.tween_property(achievement_indicator, "modulate:a", 0.0, 2)

# There has been one report of a bug in which the player overlapped the entirity of
# Daedalus at once, thus triggering all unlocks at once and ruining the save file.
# The root cause of this is not yet well understood, so for now this emergency
# failsafe will crash the game upon detecting an "impossible" collision between
# two boxes that are farther away than the size of the player. This hopefully
# should at least prevent save file corruption should this happen again.
func _setup_failsafe_areas():
	var a1 = Area3D.new()
	var a1_shape = CollisionShape3D.new()
	a1_shape.shape = BoxShape3D.new()
	a1.priority = 99999
	a1.add_child(a1_shape)
	var a2 = Area3D.new()
	var a2_shape = CollisionShape3D.new()
	a2_shape.shape = BoxShape3D.new()
	a2.priority = 99999
	a2.add_child(a2_shape)
	var scene = get_node("/root/scene")
	scene.add_child(a1)
	scene.add_child(a2)
	a1.global_position = Vector3(0, 0, 0)
	a2.global_position = Vector3(0, 10, 0)
	a1.body_entered.connect(_failsafe_entered)
	a1.body_exited.connect(_failsafe_exited)
	a2.body_entered.connect(_failsafe_entered)
	a2.body_exited.connect(_failsafe_exited)

func _failsafe_entered(body):
	if body == self:
		failsafe_area_count += 1
		if failsafe_area_count > 1:
			OS.alert("Unrecoverable error detected: please force quit the game and report a bug.")
			# Intentionally infinite loop to avoid any possibility of a save happening.
			while true:
				pass

func _failsafe_exited(body):
	if body == self:
		failsafe_area_count -= 1
