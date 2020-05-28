tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTool.gd"



# Core
func _init():
	name = "sub"
	selection_offset = -1


func work(editor) -> void:
	pass
#	var voxel = VoxelObject.get_voxel(grid)
#	if not typeof(voxel) == TYPE_NIL:
#		set_modified(true)
#		undo_redo.add_do_method(VoxelObject, 'erase_voxel', grid, false)
#		undo_redo.add_undo_method(VoxelObject, 'set_voxel', grid, voxel, false)
