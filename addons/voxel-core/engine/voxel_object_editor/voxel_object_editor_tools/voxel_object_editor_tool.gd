extends RefCounted
## Abstract class for VoxelObject Editor Tools



# Public Methods
func get_tool_name() -> String:
	return ""


func get_tool_visible_name() -> String:
	return ""


func get_tool_icon() -> Texture2D:
	return null


func get_compatible_edit_modes() -> Array:
	return [
		
	]


func get_cursor_offset() -> int:
	return 0


func can_mirror_x() -> bool:
	return true


func can_mirror_y() -> bool:
	return true


func can_mirror_z() -> bool:
	return true


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
