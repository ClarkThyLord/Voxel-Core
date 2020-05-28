tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTool.gd"



# Core
func _init():
	name = "add"


func work(editor) -> void:
	pass
#	undo_redo.add_do_method(VoxelObject, 'set_voxel', grid, voxel, false)
#	voxel = VoxelObject.get_rvoxel(grid)
#	if typeof(voxel) == TYPE_NIL:
#		undo_redo.add_undo_method(VoxelObject, 'erase_voxel', grid, false)
#	else:
#		undo_redo.add_undo_method(VoxelObject, 'set_voxel', grid, voxel, false)
