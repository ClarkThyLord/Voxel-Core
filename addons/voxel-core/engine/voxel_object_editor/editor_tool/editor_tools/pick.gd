tool
extends "res://addons/voxel-core/engine/voxel_object_editor/editor_tool/editor_tool.gd"



## Built-In Virtual Methods
func _init():
	name = "pick"
	selection_modes = PoolStringArray([
		"individual"
	])
	mirror_modes = Vector3.ZERO



## Public Methods
func work(editor) -> void:
	var voxel = editor.voxel_object.get_voxel_id(editor.get_selection())
	if voxel > -1:
		editor.VoxelSetViewer.unselect_all()
		editor.VoxelSetViewer.select(voxel)
