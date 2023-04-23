@tool
extends RefCounted
## Abstract class for VoxelObject Editor Edit Modes



# Public Methods
func get_name() -> String:
	return ""


func get_display_name() -> String:
	return ""


func get_display_icon() -> Texture2D:
	return null


func get_display_tooltip() -> String:
	return ""


func loaded(button : Button) -> void:
	print_debug("LOADED EDIT MODE \"%s\"" % get_name())


func unloaded() -> void:
	print_debug("UNLOADED EDIT MODE \"%s\"" % get_name())


func activate() -> void:
	print_debug("ACTIVATED EDIT MODE \"%s\"" % get_name())


func use() -> void:
	print_debug("USED EDIT MODE \"%s\"" % get_name())


func deactivate() -> void:
	print_debug("DEACTIVATED EDIT MODE \"%s\"" % get_name())
