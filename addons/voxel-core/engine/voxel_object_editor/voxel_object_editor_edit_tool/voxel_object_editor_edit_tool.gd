@tool
extends RefCounted
## Abstract class for VoxelObject Editor Edit Tools



# Public Methods
func get_name() -> String:
	return ""


func get_display_name() -> String:
	return ""


func get_display_icon() -> Texture2D:
	return null


func get_display_tooltip() -> String:
	return ""


func get_supported_edit_modes() -> Array:
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


func loaded(button : Button) -> void:
	print_debug("LOADED EDIT TOOL \"%s\"" % get_name())


func unloaded() -> void:
	print_debug("UNLOADED EDIT TOOL \"%s\"" % get_name())


func activate() -> void:
	print_debug("ACTIVATED EDIT TOOL \"%s\"" % get_name())


func use() -> void:
	print_debug("USED EDIT TOOL \"%s\"" % get_name())


func deactivate() -> void:
	print_debug("DEACTIVATED EDIT TOOL \"%s\"" % get_name())
