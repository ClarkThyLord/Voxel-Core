tool
extends Button



# Core
func setup(voxel : int, voxel_set : VoxelSet) -> void:
	hint_tooltip = str(voxel)
	$VoxelRect.setup_voxel(voxel, voxel_set)
