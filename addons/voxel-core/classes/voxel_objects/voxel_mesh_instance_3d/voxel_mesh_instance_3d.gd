@tool
@icon("res://addons/voxel-core/classes/voxel_objects/voxel_mesh_instance_3d/voxel_mesh_instance_3d.svg")
class_name VoxelMeshInstance3D
extends MeshInstance3D
## Voxel visualization object, for a moderate amount of voxels;
## part of Voxel-Core.
##
## VoxelMeshInstance3D is the most basic voxel visualization object provided 
## by Voxel-Core, and is intended to be used to visualize a moderate amount of 
## voxels. Voxel visualization object work together with [VoxelSet]s and 
## [Voxel]s to visualize any user defined content (e.g. terrain, characters, etc.)
## [br]
## [codeblock]
## # Create a new VoxelMeshInstance3D instance
## var voxel_mesh : VoxelMeshInstance3D = VoxelMeshInstance3D.new()
## 
## # Create a new VoxelSet resource
## var voxel_set : VoxelSet = VoxelSet.new()
##
## # Assign the VoxelSet a texture
## voxel_set.texture = preload("res://texture.png")
## 
## # Create a new Voxel
## var voxel : Voxel = Voxel.new()
## # Name the Voxel
## voxel.name = "dirt grass"
## # Set the Voxel's faces color
## voxel.color = Color.BROWN
## voxel.color_top = Color.GREEN
## # Set the Voxel's faces texture uvs
## voxel.texture_uv = Vector2(0, 0)
## voxel.texture_uv_top = Vector2(1, 0)
##
## # Add the Voxel to the VoxelSet
## var voxel_id : int = voxel_set.add_voxel(voxel)
##
## # Assign VoxelSet to VoxelMeshInstance3D
## voxel_mesh.voxel_set = voxel_set
##
## # Place a few voxels within the VoxelMeshInstance3D to visualize
## voxel_mesh.add_voxel(Vector3i(0, 0, 0), voxel_id)
## voxel_mesh.add_voxel(Vector3i(1, 0, 0), voxel_id)
## voxel_mesh.add_voxel(Vector3i(1, 0, 1), voxel_id)
## voxel_mesh.add_voxel(Vector3i(0, 0, 1), voxel_id)
##
## # Update the VoxelMeshInstance3D's mesh
## voxel_mesh.update()
## [/codeblock]



# Signals
## Emited with [VoxelSet] changed.
signal voxel_set_changed



# Exported Variables
## Determines the size of the three-dimensional space in which the voxels can
## be arranged. (width, height, depth)
@export
var shape : Vector3i = Vector3i(32, 32, 32) :
	get = get_shape,
	set = set_shape

## Defines the coordinates of the bottom-back-left corner of the 
## three-dimensional space.
@export
var origin : Vector3 = Vector3(0, 0, 0) :
	get = get_origin,
	set = set_origin

## Algorithm used to generate voxel mesh, refrence 
## [member VoxelSurfaceTool.MeshModes].
@export
var mesh_type : VoxelSurfaceTool.MeshType = \
		VoxelSurfaceTool.MeshType.NAIVE :
	get = get_mesh_type,
	set = set_mesh_type

## Defines the size of individual voxels relative to the scale of their parent.
@export_range(0.01, 1.0, 0.01,"or_greater")
var voxel_size : float = 0.25 :
	get = get_voxel_size,
	set = set_voxel_size

## When enabled, UV textured voxels will be generated.
## When disabled, voxels will be generated without UV texturing.
@export
var voxel_textured : bool = false :
	get = get_voxel_textured,
	set = set_voxel_textured

## VoxelSet used to generate voxel mesh.
@export
var voxel_set : VoxelSet = null :
	get = get_voxel_set,
	set = set_voxel_set



# Private Variables
# Collection of used voxels [Dictionary[Vector3i, int]].
var _voxels : Dictionary = {}



# Built-In Virtual Methods
func _get(property : StringName):
	match str(property):
		"voxels":
			return _voxels
	return null


func _set(property : StringName, value):
	match str(property):
		"voxels":
			_voxels = value
			return true
	return false


func _get_property_list():
	return [
		{
			"name": "voxels",
			"type": TYPE_DICTIONARY,
			"usage": PROPERTY_USAGE_STORAGE,
		},
	]



# Public Methods
## Returns [member shape].
func get_shape() -> Vector3i:
	return shape


## Sets [member shape]; and, if in engine, calls on [method update].
func set_shape(
		new_shape : Vector3i) -> void:
	new_shape = new_shape.clamp(Vector3i(1, 1, 1), Vector3i(128, 128, 128))
	
	var new_voxels : Dictionary = {}
	
	for x in range(min(shape.x, new_shape.x)):
		for y in range(min(shape.y, new_shape.y)):
			for z in range(min(shape.z, new_shape.z)):
				var voxel_position : Vector3i = Vector3i(x, y, z)
				new_voxels[voxel_position] = get_voxel(voxel_position)
	
	shape = new_shape
	_voxels = new_voxels
	
	if Engine.is_editor_hint():
		update()


## Returns [member origin].
func get_origin() -> Vector3:
	return origin


## Sets [member origin]; and, if in engine, calls on [method update].
func set_origin(
		new_origin : Vector3) -> void:
	origin = new_origin.clamp(Vector3(0, 0, 0), Vector3(shape))
	
	if Engine.is_editor_hint():
		update()


## Returns [member mesh_type].
func get_mesh_type() -> VoxelSurfaceTool.MeshType:
	return mesh_type


## Sets [member mesh_type]; and, if in engine, calls on [method update].
func set_mesh_type(
		new_mesh_type : VoxelSurfaceTool.MeshType) -> void:
	mesh_type = new_mesh_type
	
	if Engine.is_editor_hint():
		update()


## Returns [member voxel_size].
func get_voxel_size() -> float:
	return voxel_size


## Sets [member voxel_size]; and, if in engine, calls on [method update].
func set_voxel_size(new_voxel_size : float) -> void:
	voxel_size = new_voxel_size
	
	if Engine.is_editor_hint():
		update()


## Returns [member voxel_textured].
func get_voxel_textured() -> bool:
	return voxel_textured


## Sets [member voxel_textured]; and, if in engine, calls on [method update].
func set_voxel_textured(new_voxel_textured : bool) -> void:
	voxel_textured = new_voxel_textured
	
	if Engine.is_editor_hint():
		update()


## Returns [member voxel_set].
func get_voxel_set() -> VoxelSet:
	return voxel_set


## Sets [member voxel_set]; and, if in engine, calls on [method update].
func set_voxel_set(new_voxel_set : VoxelSet) -> void:
	voxel_set = new_voxel_set
	
	voxel_set_changed.emit()
	
	if Engine.is_editor_hint():
		update()


func has_voxel_set() -> bool:
	return is_instance_valid(voxel_set)


## Returns the corresponding voxel id at the given [code]voxel_position[/code]. 
## If no voxel id is found at given [code]voxel_position[/code], 
## returns [code]-1[/code].
func get_voxel_id(voxel_position : Vector3i) -> int:
	return _voxels.get(voxel_position) or -1


## Returns the corresponding [Voxel] from the assigned [member voxel_set], 
## in refrence to the voxel id at the given [code]voxel_position[/code]. 
## If no [Voxel] is found at given [code]voxel_position[/code], 
## returns [code]null[/code].
func get_voxel(voxel_position : Vector3i) -> Voxel:
	if not is_instance_valid(voxel_set):
		return null
	return voxel_set.get_voxel(get_voxel_id(voxel_position))


## Returns a [Dictionary] of all used voxels; where, keys 
## are voxel positions and voxel ids are values.
func get_voxels() -> Dictionary:
	return _voxels.duplicate()


## Returns a list of used voxel positions [Array[Vector3i]].
func get_voxel_positions() -> Array:
	return _voxels.keys()


## Returns a list of used voxel ids [Array[int]].
func get_voxel_ids() -> Array:
	return _voxels.values()


## Assigns the given [code]voxel_id[/code] at the given 
## [code]voxel_position[/code].
func set_voxel(voxel_position : Vector3i, voxel_id : int) -> void:
	_voxels[voxel_position] = voxel_id


## Replaces used voxels with the given [code]new_voxels[/code]; where, keys 
## are voxel positions and values are voxel ids.
func set_voxels(new_voxels : Dictionary) -> void:
	for voxel_position in new_voxels:
		if not voxel_position is Vector3i:
			push_error("Invalid voxel_position to be set")
			return
		if not new_voxels[voxel_position] is int:
			push_error("Invalid voxel_id to be set")
			return
	_voxels = new_voxels


## Erases the voxel at [code]voxel_position[/code] if exists. Returns 
## [code]true[/code] if a voxel id existed at [code]voxel_position[/code]; 
## otherwise, returns [code]false[/code].
func erase_voxel(voxel_position : Vector3i) -> bool:
	return _voxels.erase(voxel_position)


## Erases all used voxels.
func erase_voxels() -> void:
	_voxels.clear()


func has_voxel_at(voxel_position : Vector3i) -> bool:
	return _voxels.has(voxel_position)


## Returns [code]true[/code] if voxels are present; 
## otherwise, returns [code]false[/code].
func has_voxels() -> bool:
	return not _voxels.is_empty()


## Returns the number of voxels used.
func get_voxel_count() -> int:
	return _voxels.size()


## Updates voxel mesh with currently used voxels.
func update() -> void:
	if not has_voxel_set():
		push_warning("Trying to update VoxelMeshInstance3D with no VoxelSet attached!")
		mesh = null
		return
	
	var voxel_surface_tool : VoxelSurfaceTool = VoxelSurfaceTool.new()
	voxel_surface_tool.set_offset(-origin * voxel_size)
	voxel_surface_tool.create_from(self, mesh_type)
	mesh = voxel_surface_tool.commit()


func world_position_to_voxel_position(world_position : Vector3) -> Vector3i:
	return Vector3i((to_local(world_position) / voxel_size).floor())


func raycast(
		from_world_position : Vector3,
		direction : Vector3,
		length : float = 100) -> Dictionary:
	var result : Dictionary = {}
	
	var to_world_position : Vector3 = from_world_position + direction * length
	var to_from_delta : Vector3 = to_world_position - from_world_position
	var to_from_delta_frac : Vector3 = to_from_delta - to_from_delta.floor()
	
	var dx : int = sign(to_from_delta.x)
	var delta_x : float = \
			min(dx / to_from_delta.x, 10000000) if dx != 0 else 10000000
	var max_x : float = \
			delta_x * (1.0 - to_from_delta_frac.x) if dx > 0 else delta_x * to_from_delta_frac.x
	
	var dy : int = sign(to_from_delta.y)
	var delta_y : float = \
			min(dy / to_from_delta.y, 10000000) if dy != 0 else 10000000
	var max_y : float = \
			delta_y * (1.0 - to_from_delta_frac.y) if dy > 0 else delta_y * to_from_delta_frac.y
	
	var dz : int = sign(to_from_delta.z)
	var delta_z : float = \
			min(dz / to_from_delta.z, 10000000) if dz != 0 else 10000000
	var max_z : float = \
			delta_z * (1.0 - to_from_delta_frac.z) if dz > 0 else delta_z * to_from_delta_frac.z
	
	var step_direction : int = -1
	var current_voxel_position : Vector3i = \
			world_position_to_voxel_position(from_world_position)
	while not (max_x > 1.0 and max_y > 1.0 and max_z > 1.0):
		var voxel_id : int = get_voxel_id(current_voxel_position)
		
		if voxel_id > -1:
			var hit_voxel_face : Vector3i = Vector3i.ZERO
			if step_direction == 0:
				hit_voxel_face.x = -dx
			elif step_direction == 1:
				hit_voxel_face.y = -dy
			elif step_direction == 2:
				hit_voxel_face.z = -dz
			
			return {
				"hit_voxel_position": current_voxel_position,
				"hit_voxel_face": hit_voxel_face
			}
		
		if max_x < max_y:
			if max_x < max_z:
				current_voxel_position.x += dx
				max_x += delta_x
				step_direction = 0
			else:
				current_voxel_position.z += dz
				max_z += delta_z
				step_direction = 2
		else:
			if max_y < max_z:
				current_voxel_position.y += dy
				max_y += delta_y
				step_direction = 1
			else:
				current_voxel_position.z += dz
				max_z += delta_z
				step_direction = 2
	
	return result
