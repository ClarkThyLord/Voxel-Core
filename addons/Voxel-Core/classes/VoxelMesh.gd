tool
extends "res://addons/Voxel-Core/classes/VoxelObject.gd"
class_name VoxelMesh, "res://addons/Voxel-Core/assets/classes/VoxelMesh.png"



#
# VoxelMesh, the most basic VoxelObject, should be
# used for relatively small amounts of voxels.
#



# Declarations
var voxels := {}



# Core
func _save() -> void:
	set_meta("voxels", voxels)

func _load() -> void:
	if has_meta("voxels"):
		voxels = get_meta("voxels")
		._load()


func _init() -> void: _load()
func _ready() -> void: _load()


func set_voxel(grid : Vector3, voxel) -> void:
	match typeof(voxel):
		TYPE_INT, TYPE_DICTIONARY:
			voxels[grid] = voxel
		_:
			printerr("invalid voxel set")

func set_rvoxel(grid : Vector3, voxel) -> void:
	match typeof(voxel):
		TYPE_INT, TYPE_STRING:
			voxel = Voxel_Set.get_voxel(voxel)
	set_voxel(grid, voxel)

func set_voxels(voxels : Dictionary) -> void:
	erase_voxels()
	voxels = voxels

func get_voxel(grid : Vector3) -> Dictionary:
	var voxel = get_rvoxel(grid)
	match typeof(voxel):
		TYPE_INT, TYPE_STRING:
			voxel = Voxel_Set.get_voxel(voxel)
	return voxel

func get_rvoxel(grid : Vector3):
	return voxels.get(grid)

func get_voxels() -> Array:
	return voxels.keys()

func erase_voxel(grid : Vector3) -> void:
	voxels.erase(grid)

func erase_voxels() -> void:
	voxels.clear()


func update_mesh(save := true) -> void:
	if save: _save()

func update_static_body() -> void:
	pass
