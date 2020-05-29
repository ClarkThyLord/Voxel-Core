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
	var voxel = editor.VoxelObjectRef.get_rvoxel(editor.Cursors[Vector3.ZERO].Selections[0])
	print(voxel)
	match typeof(voxel):
		TYPE_DICTIONARY:
			editor.set_palette(editor.Palette.get_selected_id(), voxel.duplicate(true))
		TYPE_INT, TYPE_STRING:
			print(voxel)
			editor.set_palette(editor.Palette.get_selected_id(), voxel)
