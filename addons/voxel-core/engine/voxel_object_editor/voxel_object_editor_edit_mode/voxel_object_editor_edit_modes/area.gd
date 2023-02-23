@tool
extends "res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_mode/voxel_object_editor_edit_mode.gd"
## Abstract class for VoxelObject Editor Edit Modes



# Public Methods
func get_edit_mode_name() -> String:
	return "voxelcore.area"


func get_edit_mode_visible_name() -> String:
	return "Area"


func get_edit_mode_icon() -> Texture2D:
	return preload("res://addons/voxel-core/icons/area.svg")


func loaded(button : Button) -> void:
	pass


func unloaded() -> void:
	pass


func activate() -> void:
	pass


func use() -> void:
	pass


func deactivate() -> void:
	pass
