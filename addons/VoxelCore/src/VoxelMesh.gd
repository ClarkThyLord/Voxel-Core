tool
extends "res://addons/VoxelCore/src/VoxelObject.gd"
class_name VoxelMesh, 'res://addons/VoxelCore/assets/VoxelMesh.png'



# Declarations
var voxels : Dictionary = {}

# Core
func _load() -> void: voxels = get_meta('voxels') if has_meta('voxels') else {}
func _save() -> void: set_meta('voxels', voxels)


