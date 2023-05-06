extends Node
## Voxel-Core is designed to work with voxel visualization objects and for an 
## object to be recognized as a "VoxelObject" and interact with the rest of the 
## Voxel-Core framework it must implement certain properties and methods.
## 
## This “VoxelObject” class defines the required properties and methods that 
## are needed to be defined and implemented by any class that wants to be 
## recognized as a "VoxelObject".
##
## By following the guidelines laid out in the "VoxelObject" class, developers 
## can ensure that their objects are recognized as "VoxelObjects" and are able 
## to interact with the rest of the Voxel-Core.
## 
## It's important to note that the "VoxelObject" class is not intended to be 
## instantiated or inherited by other classes. Instead, it serves as a 
## guideline for implementing the necessary properties and methods to achieve 
## "VoxelObject" recognition within Voxel-Core.



# Exported Variables
## Algorithm used to generate voxel mesh, refrence 
## [member VoxelSurfaceTool.MeshModes].
@export
var voxel_mesh_type : VoxelSurfaceTool.VoxelMeshType = -1 :
	get = get_voxel_mesh_type,
	set = set_voxel_mesh_type

## Size of voxels relative to the parents scale.
@export_range(0.01, 1.0, 0.01,"or_greater")
var voxel_size : float = 0.0 :
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



# Public Methods
## Returns [member voxel_mesh_type].
func get_voxel_mesh_type() -> VoxelSurfaceTool.VoxelMeshType:
	return -1


## Sets [member voxel_mesh_type]; and, if in engine, calls on [method update].
func set_voxel_mesh_type(
		new_voxel_mesh_type : VoxelSurfaceTool.VoxelMeshType) -> void:
	pass


## Returns [member voxel_size].
func get_voxel_size() -> float:
	return 0.0


## Sets [member voxel_size]; and, if in engine, calls on [method update].
func set_voxel_size(new_voxel_size : float) -> void:
	pass


## Returns [member voxels_textured].
func get_voxels_textured() -> bool:
	return false


## Sets [member voxels_textured]; and, if in engine, calls on [method update].
func set_voxels_textured(new_voxels_textured : bool) -> void:
	pass


## Returns [member voxel_set].
func get_voxel_set() -> VoxelSet:
	return null


## Sets [member voxel_set]; and, if in engine, calls on [method update].
func set_voxel_set(new_voxel_set : VoxelSet) -> void:
	pass


## Returns the corresponding voxel id at the given [code]voxel_position[/code]. 
## If no voxel id is found at given [code]voxel_position[/code], 
## returns [code]-1[/code].
func get_voxel_id(voxel_position : Vector3i) -> int:
	return -1


## Returns the corresponding [Voxel] from the assigned [member voxel_set], 
## in refrence to the voxel id at the given [code]voxel_position[/code]. 
## If no [Voxel] is found at given [code]voxel_position[/code], 
## returns [code]null[/code].
func get_voxel(voxel_position : Vector3i) -> Voxel:
	return null


## Returns a [Dictionary] of all used voxels; where, keys 
## are voxel positions and voxel ids are values.
func get_voxels() -> Dictionary:
	return {}


## Returns a list of used voxel positions.
func get_voxel_positions() -> Array[Vector3i]:
	return []


## Returns a list of used voxel ids.
func get_voxel_ids() -> Array[int]:
	return []


## Assigns the given [code]voxel_id[/code] at the given 
## [code]voxel_position[/code].
func set_voxel(voxel_position : Vector3i, voxel_id : int) -> void:
	pass


## Replaces used voxels with the given [code]new_voxels[/code]; where, keys 
## are voxel positions and values are voxel ids.
func set_voxels(new_voxels : Dictionary) -> void:
	pass


## Erases the voxel at [code]voxel_position[/code] if exists. Returns 
## [code]true[/code] if a voxel id existed at [code]voxel_position[/code]; 
## otherwise, returns [code]false[/code].
func erase_voxel(voxel_position : Vector3i) -> bool:
	return false


## Erases all used voxels.
func erase_voxels() -> void:
	pass


## Returns [code]true[/code] if voxels are present; 
## otherwise, returns [code]false[/code].
func has_voxels() -> bool:
	return false


## Returns the number of voxels used.
func get_voxel_count() -> int:
	return 0


## Updates voxel mesh with currently used voxels.
func update() -> void:
	pass
