tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTool.gd"



# Core
func _init():
	name = "swap"
	selection_offset = -1


func work(editor) -> void:
	pass
#	var _voxel = VoxelObject.get_rvoxel(grid)
#	if not typeof(_voxel) == TYPE_NIL:
#		set_modified(true)
#		undo_redo.add_do_method(VoxelObject, 'set_voxel', grid, voxel, false)
#		undo_redo.add_undo_method(VoxelObject, 'set_voxel', grid, _voxel, false)
