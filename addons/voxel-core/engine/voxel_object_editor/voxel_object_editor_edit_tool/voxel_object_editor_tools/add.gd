@tool
extends "res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tool/voxel_object_editor_edit_tool.gd"



# Public Methods
func get_name() -> String:
	return "voxelcore.add"


func get_display_name() -> String:
	return "Add"


func get_display_icon() -> Texture2D:
	return preload("res://addons/voxel-core/engine/icons/add.svg")


func get_supported_edit_modes() -> Array[String]:
	return [
		"voxelcore.individual",
		"voxelcore.area",
		"voxelcore.extrude",
		"voxelcore.pattern",
	]


func get_cursor_offset() -> int:
	return 0


func can_mirror_x() -> bool:
	return true


func can_mirror_y() -> bool:
	return true


func can_mirror_z() -> bool:
	return true
