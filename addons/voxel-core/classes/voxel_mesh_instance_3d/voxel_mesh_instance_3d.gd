@tool
class_name VoxelMeshInstance3D
extends MeshInstance3D
@icon("res://addons/voxel-core/classes/voxel_mesh_instance_3d/voxel_mesh_instance_3d.svg")
## The most basic voxel visualization object, for a moderate amount of voxels;
## used by Voxel-Core.
##
## A VoxelMeshInstance3D is the most basic voxel visualization object to be used
## with a moderate amount of voxels, depending on the hardware a couple
## of thousand~.
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
## voxel_mesh.add_voxel(Vector3(0, 0, 0), voxel_id)
## voxel_mesh.add_voxel(Vector3(1, 0, 0), voxel_id)
## voxel_mesh.add_voxel(Vector3(1, 0, 1), voxel_id)
## voxel_mesh.add_voxel(Vector3(0, 0, 1), voxel_id)
##
## voxel_mesh.update()
## [/codeblock]



# Enums
enum MeshModes {
	NAIVE,
	GREEDY,
}



# Exported Variables
@export
var mesh_mode : MeshModes = MeshModes.NAIVE

@export
var tiled_faces : bool = true

@export_range(0.01, 1.0, 0.01,"or_greater")
var voxel_size : float = 0.25

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


func get_voxel(position : Vector3) -> Voxel:
	return null


func get_voxel_id(position : Vector3) -> int:
	return -1


func get_voxels() -> Dictionary:
	return _voxels.duplicate(true)


func set_voxel(position : Vector3, voxel_id : int) -> void:
	update()


func set_voxels(new_voxels : Dictionary) -> void:
	update()


func erase_voxel(position : Vector3) -> void:
	update()


func erase_voxels() -> void:
	update()


func has_voxels() -> bool:
	return not _voxels.is_empty()


func get_voxel_count() -> int:
	return _voxels.size()


func update() -> void:
	pass
