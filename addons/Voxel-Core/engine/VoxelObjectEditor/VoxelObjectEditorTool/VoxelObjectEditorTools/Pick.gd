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
	var voxel = editor.VoxelObjectRef.get_voxel_id(editor.Cursors[Vector3.ZERO].Selections[0])
	if voxel > -1:
		editor.VoxelSetViewer.unselect_all()
		editor.VoxelSetViewer.select(voxel)
