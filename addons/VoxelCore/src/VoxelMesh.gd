tool
extends "res://addons/VoxelCore/src/VoxelObject.gd"
class_name VoxelMesh, 'res://addons/VoxelCore/assets/VoxelMesh.png'



# Declarations
var voxels : Dictionary = {} setget set_voxels



# Core
func _load() -> void: if has_meta('voxels'): voxels = get_meta('voxels')
func _save() -> void: set_meta('voxels', voxels)


func _init() -> void: ._init()
#func _ready() -> void: ._ready()


# Set Voxel as given to grid position, emits 'set_voxel'
# grid     :   Vector3          -   grid position to set Voxel to 
# voxel    :   int/Dictionary   -   Voxel to be set
# update   :   bool             -   call on update
# emit     :   bool             -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel(Vector(11, -34, 2), 3)         #   NOTE: This would store the Voxels ID
#   set_voxel(Vector(11, -34, 2), { ... })
#
func set_voxel(grid : Vector3, voxel, update : bool = false, emit : bool = true) -> void:
	voxels[grid] = voxel
	
	.set_voxel(grid, voxel, update, emit)

# Set raw Voxel data to given grid position, emits 'set_voxel'
# grid     :   Vector3          -   grid position to set Voxel to 
# voxel    :   int/Dictionary   -   Voxel to be set
# update   :   bool             -   call on update
# emit     :   bool             -   true, emit signal; false, don't emit signal
#
# Example:
#   set_rvoxel(Vector(11, -34, 2), 3)         #   NOTE: This would store a copy of the Voxels present Dictionary within the VoxelSet, not the ID itself
#   set_rvoxel(Vector(11, -34, 2), { ... })
#
func set_rvoxel(grid : Vector3, voxel : Dictionary, update : bool = false, emit : bool = true) -> void:
	.set_rvoxel(grid, voxel, update, emit)

# Get Voxel data from grid position
# grid       :   Vector3      -   grid position to get Voxel from
# @returns   :   Dictionary   -   Voxel data
#
# Example:
#   get_voxel(Vector(11, -34, 2))   ->   { ... }
#
func get_voxel(grid : Vector3) -> Dictionary: return .get_voxel(grid)

# Get raw Voxel from grid position
# grid       :   Vector3          -   grid position to get Voxel from
# @returns   :   int/Dictionary   -   raw Voxel
#
# Example:
#   get_rvoxel(Vector(11, -34, 2))   ->   3         #   NOTE: Returned ID representing  Voxel data
#   get_rvoxel(Vector(-7, 0, 96))    ->   { ... }   #   NOTE: Returned Voxel data
#
func get_rvoxel(grid : Vector3): return voxels.get(grid)

# Erase Voxel from grid position, emits 'erased_voxel'
# grid     :   Vector3   -   grid position to erase Voxel from
# update   :   bool      -   call on update
# emit     :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   erase_voxel(Vector(11, -34, 2), false)
#
func erase_voxel(grid : Vector3, update : bool = false, emit : bool = true) -> void:
	voxels.erase(grid)
	
	.erase_voxel(grid, update, emit)


# Clears and replaces all Voxels with given Voxels, emits 'set_voxels'
# voxels   :   Dictionary<Vector3, Voxel>   -   Voxels to set
# update   :   bool                         -   call on update
# emit     :   bool                         -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel({ ... })
#
func set_voxels(_voxels : Dictionary, update : bool = true, emit : bool = true) -> void:
	erase_voxels(emit)
	
	voxels = _voxels.duplicate(true)
	
	if update: update(false, emit)
	if emit: emit_signal('set_voxels')

# Gets all present Voxel positions
# @returns   :   Dictionary<Vector3, Voxel>   -   Dictionary containing grid positions, as keys, and Voxels, as values
#
# Example:
#   get_voxels()   ->   { ... }
#
func get_voxels() -> Dictionary: return voxels

# Erases all present Voxels, emits 'erased_voxels'
# emit     :   bool   -   true, emit signal; false, don't emit signal
# update   :   bool   -   call on update
#
# Example:
#   erase_voxels(false)
#
func erase_voxels(emit : bool = true, update : bool = true) -> void:
	voxels.clear()
	
	if update: update(false, emit)
	if emit: emit_signal('erased_voxels')


func is_valid_face(grid : Vector3, direction : Vector3, used : Array = []) -> bool: return not (voxels.has(grid + direction) or used.has(grid))

func greed(st : SurfaceTool, origin : Vector3, direction : Vector3, directions : Array, used : Array) -> Array:
	used.append(origin)
	
	var origin_voxel = get_voxel(origin)
	var origin_color = Voxel.get_color_side(origin_voxel, direction)
	var origin_texture = Voxel.get_texture_side(origin_voxel, direction)
	
	var g1 = origin
	var g2 = origin
	var g3 = origin
	var g4 = origin
	
	if origin_texture == null:
		var temp = []
		var offset = 1
		var length = 1
		
		while true:
			var temp_grid = g4 + (directions[0] * offset)
			var temp_voxel = get_voxel(temp_grid)
			
			if voxels.has(temp_grid) and is_valid_face(temp_grid, direction, used) and Voxel.get_color_side(temp_voxel, direction) == origin_color:
				offset += 1
				temp.append(temp_grid)
			else: break
		
		used += temp
		length += temp.size()
		g1 += directions[0] * temp.size()
		g3 += directions[0] * temp.size()
		print('moved g1 and g3 :' + str(temp.size()))
		
		temp = []
		offset = 1
		
		while true:
			var temp_grid = g4 + (directions[1] * offset)
			var temp_voxel = get_voxel(temp_grid)
			
			if voxels.has(temp_grid) and is_valid_face(temp_grid, direction, used) and Voxel.get_color_side(temp_voxel, direction) == origin_color:
				offset += 1
				temp.append(temp_grid)
			else: break
		
		used += temp
		length += temp.size()
		g2 += directions[1] * temp.size()
		g4 += directions[1] * temp.size()
		print('moved g2 and g4 :' + str(temp.size()))

		temp = []
		offset = 1

		while true:
			var temp_grid = g4 + (directions[2] * offset)

			var valid = true
			for temp_offset in range(length):
				var _temp_grid = temp_grid + directions[0] * temp_offset
				var temp_voxel = get_voxel(_temp_grid)

				if voxels.has(_temp_grid) and is_valid_face(_temp_grid, direction, used) and Voxel.get_color_side(temp_voxel, direction) == origin_color:
#					offset += 1
					temp.append(_temp_grid)
				else:
					valid = false
					break

			if valid:
				used += temp
				offset += 1
			else: break

		g1 += directions[2] * (offset - 1)
		g2 += directions[2] * (offset - 1)
		print('moved g1 and g2 :' + str(temp.size()))

		temp = []
		offset = 1
		while true:
			var temp_grid = g4 + (directions[3] * offset)

			var valid = true
			for temp_offset in range(length):
				var _temp_grid = temp_grid + directions[0] * temp_offset
				var temp_voxel = get_voxel(_temp_grid)

				if voxels.has(_temp_grid) and is_valid_face(_temp_grid, direction, used) and Voxel.get_color_side(temp_voxel, direction) == origin_color:
#					offset += 1
					temp.append(_temp_grid)
				else:
					valid = false
					break

			if valid:
				used += temp
				offset += 1
			else: break

		g3 += directions[3] * (offset - 1)
		g4 += directions[3] * (offset - 1)
		print('moved g3 and g4 :' + str(temp.size()))
		
		print('---')
	
#	g1 = origin
#	g2 = origin
#	g3 = origin
#	g4 = origin
#	used.clear()
	
	Voxel.generate_side(direction, st, get_voxel(origin), g1, g2, g3, g4)
	
	return used

# Updates mesh and StaticBody, emits 'updated'
# temp   :   bool   -   true, build temporary StaticBody; false, don't build temporary StaticBody
# emit   :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   update(false)
#
func update(temp : bool = false, emit : bool = true) -> void:
	if voxels == null: return;
	if voxels.size() > 0:
		var ST = SurfaceTool.new()
		ST.begin(Mesh.PRIMITIVE_TRIANGLES)
		var material = SpatialMaterial.new()
		material.roughness = 1
		material.vertex_color_is_srgb = true
		material.vertex_color_use_as_albedo = true
		ST.set_material(material)
		
		if Greedy:
			print('GREEDY')
			var rights = []
			var right_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ] # ok
			var lefts = []
			var left_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ] # ok?
			var ups = []
			var up_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT ] # ok?
			var downs = []
			var down_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT ] # ok
			var backs = []
			var back_directions = [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ] # ok?
			var forwards = []
			var forward_directions = [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ] # ok
			
			for voxel_grid in voxels:
				if is_valid_face(voxel_grid, Vector3.RIGHT, rights): rights = greed(ST, voxel_grid, Vector3.RIGHT, right_directions, rights)
				if is_valid_face(voxel_grid, Vector3.LEFT, lefts): lefts = greed(ST, voxel_grid, Vector3.LEFT, left_directions, lefts)
				if is_valid_face(voxel_grid, Vector3.UP, ups): ups = greed(ST, voxel_grid, Vector3.UP, up_directions, ups)
				if is_valid_face(voxel_grid, Vector3.DOWN, downs): downs = greed(ST, voxel_grid, Vector3.DOWN, down_directions, downs)
				if is_valid_face(voxel_grid, Vector3.BACK, backs): backs = greed(ST, voxel_grid, Vector3.BACK, back_directions, backs)
				if is_valid_face(voxel_grid, Vector3.FORWARD, forwards): forwards = greed(ST, voxel_grid, Vector3.FORWARD, forward_directions, forwards)
		else:
			for voxel_grid in voxels:
				if not voxels.has(voxel_grid + Vector3.RIGHT): Voxel.generate_right(ST, get_voxel(voxel_grid), voxel_grid)
				if not voxels.has(voxel_grid + Vector3.LEFT): Voxel.generate_left(ST, get_voxel(voxel_grid), voxel_grid)
				if not voxels.has(voxel_grid + Vector3.UP): Voxel.generate_up(ST, get_voxel(voxel_grid), voxel_grid)
				if not voxels.has(voxel_grid + Vector3.DOWN): Voxel.generate_down(ST, get_voxel(voxel_grid), voxel_grid)
				if not voxels.has(voxel_grid + Vector3.BACK): Voxel.generate_back(ST, get_voxel(voxel_grid), voxel_grid)
				if not voxels.has(voxel_grid + Vector3.FORWARD): Voxel.generate_forward(ST, get_voxel(voxel_grid), voxel_grid)
		
		ST.index()
		mesh = ST.commit()
	else: mesh = null
	
	.update(temp, emit)

# Sets and updates static trimesh body, emits 'updated_staticbody'
# temp   :   bool   -   true, build temporary StaticBody; false, don't build temporary StaticBody
# emit   :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   update_staticbody(false)
#
func update_staticbody(temp : bool = false, emit : bool = true) -> void:
	var staticbody
	if has_node('StaticBody'): staticbody = get_node('StaticBody')
	
	if (temp or Static_Body) and mesh and voxels.size() > 0:
		var collisionshape
		if not staticbody:
			staticbody = StaticBody.new()
			staticbody.set_name('StaticBody')
		
		if staticbody.has_node('CollisionShape'):
			collisionshape = staticbody.get_node('CollisionShape')
		else:
			collisionshape = CollisionShape.new()
			collisionshape.set_name('CollisionShape')
			staticbody.add_child(collisionshape)
		
		collisionshape.shape = mesh.create_trimesh_shape()
		
		if not has_node('StaticBody'): add_child(staticbody)
		
		if Static_Body and not staticbody.owner: staticbody.set_owner(get_tree().get_edited_scene_root())
		if Static_Body and not collisionshape.owner: collisionshape.set_owner(get_tree().get_edited_scene_root())
	elif ((not temp and not Static_Body) or voxels.size() <= 0) and staticbody:
		remove_child(staticbody)
		staticbody.queue_free()
	
	.update_staticbody(emit)
