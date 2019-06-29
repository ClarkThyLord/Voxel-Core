tool
extends "res://addons/VoxelCore/src/VoxelSet.gd"



# This VoxelSet is used by default by all VoxelCore Objects
# This VoxelSet can and should be modified to your needs
# NOTE: Once the VoxelCore plug-in is activated this VoxelSet shall be set as a singleton named 'CoreVoxelSet', accessible by any Script within the SceneTree



# The following will initialize the object as needed
func _load():
	set_voxel(Voxel.colored(Color.black, {'name': 'black'}))
	set_voxel(Voxel.colored(Color.white, {'name': 'white'}))
	set_voxel(Voxel.colored(Color.red, {'name': 'red'}))
	set_voxel(Voxel.colored(Color.green, {'name': 'green'}))
	set_voxel(Voxel.colored(Color.blue, {'name': 'blue'}))
	set_voxel(Voxel.colored(Color.yellow, {'name': 'yellow'}))
	set_voxel(Voxel.colored(Color.cyan, {'name': 'cyan'}))
	set_voxel(Voxel.colored(Color.purple, {'name': 'purple'}))
	set_voxel(Voxel.colored(Color.magenta, {'name': 'magenta'}))