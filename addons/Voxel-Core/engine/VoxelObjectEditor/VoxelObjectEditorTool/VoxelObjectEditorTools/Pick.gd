tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTool.gd"



# Core
func _init():
	name = "pick"
	selection_offset = -1
	selection_modes = PoolStringArray([
		"individual"
	])
	mirror_modes = Vector3.ZERO


func work(editor) -> void:
	pass
