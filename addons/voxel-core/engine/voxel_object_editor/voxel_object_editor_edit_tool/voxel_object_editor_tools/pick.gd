@tool
extends "res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tool/voxel_object_editor_edit_tool.gd"



# Public Methods
func get_name() -> String:
	return "voxelcore.pick"


func get_display_name() -> String:
	return "Pick"


func get_display_icon() -> Texture2D:
	return preload("res://addons/voxel-core/engine/icons/pick.svg")


func get_supported_edit_modes() -> Array[String]:
	return [
		"voxelcore.individual",
	]


func get_cursor_offset() -> int:
	return 0


func can_mirror_x() -> bool:
	return false


func can_mirror_y() -> bool:
	return false


func can_mirror_z() -> bool:
	return false