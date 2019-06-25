tool
extends VoxelSet



# Core
func _load():
	.set_voxel(Voxel.colored(Color(1, 0, 0), {'color': 'red'}))
	.set_voxel(Voxel.colored(Color(0, 1, 0), {'color': 'green'}))
	.set_voxel(Voxel.colored(Color(0, 0, 1), {'color': 'blue'}))
