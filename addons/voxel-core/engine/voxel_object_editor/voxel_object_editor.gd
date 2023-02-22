@tool
extends HBoxContainer
## VoxelObject Editor Class



# Constants
const EditMode = preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_mode/voxel_object_editor_edit_mode.gd")

const EditTool = preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tools/voxel_object_editor_edit_tool.gd")



# Private Variables
var _edit_modes : Array = []

var _edit_tools : Array = []



# Built-In Virtual Methods
func _ready() -> void:
	for edit_mode in [
				
			]:
		add_edit_mode(edit_mode)
	for edit_tool in [
				
			]:
		add_edit_tool(edit_tool)



# Public Variables
func get_edit_mode(edit_mode_name : String) -> EditMode:
	return null


func add_edit_mode(edit_mode : EditMode) -> void:
	pass


func remove_edit_mode(edit_mode : EditMode) -> void:
	pass


func get_edit_tool(edit_tool_name : String) -> EditTool:
	return null


func add_edit_tool(edit_tool : EditTool) -> void:
	pass


func remove_edit_tool(edit_tool : EditTool) -> void:
	pass
