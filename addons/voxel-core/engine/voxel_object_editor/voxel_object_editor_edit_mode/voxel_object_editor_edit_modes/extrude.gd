@tool
extends "res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_mode/voxel_object_editor_edit_mode.gd"



# Public Methods
func get_name() -> String:
	return "voxelcore.extrude"


func get_display_name() -> String:
	return "Extrude"


func get_display_icon() -> Texture2D:
	return preload("res://addons/voxel-core/engine/icons/extrude.svg")
