@tool
class_name VoxelMeshInstance3D
extends MeshInstance3D
@icon("res://addons/voxel-core/classes/voxel_mesh_instance_3d/voxel_mesh_instance_3d.svg")
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



# Enums
## Approaches for generating voxel meshes, each approach has its own advantage 
## and disadvantage; for more information visit:
## [url=http://web.archive.org/web/20200428085802/https://0fps.net/2012/06/30/meshing-in-a-minecraft-game/]Voxel Meshing[/url],
## [url=http://web.archive.org/web/20201112011204/https://www.gedge.ca/dev/2014/08/17/greedy-voxel-meshing]Greedy Voxel Meshing[/url]
## [br]
## - Brute meshing, no culling of voxel faces; renders all voxel faces
## regardless of obstruction. (worst optimized approach)
## [br]
## - Naive meshing, simple culling of voxel faces; only renders all non
## obstructed voxels. (best optimized approach for its execution cost)
## [br]
## - Greedy meshing, culls and merges similar voxel faces; renders all non
## obstructed voxels while reducing face count. (best used for static content,
## as its very costly to execute)
enum MeshModes {
	BRUTE,
	NAIVE,
	GREEDY,
}



# Exported Variables
@export
var mesh_mode : MeshModes = MeshModes.NAIVE

@export_range(0.01, 1.0, 0.01,"or_greater")
var voxel_size : float = 0.25

@export
var voxels_tiled : bool = true

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
func get_voxel_set():
	return voxel_set


func set_voxel_set(new_voxel_set : VoxelSet) -> void:
	voxel_set = new_voxel_set
	update()


func get_voxel_id(voxel_position : Vector3i) -> int:
	return _voxels.get(voxel_position, -1)


func get_voxel(voxel_position : Vector3i) -> Voxel:
	return voxel_set.get_voxel(get_voxel_id(voxel_position))


func get_voxels() -> Dictionary:
	return _voxels.duplicate(true)


func set_voxel(voxel_position : Vector3i, voxel_id : int) -> void:
	if not voxel_set.has_voxel_id(voxel_id):
		printerr("Error: Invalid voxel_id `%s` to be set" % voxel_id)
		return
	
	_voxels[voxel_position] = voxel_id
	update()


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


func erase_voxel(voxel_position : Vector3i) -> void:
	_voxels.erase(voxel_position)
	update()


func erase_voxels() -> void:
	_voxels.clear()
	update()


func has_voxels() -> bool:
	return not _voxels.is_empty()


func get_voxel_count() -> int:
	return _voxels.size()


func update() -> void:
	pass
