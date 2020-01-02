tool
extends "res://addons/Voxel-Core/src/VoxelMesh.gd"



# Declarations
export(int, 16, 32, 2) var ChunkSize setget set_chunk_size
func set_chunk_size(chunksize : int) -> void:
	ChunkSize = clamp(chunksize - (chunksize % 2), 16, 32)




# Core
func _load() -> void: pass
func _save() -> void: pass


func _init() -> void: pass
func _ready() -> void: pass


func get_rvoxel(grid : Vector3):
	return voxels.get(grid)

func get_voxels() -> Dictionary:
	return voxels.duplicate(true)


func set_voxel(grid : Vector3, voxel, update := false) -> void:
	voxels[grid] = voxel
	.set_voxel(grid, voxel, update)

func set_voxels(_voxels : Dictionary, update := true) -> void:
	erase_voxels(false)
	
	voxels = _voxels
	if update: update()


func erase_voxel(grid : Vector3, update := false) -> void:
	voxels.erase(grid)
	.erase_voxel(grid, update)

func erase_voxels(update : bool = true) -> void:
	voxels.clear()
	if update: update()
