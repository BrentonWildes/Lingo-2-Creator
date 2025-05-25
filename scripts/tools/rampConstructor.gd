@tool
extends Node3D

const runtimescriptpath:String = "res://scripts/nodes/ramp.gd"
const swaphelperscriptpath:String = "res://scripts/tools/swapHelper.gd"
const collision_prevent_skip_factor = 2.0
const collision_prevent_capture_factor = 1.5

var runtimescript
var swaphelperscript 

@export var create_ramps = false: set=_set_ramps_in_editor 

@export_range(5, 7200, 5) var degrees_of_rotation= 90
@export var skew:float = 0
enum wall_gen{Outside, Inside, None}
@export var build_walls:wall_gen = wall_gen.Outside
enum collision_areas{inside, outside, both}
@export var build_collision:collision_areas = collision_areas.inside
enum collision_shapes{boxes, tube, concavepolygons_slow}
@export var shape_of_collisions:collision_shapes = collision_shapes.boxes
enum collision_extent{prevent_skipping,prevent_capturing}
@export var outside_collision_size:collision_extent = collision_extent.prevent_skipping



enum gravity_snaps{Nearest_by_degree, Favour_Base_by_degree, Favour_Wall_by_degree, Nearest_by_distance, Favour_Base_by_distance, Favour_Wall_by_distance, Custom_Up, Do_Not_Snap}
@export var snap_gravity_on_leaving_ramp:gravity_snaps = gravity_snaps.Nearest_by_degree
@export var custom_up:Vector3 = Vector3(0,1,0)

enum velocity_grabs{Only_walking, Walking_and_running, Always}
@export var velocity_restrictions:velocity_grabs = velocity_grabs.Walking_and_running

@export var gravity_inside_points_towards_centre:bool = false
enum angle_grabs{Within_30, Within_90, Always}
@export var angle_restrictions:angle_grabs = angle_grabs.Within_30
@export var ramp_cannon:bool = false

var gone_through_ready:bool = false


func _ready()->void:
	runtimescript = load(runtimescriptpath)
	swaphelperscript = load(swaphelperscriptpath)
	gone_through_ready = true

func _set_ramps_in_editor(_value)->void:
	if Engine.is_editor_hint() and gone_through_ready:
		create_ramps=false
		#get rid of any add'l collision shapes we created.
		
		for child in $ActivationInside.get_children():
			child.queue_free()
		for child in $ActivationOutside.get_children():
			child.queue_free()
		
		
		
		if shape_of_collisions == collision_shapes.boxes:
			make_box_collision()
		elif shape_of_collisions == collision_shapes.tube:
			make_tube_collision()
		elif shape_of_collisions == collision_shapes.concavepolygons_slow:
			make_concave_collision()
		
		
		generate_ramp()
		$StaticBody3D/CollisionShape3D.shape = $"programmatic ramp".mesh.create_trimesh_shape()
		$StaticBody3D/CollisionShape3D.shape.backface_collision = true
		$StaticBody3D/CollisionShape3D.shape.margin = 0.1
		get_parent().set_editable_instance(self, true)
		$"programmatic ramp".set_script(swaphelperscript)
		$"programmatic ramp".swap_helper(runtimescript)

func generate_array_mesh(walls):
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()

	var points = degrees_of_rotation/5.0

	for i in points+1:
		var vert = Vector3(0,-3.95,-0.5 + skew * i/points)
		var vert2 = Vector3(0,-3.95,0.5+ skew * i/points)
		var vert3 = Vector3(0,-4.0,-0.5 + skew * i/points)
		var vert4 = Vector3(0,-4.0,0.5 + skew * i/points)
		
		vert = vert.rotated(Vector3(0,0,1), -i*PI/36)
		vert2 = vert2.rotated(Vector3(0,0,1), -i*PI/36)
		vert3= vert3.rotated(Vector3(0,0,1), -i*PI/36)
		vert4 = vert4.rotated(Vector3(0,0,1), -i*PI/36)

		vert += Vector3(0,4,0)
		vert2 += Vector3(0,4,0)
		vert3 += Vector3(0,4,0)
		vert4 += Vector3(0,4,0)
		
		if walls == wall_gen.Outside:
			if int(i) % 72 <= 18:
				vert.y = 0
				vert2.y = 0
			elif int(i) % 72 <= 36:
				vert.x = -4
				vert2.x = -4
			elif int(i) % 72 <= 54:
				vert.y = 8
				vert2.y = 8
			elif int(i) % 72 <= 72:
				vert.x = 4
				vert2.x = 4
		elif walls == wall_gen.Inside:
			vert3.x = 0
			vert4.x = 0
			vert3.y = 4
			vert4.y = 4
		#random flag unlikely to be captured by a growing enum
		elif walls == 69:
			var limits
			if outside_collision_size == collision_extent.prevent_capturing:
				limits = collision_prevent_capture_factor
			elif outside_collision_size == collision_extent.prevent_skipping:
				limits = collision_prevent_skip_factor
			vert -= Vector3(0,4,0)
			vert2 -= Vector3(0,4,0)
			vert.x *= limits
			vert2.x *= limits
			vert.y *= limits
			vert2.y *= limits
			vert += Vector3(0,4,0)
			vert2 += Vector3(0,4,0)
			
		verts.append(vert)
		verts.append(vert2)
		verts.append(vert3)
		verts.append(vert4)


		normals.append(vert.normalized())
		normals.append(vert2.normalized())
		normals.append(vert3.normalized())
		normals.append(vert4.normalized())

		if i == 0:
			indices.append(i*4)
			indices.append(i*4+1)
			indices.append(i*4+2)
			indices.append(i*4+2)
			indices.append(i*4+1)
			indices.append(i*4+3)
		if i == points:
			indices.append(i*4+2)
			indices.append(i*4+1)
			indices.append(i*4)
			indices.append(i*4+3)
			indices.append(i*4+1)
			indices.append(i*4+2)
		
		
		#uv should wrap twice for a 90degree, and then tile.
		#90 degrees has 18 points
		var uv_constant = 18

		uvs.append(Vector2(0,i/uv_constant))
		uvs.append(Vector2(0.3333,i/uv_constant))
		
		uvs.append(Vector2(0.6666,(1.0/i)*(1-(i/uv_constant))+i/(uv_constant+1)))
		uvs.append(Vector2(1.0,(1.0/i)*(1-(i/uv_constant))+i/(uv_constant+1)))
		

		if i > 0:
			var p0 = (i-1)*4
			var p1 = p0 + 1
			var p2 = p0 + 2
			var p3 = p0 + 3
			var p4 = p0 + 4
			var p5 = p0 + 5
			var p6 = p0 + 6
			var p7 = p0 + 7
			#left side quad
			indices += PackedInt32Array([p0, p2, p4])
			indices += PackedInt32Array([p4, p2, p6])
			#right side quad
			indices += PackedInt32Array([p5, p3, p1])
			indices += PackedInt32Array([p7, p3, p5])
			#top side quad
			indices += PackedInt32Array([p2, p3, p6])
			indices += PackedInt32Array([p6, p3, p7])
			#bottom side quad
			indices += PackedInt32Array([p4, p1, p0])
			indices += PackedInt32Array([p5, p1, p4])
			

	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	return surface_array


func generate_ramp()->void:
	$"programmatic ramp".mesh =$"programmatic ramp".mesh.duplicate()
	$"programmatic ramp".mesh.clear_surfaces()
	$"programmatic ramp".mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, generate_array_mesh(build_walls))

func make_concave_collision():
	if build_collision == collision_areas.inside or build_collision == collision_areas.both:
		var mesh = ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, generate_array_mesh(wall_gen.Inside))
		var mesh3d = MeshInstance3D.new()
		mesh3d.mesh = mesh
		var convexsettings = MeshConvexDecompositionSettings.new()
		convexsettings.max_convex_hulls = 180
		convexsettings.max_concavity = 0.0001
		mesh3d.create_multiple_convex_collisions(convexsettings)
		for staticbody in mesh3d.get_children():
			for child in staticbody.get_children():
				staticbody.remove_child(child)
				$ActivationInside.add_child(child)
				child.owner = get_tree().edited_scene_root
	if build_collision == collision_areas.outside or build_collision == collision_areas.both:
		var mesh = ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, generate_array_mesh(69))
		var mesh3d = MeshInstance3D.new()
		mesh3d.mesh = mesh
		var convexsettings = MeshConvexDecompositionSettings.new()
		convexsettings.max_convex_hulls = 180
		convexsettings.max_concavity = 0.0001
		mesh3d.create_multiple_convex_collisions(convexsettings)
		for staticbody in mesh3d.get_children():
			for child in staticbody.get_children():
				staticbody.remove_child(child)
				$ActivationOutside.add_child(child)
				child.owner = get_tree().edited_scene_root

func make_tube_collision():
	if build_collision == collision_areas.inside or build_collision == collision_areas.both:
		var temp = CollisionShape3D.new()
		temp.shape = CylinderShape3D.new()
		$ActivationInside.add_child(temp)
		temp.owner = get_tree().edited_scene_root
		temp.shape.height = abs(skew) + 1.0
		temp.shape.radius = 4
		temp.transform.origin = Vector3(0,4,skew/2.0)
		temp.rotation = Vector3(PI/2,0,0)
	if build_collision == collision_areas.outside or build_collision == collision_areas.both:
		var temp = CollisionShape3D.new()
		temp.shape = CylinderShape3D.new()
		$ActivationOutside.add_child(temp)
		temp.owner = get_tree().edited_scene_root
		temp.shape.height = abs(skew) + 1.0
		if outside_collision_size == collision_extent.prevent_capturing:
			temp.shape.radius = 4 + 2 * collision_prevent_capture_factor
		elif outside_collision_size == collision_extent.prevent_skipping:
			temp.shape.radius = 4 + 2 * collision_prevent_skip_factor
			#big number why? Because with cylindrical gravity, moving forward means moving off the curve, which can make for big jumps. 
			#A second reason is jumping over a cylindrical area from the side.
			#which is a good reason not to use capsule shapes, too!
		temp.transform.origin = Vector3(0,4,skew/2.0)
		temp.rotation = Vector3(PI/2,0,0)
	
	
	


func make_box_collision():
	if build_collision == collision_areas.inside or build_collision == collision_areas.both:
		var temp = CollisionShape3D.new()
		temp.shape = BoxShape3D.new()

		var skewPer = skew / (degrees_of_rotation/90.0)
		for recurse in ceil(degrees_of_rotation/360.0):
			var degreescurrent
			if recurse < ceil(degrees_of_rotation/360.0) -1:
				degreescurrent = 360
			else:
				degreescurrent = degrees_of_rotation - recurse * 360
			var vert = Vector3(0,-4.0,0.0)
			vert = vert.rotated(Vector3(0,0,1), deg_to_rad(degreescurrent))
			var side_length = vert.distance_to(Vector3(0,-4,0))
			var basetriangle = deg_to_rad(90 -(180-degreescurrent)/2.0)
			var height = side_length*sin(basetriangle)
			var length = side_length*cos(basetriangle)
			var width = 1 + abs(skewPer)
			var temp1 = temp.duplicate()
			$ActivationInside.add_child(temp1)
			temp1.owner = get_tree().edited_scene_root
			temp1.name = "BoxA"
			if degreescurrent <= 90:
				temp1.shape.size = Vector3(length,height,width) 
				temp1.transform.origin = Vector3(-length*0.5,height/2,recurse * 4.0 * skewPer + skewPer/2 * degreescurrent/90)
				break
			temp1.shape.size = Vector3(3.75,4,1 + abs(skewPer)) 
			temp1.transform.origin = Vector3(-2, 2, recurse * 4.0 * skewPer + skewPer/2)
			
			var temp2 = temp.duplicate()
			$ActivationInside.add_child(temp2)
			temp2.owner = get_tree().edited_scene_root
			#if I don't duplicate the shape, my collisions will share the same one
			temp2.shape = temp2.shape.duplicate()
			temp2.name = "BoxB"
			var degreesafter = degreescurrent - 90
			
			vert = Vector3(0,-4.0,0.0)
			vert = vert.rotated(Vector3(0,0,1), deg_to_rad(degreesafter))
			side_length = vert.distance_to(Vector3(0,-4,0))
			basetriangle = deg_to_rad(90 -(180-degreesafter)/2.0)
			height = side_length*cos(basetriangle) + 4
			length = side_length*sin(basetriangle)
			width = 1 + abs(skewPer) * degreesafter/degreescurrent
			temp2.shape.size = Vector3(length, height,width) 
			temp2.transform.origin = Vector3(-4+length/2,height/2,  recurse * 4.0 * skewPer + skewPer + skewPer/2 * degreesafter/90)
			
			if degreescurrent < 180:
				break
			temp2.shape.size = Vector3(3.75,4,1+abs(skewPer))
			temp2.transform.origin = Vector3(-2,6, recurse * 4.0 * skewPer +3.0* skewPer/2.0)
			var temp3 = temp.duplicate()
			$ActivationInside.add_child(temp3)
			temp3.owner = get_tree().edited_scene_root
			temp3.shape = temp.shape.duplicate()
			temp3.name = "BoxC"
			degreesafter = degreescurrent - 180
			vert = Vector3(0,-4.0,0.0)
			vert = vert.rotated(Vector3(0,0,1), deg_to_rad(degreesafter))
			side_length = vert.distance_to(Vector3(0,-4,0))
			basetriangle = deg_to_rad(90 -(180-degreesafter)/2.0)
			height = side_length*sin(basetriangle)
			length = side_length*cos(basetriangle) 
			width = 1 + abs(skewPer) * degreesafter/degreescurrent
			temp3.shape.size = Vector3(length,height,width) 
			temp3.transform.origin = Vector3(length/2,8-(height/2), recurse * 4.0 * skewPer + 2*skewPer + skewPer/2 * degreesafter/90)
			if degreescurrent < 270:
				break
			temp3.shape.size = Vector3(3.75,4,1+abs(skewPer) *90.0/degreescurrent)
			temp3.transform.origin = Vector3(2,6, recurse * 4.0 * skewPer + 5*skewPer/2)
			var temp4 = temp.duplicate()
			$ActivationInside.add_child(temp4)
			temp4.owner = get_tree().edited_scene_root
			temp4.shape = temp.shape.duplicate()
			temp4.name = "BoxD"
			degreesafter = degreescurrent - 270
			vert = Vector3(0,-4.0,0.0)
			vert = vert.rotated(Vector3(0,0,1), deg_to_rad(degreesafter))
			side_length = vert.distance_to(Vector3(0,-4,0))
			basetriangle = deg_to_rad(90 -(180-degreesafter)/2.0)
			height = side_length*cos(basetriangle)
			length = side_length*sin(basetriangle)
			width = 1 + abs(skewPer) * degreesafter/degreescurrent
			temp4.shape.size = Vector3(length,height,width) 
			temp4.transform.origin = Vector3(4-length/2,4-(height/2), recurse * 4.0 * skewPer + 3*skewPer + skewPer/2 * degreesafter/90)
	if build_collision == collision_areas.outside or build_collision == collision_areas.both:
		var temp = CollisionShape3D.new()
		temp.shape = BoxShape3D.new()
		var limits 
		if outside_collision_size == collision_extent.prevent_capturing:
			limits = collision_prevent_capture_factor
		elif outside_collision_size == collision_extent.prevent_skipping:
			limits = collision_prevent_skip_factor

		var skewPer = skew / (degrees_of_rotation/90.0)
		for recurse in ceil(degrees_of_rotation/360.0):
			var degreescurrent
			if recurse < ceil(degrees_of_rotation/360.0) -1:
				degreescurrent = 360
			else:
				degreescurrent = degrees_of_rotation - recurse * 360
			var vert = Vector3(0,-4.0,0.0)
			vert = vert.rotated(Vector3(0,0,1), deg_to_rad(degreescurrent))
			var side_length = vert.distance_to(Vector3(0,-4,0))
			var basetriangle = deg_to_rad(90 -(180-degreescurrent)/2.0)
			var height = limits*side_length*sin(basetriangle)
			var length = limits*side_length*cos(basetriangle)
			var width = 1 + abs(skewPer)
			var temp1 = temp.duplicate()
			$ActivationOutside.add_child(temp1)
			temp1.owner = get_tree().edited_scene_root
			temp1.name = "BoxA"
			if degreescurrent <= 90:
				temp1.shape.size = Vector3(length,height,width) 
				temp1.transform.origin = Vector3(-length*0.5,height/2,recurse * 4.0 * skewPer + skewPer/2 * degreescurrent/90)
				break
			temp1.shape.size = Vector3(limits*4 - 0.25,limits*4,1 + abs(skewPer)) 
			temp1.transform.origin = Vector3(limits * -2, limits*2, recurse * 4.0 * skewPer + skewPer/2)
			
			var temp2 = temp.duplicate()
			$ActivationOutside.add_child(temp2)
			temp2.owner = get_tree().edited_scene_root
			#if I don't duplicate the shape, my collisions will share the same one
			temp2.shape = temp2.shape.duplicate()
			temp2.name = "BoxB"
			var degreesafter = degreescurrent - 90
			
			vert = Vector3(0,-4.0,0.0)
			vert = vert.rotated(Vector3(0,0,1), deg_to_rad(degreesafter))
			side_length = vert.distance_to(Vector3(0,-4,0))
			basetriangle = deg_to_rad(90 -(180-degreesafter)/2.0)
			height = limits*(side_length*cos(basetriangle) + 4)
			length = limits*(side_length*sin(basetriangle))
			width = 1 + abs(skewPer) * degreesafter/degreescurrent
			temp2.shape.size = Vector3(length, height,width) 
			temp2.transform.origin = Vector3(-4+length/2,height/2,  recurse * 4.0 * skewPer + skewPer + skewPer/2 * degreesafter/90)
			
			if degreescurrent < 180:
				break
			temp2.shape.size = Vector3(limits*4 - 0.25,limits*4,1+abs(skewPer))
			temp2.transform.origin = Vector3(limits*-2,limits * 2 + 4, recurse * 4.0 * skewPer +3.0* skewPer/2.0)
			var temp3 = temp.duplicate()
			$ActivationOutside.add_child(temp3)
			temp3.owner = get_tree().edited_scene_root
			temp3.shape = temp.shape.duplicate()
			temp3.name = "BoxC"
			degreesafter = degreescurrent - 180
			vert = Vector3(0,-4.0,0.0)
			vert = vert.rotated(Vector3(0,0,1), deg_to_rad(degreesafter))
			side_length = vert.distance_to(Vector3(0,-4,0))
			basetriangle = deg_to_rad(90 -(180-degreesafter)/2.0)
			height = limits*side_length*sin(basetriangle)
			length = limits*side_length*cos(basetriangle) 
			width = 1 + abs(skewPer) * degreesafter/degreescurrent
			temp3.shape.size = Vector3(length,height,width) 
			temp3.transform.origin = Vector3(length/2,8-(height/2), recurse * 4.0 * skewPer + 2*skewPer + skewPer/2 * degreesafter/90)
			if degreescurrent < 270:
				break
			temp3.shape.size = Vector3(limits*4-0.25,limits*4,1+abs(skewPer) *90.0/degreescurrent)
			temp3.transform.origin = Vector3(limits*2,limits*2 + 4, recurse * 4.0 * skewPer + 5*skewPer/2)
			var temp4 = temp.duplicate()
			$ActivationOutside.add_child(temp4)
			temp4.owner = get_tree().edited_scene_root
			temp4.shape = temp.shape.duplicate()
			temp4.name = "BoxD"
			degreesafter = degreescurrent - 270
			vert = Vector3(0,-4.0,0.0)
			vert = vert.rotated(Vector3(0,0,1), deg_to_rad(degreesafter))
			side_length = vert.distance_to(Vector3(0,-4,0))
			basetriangle = deg_to_rad(90 -(180-degreesafter)/2.0)
			height = limits*side_length*cos(basetriangle)
			length = limits*side_length*sin(basetriangle)
			width = 1 + abs(skewPer) * degreesafter/degreescurrent
			temp4.shape.size = Vector3(length,height,width) 
			temp4.transform.origin = Vector3(4-length/2,4-(height/2), recurse * 4.0 * skewPer + 3*skewPer + skewPer/2 * degreesafter/90)
