tool
extends EditorPlugin



# Core
func _enter_tree():
	add_autoload_singleton('VoxelSet', 'res://addons/Voxel-Core/defaults/VoxelSet.default.gd')
	
	
	print('Loaded Voxel-Core.')

func _exit_tree():
	remove_autoload_singleton('VoxelSet')
	
	
	print('Unloaded Voxel-Core.')
