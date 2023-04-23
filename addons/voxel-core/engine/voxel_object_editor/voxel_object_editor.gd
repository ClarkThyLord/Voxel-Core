@tool
extends HBoxContainer
## VoxelObject Editor Class



# Constants
const EditMode = preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_mode/voxel_object_editor_edit_mode.gd")

const EditTool = preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tool/voxel_object_editor_edit_tool.gd")



# Private Variables
var _edit_modes : Dictionary = {}

var _edit_modes_button_group : ButtonGroup = ButtonGroup.new()

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
	
	get_edit_mode_button(_edit_modes.keys()[0]).button_pressed = true



# Public Variables
func get_edit_mode(edit_mode_name : String) -> EditMode:
	if edit_mode_name in _edit_modes:
		return _edit_modes.get(edit_mode_name)[0]
	else:
		push_error("VoxelObjectEditor doesn't have EditMode with given name!")
		return null


func get_edit_mode_button(edit_mode_name : String) -> Button:
	if edit_mode_name in _edit_modes:
		return _edit_modes.get(edit_mode_name)[1]
	else:
		push_error("VoxelObjectEditor doesn't have EditMode with given name!")
		return null


func add_edit_mode(edit_mode : EditMode) -> void:
	if edit_mode.get_name() in _edit_modes:
		push_error("VoxelObjectEditor already has EditMode with given name!")
		return
	
	var edit_mode_button : Button = Button.new()
	edit_mode_button.toggle_mode = true
	edit_mode_button.button_group = _edit_modes_button_group
	
	edit_mode_button.text = edit_mode.get_display_name()
	edit_mode_button.icon = edit_mode.get_display_icon()
	edit_mode_button.tooltip_text = edit_mode.get_display_tooltip()
	
	edit_mode_button.toggled.connect(
			Callable(_edit_mode_toggled).bind(edit_mode.get_name()))
	
	_edit_modes[edit_mode.get_name()] = [
		edit_mode,
		edit_mode_button
	]
	
	%EditModes.add_child(edit_mode_button)
	
	edit_mode.loaded(edit_mode_button)


func remove_edit_mode(edit_mode_name : String) -> void:
	var edit_mode : EditMode = get_edit_mode(edit_mode_name)
	
	var edit_mode_button : Button = get_edit_mode_button(edit_mode_name)
	%EditModes.remove_child(edit_mode_button)
	edit_mode_button.queue_free()
	
	edit_mode.unloaded()


func activate_edit_mode(edit_mode_name : String) -> void:
	var edit_mode : EditMode = get_edit_mode(edit_mode_name)
	if is_instance_valid(edit_mode):
		edit_mode.activate()


func deactivate_edit_mode(edit_mode_name : String) -> void:
	var edit_mode : EditMode = get_edit_mode(edit_mode_name)
	if is_instance_valid(edit_mode):
		edit_mode.deactivate()


func get_edit_tool(edit_tool_name : String) -> EditTool:
	return null


func add_edit_tool(edit_tool : EditTool) -> void:
	pass


func remove_edit_tool(edit_tool : EditTool) -> void:
	pass



# Private Methods
func _edit_mode_toggled(button_pressed : bool, edit_mode_name : String) -> void:
	if button_pressed:
		activate_edit_mode(edit_mode_name)
	else:
		deactivate_edit_mode(edit_mode_name)
