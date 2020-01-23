tool
extends "res://addons/Voxel-Core/src/VoxelSet.gd"



# VoxelSet.default:
# This VoxelSet is used by default by all VoxelObjects.
# This VoxelSet can and should be modified to your needs.
# NOTE: Once the VoxelCore plug-in is activated this VoxelSet shall be added as a singleton named 'VoxelSet', accessible by any Script within the SceneTree



# The following will initialize the object as needed
func _load():
	set_voxel(Voxel.colored(Color.black), 'black')
	set_voxel(Voxel.colored(Color.white), 'white')
	set_voxel(Voxel.colored(Color.red), 'red')
	set_voxel(Voxel.colored(Color.green), 'green')
	set_voxel(Voxel.colored(Color.blue), 'blue')
	set_voxel(Voxel.colored(Color.yellow), 'yellow')
	set_voxel(Voxel.colored(Color.cyan), 'cyan')
	set_voxel(Voxel.colored(Color.purple), 'purple')
	set_voxel(Voxel.colored(Color.magenta), 'magenta')
