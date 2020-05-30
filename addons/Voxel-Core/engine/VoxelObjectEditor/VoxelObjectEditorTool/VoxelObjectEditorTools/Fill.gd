tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTool.gd"



# Core
func _init():
	name = "fill"
	selection_offset = -1
	selection_modes = PoolStringArray([
		"individual"
	])


func work(editor) -> void:
	pass
