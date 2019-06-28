tool
extends "res://addons/VoxelCore/src/VoxelSet.gd"



# This VoxelSet is used by default by all VoxelCore Objects
# This VoxelSet can and should be modified to your needs
# NOTE: Once the VoxelCore plug-in is activated this VoxelSet shall be set as a singleton named 'CoreVoxelSet', accessible by any Script within the SceneTree



# The following will initialize the object as needed
func _load():
	.set_voxel(Voxel.colored(Color(1, 0, 0), {'color': 'red'}))
	.set_voxel(Voxel.colored(Color(0, 1, 0), {'color': 'green'}))
	.set_voxel(Voxel.colored(Color(0, 0, 1), {'color': 'blue'}))