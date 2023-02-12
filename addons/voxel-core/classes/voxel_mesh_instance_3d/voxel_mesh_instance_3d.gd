@tool
@icon("res://addons/voxel-core/classes/voxel_mesh_instance_3d/voxel_mesh_instance_3d.svg")
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



# Exported Variables
## Algorithm used to generate voxel mesh, refrence 
## [member VoxelSurfaceTool.MeshModes].
@export
var voxel_mesh_type : VoxelSurfaceTool.VoxelMeshType = VoxelSurfaceTool.VoxelMeshType.NAIVE :
	get = get_voxel_mesh_type,
	set = set_voxel_mesh_type

## Size of voxels relative to the parents scale.
@export_range(0.01, 1.0, 0.01,"or_greater")
var voxel_size : float = 0.25 :
	get = get_voxel_size,
	set = set_voxel_size

## Enabled will generate uv textured voxels; disabled will generate voxels 
## without uv texturing.
@export
var voxels_textured : bool = false :
	get = get_voxels_textured,
	set = set_voxels_textured

## VoxelSet used to generate voxel mesh.
@export
var voxel_set : VoxelSet = null :
	get = get_voxel_set,
	set = set_voxel_set



# Private Variables
## Collection of used voxels; key is voxel's position and 
## value is voxel's id in reference to VoxelSet
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
## Returns [member voxel_mesh_type].
func get_voxel_mesh_type() -> VoxelSurfaceTool.VoxelMeshType:
	return voxel_mesh_type


## Sets [member voxel_mesh_type]; and, if in engine, calls on [method update].
func set_voxel_mesh_type(new_voxel_mesh_type : VoxelSurfaceTool.VoxelMeshType) -> void:
	voxel_mesh_type = new_voxel_mesh_type
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


## Returns [member voxels_textured].
func get_voxels_textured() -> bool:
	return voxels_textured


## Sets [member voxels_textured]; and, if in engine, calls on [method update].
func set_voxels_textured(new_voxels_textured : bool) -> void:
	voxels_textured = new_voxels_textured
	if Engine.is_editor_hint():
		update()


## Returns [member voxel_set].
func get_voxel_set():
	return voxel_set


## Sets [member voxel_set]; and, if in engine, calls on [method update].
func set_voxel_set(new_voxel_set : VoxelSet) -> void:
	voxel_set = new_voxel_set
	if Engine.is_editor_hint():
		update()


## Returns the corresponding voxel id at the given [code]voxel_position[/code]. 
## If no voxel id is found at given [code]voxel_position[/code], 
## returns [code]-1[/code].
func get_voxel_id(voxel_position : Vector3i) -> int:
	return _voxels.get(voxel_position, -1)


## Returns the corresponding [Voxel] from the assigned [member voxel_set], 
## in refrence to the voxel id at the given [code]voxel_position[/code]. 
## If no [Voxel] is found at given [code]voxel_position[/code], 
## returns [code]null[/code].
func get_voxel(voxel_position : Vector3i) -> Voxel:
	return voxel_set.get_voxel(get_voxel_id(voxel_position))


## Returns a [Dictionary] of all used voxels; where, keys 
## are voxel positions and voxel ids are values.
func get_voxels() -> Dictionary:
	return _voxels.duplicate(true)


## Returns a list of used voxel positions.
func get_voxel_positions() -> Array[Vector3i]:
	return _voxels.keys()


## Returns a list of used voxel ids.
func get_voxel_ids() -> Array[int]:
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


## Returns [code]true[/code] if voxels are present; 
## otherwise, returns [code]false[/code].
func has_voxels() -> bool:
	return not _voxels.is_empty()


## Returns the number of voxels used.
func get_voxel_count() -> int:
	return _voxels.size()


## Updates voxel mesh with currently used voxels.
func update() -> void:
	if not is_instance_valid(voxel_set):
		push_error("VoxelMeshInstance3D has no VoxelSet assigned!")
		return
	
	var voxel_surface_tool : VoxelSurfaceTool = VoxelSurfaceTool.new()
	voxel_surface_tool.create_from(self, voxel_mesh_type)
	mesh = voxel_surface_tool.commit()
