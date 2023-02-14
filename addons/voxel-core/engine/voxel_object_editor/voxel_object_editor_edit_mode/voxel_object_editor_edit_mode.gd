@tool
extends RefCounted
## Abstract class for VoxelObject Editor Edit Modes



# Public Methods
func get_edit_mode_name() -> String:
	return ""


func get_edit_mode_visible_name() -> String:
	return ""


func get_edit_mode_icon() -> Texture2D:
	return null


func loaded() -> void:
	pass


func unloaded() -> void:
	pass


func activate() -> void:
	pass


func use() -> void:
	pass


func deactivate() -> void:
	pass
