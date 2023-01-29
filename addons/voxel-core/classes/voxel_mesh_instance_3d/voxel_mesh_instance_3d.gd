@tool
@icon("res://addons/voxel-core/classes/voxel_mesh_instance_3d/voxel_mesh_instance_3d.svg")
class_name VoxelMeshInstance3D
extends MeshInstance3D
## The most basic voxel visualization object, for a moderate amount of voxels;
## used by Voxel-Core.
##
## A VoxelMeshInstance3D is the most basic voxel visualization object provided 
## by Voxel-Core, and is intended to be used for a moderate amount of voxels.
##
## [codeblock]
## var voxel_set : VoxelSet = VoxelSet.new()
## voxel_set.tiles = preload("res://texture.png")
##
## var voxel : Voxel = Voxel.new()
## voxel.name = "dirt grass"
## voxel.color = Color.BROWN
## voxel.color_up = Color.GREEN
## voxel.tile = Vector2(0, 0)
## voxel.tile_up = Vector2(1, 0)
##
## var voxel_id : int = voxel_set.add_voxel(voxel)
##
## var voxel_mesh : VoxelMeshInstance3D = VoxelMeshInstance3D.new()
## voxel_mesh.voxel_set = voxel_set
##
## voxel_mesh.add_voxel(Vector3i(0, 0, 0), voxel_id)
## voxel_mesh.add_voxel(Vector3i(1, 0, 0), voxel_id)
## voxel_mesh.add_voxel(Vector3i(1, 0, 1), voxel_id)
## voxel_mesh.add_voxel(Vector3i(0, 0, 1), voxel_id)
##
## voxel_mesh.update()
## [/codeblock]



# Exported Variables
## Approach to be used when generating voxel mesh, refrence 
## [member VoxelSurfaceTool.MeshModes].
@export
var voxel_mesh_type : VoxelSurfaceTool.VoxelMeshType = VoxelSurfaceTool.VoxelMeshType.NAIVE :
	get = get_voxel_mesh_type,
	set = set_voxel_mesh_type

## Size of voxels.
@export_range(0.01, 1.0, 0.01,"or_greater")
var voxel_size : float = 0.25 :
	get = get_voxel_size,
	set = set_voxel_size

## Toggle to generate voxel mesh with UV mapping.
@export
var voxels_tiled : bool = false :
	get = get_voxels_tiled,
	set = set_voxels_tiled

## VoxelSet used to generate voxel mesh.
@export
var voxel_set : VoxelSet = null :
	get = get_voxel_set,
	set = set_voxel_set



# Private Variables
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


## Sets [member voxel_mesh_type] and calls on [method update].
func set_voxel_mesh_type(new_voxel_mesh_type : VoxelSurfaceTool.VoxelMeshType) -> void:
	voxel_mesh_type = new_voxel_mesh_type
	update()


## Returns [member voxel_size].
func get_voxel_size() -> float:
	return voxel_size


## Sets [member voxel_size] and calls on [method update].
func set_voxel_size(new_voxel_size : float) -> void:
	voxel_size = new_voxel_size
	update()


## Returns [member voxels_tiled].
func get_voxels_tiled() -> bool:
	return voxels_tiled


## Sets [member voxels_tiled] and calls on [method update].
func set_voxels_tiled(new_voxels_tiled : bool) -> void:
	voxels_tiled = new_voxels_tiled
	update()


## Returns [member voxel_set].
func get_voxel_set():
	return voxel_set


## Sets [member voxel_set] and calls on [method update].
func set_voxel_set(new_voxel_set : VoxelSet) -> void:
	voxel_set = new_voxel_set


## Returns [code]voxel_id[/code] at given [code]voxel_position[/code] if not
## found returns [code]-1[/code].
func get_voxel_id(voxel_position : Vector3i) -> int:
	return _voxels.get(voxel_position, -1)


## Returns [Voxel] at given [code]voxel_position[/code] if not found returns
## [code]null[/code].
func get_voxel(voxel_position : Vector3i) -> Voxel:
	return voxel_set.get_voxel(get_voxel_id(voxel_position))


## Returns [Dictionary] with all used [code]voxel_position[/code](s) being the
## keys and their respective [code]voxel_id[/code] being their value.
func get_voxels() -> Dictionary:
	return _voxels.duplicate(true)


func get_voxel_positions() -> Array[Vector3i]:
	return _voxels.keys()


func get_voxel_ids() -> Array[int]:
	return _voxels.values()


## Sets the given [code]voxel_id[/code] at given [code]voxel_position[/code] and
## calls on [method update].
func set_voxel(voxel_position : Vector3i, voxel_id : int) -> void:
	if not voxel_set.has_voxel_id(voxel_id):
		printerr("Error: Invalid voxel_id `%s` to be set" % voxel_id)
		return
	_voxels[voxel_position] = voxel_id
	update()


## Replaces all voxels with given [code]new_voxels[/code] and calls on 
## [method update].
func set_voxels(new_voxels : Dictionary) -> void:
	for voxel_position in new_voxels:
		if not voxel_position is Vector3i:
			printerr("Error: Invalid voxel_position to be set")
			return
		if not new_voxels[voxel_position] is int:
			printerr("Error: Invalid voxel_id to be set")
			return
	_voxels = new_voxels
	update()


## Erase voxel at given [code]voxel_position[/code] and calls on [method update].
func erase_voxel(voxel_position : Vector3i) -> void:
	if not _voxels.has(voxel_position):
		printerr("Error: Invalid voxel_position to erase")
		return
	_voxels.erase(voxel_position)
	update()


## Erases all voxels and calls on [method update].
func erase_voxels() -> void:
	_voxels.clear()
	update()


## Returns [code]true[/code] if voxels are present, else [code]false[/code].
func has_voxels() -> bool:
	return not _voxels.is_empty()


## Returns amount of voxels present.
func get_voxel_count() -> int:
	return _voxels.size()


## Updates voxel mesh with current data.
func update() -> void:
	var voxel_surface_tool : VoxelSurfaceTool = VoxelSurfaceTool.new()
	voxel_surface_tool.create_from(self, voxel_mesh_type)
	mesh = voxel_surface_tool.commit()
