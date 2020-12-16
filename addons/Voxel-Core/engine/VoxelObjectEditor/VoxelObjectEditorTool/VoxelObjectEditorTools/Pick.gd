tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTool.gd"



# Core
func _init():
	name = "pick"
	selection_modes = PoolStringArray([
		"individual"
	])
	mirror_modes = Vector3.ZERO


func work(editor) -> void:
	var voxel = editor.VoxelObjectRef.get_voxel(editor.Cursors[Vector3.ZERO].Selections[0])
	match typeof(voxel):
		TYPE_DICTIONARY:
			editor.set_palette(editor.Palette.get_selected_id(), voxel.duplicate(true))
		TYPE_INT, TYPE_STRING:
			editor.set_palette(editor.Palette.get_selected_id(), voxel)
