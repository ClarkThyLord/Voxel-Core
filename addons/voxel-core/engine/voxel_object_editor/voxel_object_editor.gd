@tool
extends HBoxContainer
## VoxelObject Editor Class



# Constants
const EditMode = preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_mode/voxel_object_editor_edit_mode.gd")

const EditTool = preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tools/voxel_object_editor_edit_tool.gd")



# Private Variables
var _edit_modes : Dictionary = {}

var _edit_tools : Dictionary = {}



# Built-In Virtual Methods
func _ready() -> void:
	for edit_mode in [
				preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_mode/voxel_object_editor_edit_modes/individual.gd").new(),
				preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_mode/voxel_object_editor_edit_modes/area.gd").new(),
				preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_mode/voxel_object_editor_edit_modes/extrude.gd").new(),
				preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_mode/voxel_object_editor_edit_modes/pattern.gd").new(),
			]:
		add_edit_mode(edit_mode)
	for edit_tool in [
				
			]:
		add_edit_tool(edit_tool)



# Public Variables
func get_edit_mode(edit_mode_name : String) -> EditMode:
	return _edit_modes.get(edit_mode_name)


func add_edit_mode(edit_mode : EditMode) -> void:
	if edit_mode.get_edit_mode_name() in _edit_modes:
		push_error("VoxelObject Editor already has EditMode with given name!")
		return
	
	var edit_mode_button : Button = Button.new()
	edit_mode_button.icon = edit_mode.get_edit_mode_icon()
	edit_mode_button.text = edit_mode.get_edit_mode_visible_name()
	
	_edit_modes[edit_mode.get_edit_mode_name()] = [
		edit_mode,
		edit_mode_button
	]
	
	edit_mode.loaded(edit_mode_button)
	%EditModes.add_child(edit_mode_button)


func remove_edit_mode(edit_mode : EditMode) -> void:
	pass


func get_edit_tool(edit_tool_name : String) -> EditTool:
	return null


func add_edit_tool(edit_tool : EditTool) -> void:
	pass


func remove_edit_tool(edit_tool : EditTool) -> void:
	pass
