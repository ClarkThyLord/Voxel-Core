@tool
extends HBoxContainer
## VoxelObject Editor Class



# Constants
const Grid = preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_grid/voxel_object_editor_grid.gd")

const EditMode = preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_mode/voxel_object_editor_edit_mode.gd")

const EditTool = preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tool/voxel_object_editor_edit_tool.gd")



# Signals
signal started_editing

signal stopped_editing



# Private Variables
var _editing : bool = false

var _editing_voxel_object = null

var _current_edit_mode_name : String = ""

var _edit_modes : Dictionary = {}

var _edit_modes_button_group : ButtonGroup = ButtonGroup.new()

var _current_edit_tool_name : String = ""

var _edit_tools : Dictionary = {}

var _edit_tools_button_group : ButtonGroup = ButtonGroup.new()

var _mirror_x : bool = false

var _mirror_y : bool = false

var _mirror_z : bool = false

var _grid : Grid = null



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
				preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tool/voxel_object_editor_tools/add.gd").new(),
				preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tool/voxel_object_editor_tools/sub.gd").new(),
				preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tool/voxel_object_editor_tools/select.gd").new(),
				preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tool/voxel_object_editor_tools/pick.gd").new(),
				preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tool/voxel_object_editor_tools/swap.gd").new(),
				preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_edit_tool/voxel_object_editor_tools/fill.gd").new(),
			]:
		add_edit_tool(edit_tool)
	
	get_edit_tool_button(_edit_tools.keys()[0]).button_pressed = true


func _exit_tree() -> void:
	if is_instance_valid(_grid):
		_grid.queue_free()



# Public Variables
func is_editing() -> bool:
	return _editing


func start_editing() -> void:
	if _editing:
		return
	
	if not %EditingCheckBox.button_pressed:
		%EditingCheckBox.button_pressed = true
		return
	
	if is_instance_valid(_editing_voxel_object):
		_attach_grid()
	
	_editing = true
	emit_signal("started_editing")


func stop_editing() -> void:
	if not _editing:
		return
	
	if %EditingCheckBox.button_pressed:
		%EditingCheckBox.button_pressed = false
		return
	
	if is_instance_valid(_editing_voxel_object):
		_detach_grid()
	
	_editing = false
	emit_signal("stopped_editing")


func get_current_edit_mode_name() -> String:
	return _current_edit_mode_name


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
		var edit_mode_button : Button = get_edit_mode_button(edit_mode_name)
		if not edit_mode_button.button_pressed:
			edit_mode_button.button_pressed = true
			return
		
		_current_edit_mode_name = edit_mode_name
		
		edit_mode.activate()


func deactivate_edit_mode(edit_mode_name : String) -> void:
	var edit_mode : EditMode = get_edit_mode(edit_mode_name)
	if is_instance_valid(edit_mode):
		var edit_mode_button : Button = get_edit_mode_button(edit_mode_name)
		if edit_mode_button.button_pressed:
			edit_mode_button.button_pressed = false
			return
		
		edit_mode.deactivate()


func enable_edit_mode(edit_mode_name : String) -> void:
	var edit_mode_button : Button = get_edit_mode_button(edit_mode_name)
	if is_instance_valid(edit_mode_button):
		edit_mode_button.disabled = false


func disable_edit_mode(edit_mode_name : String) -> void:
	var edit_mode_button : Button = get_edit_mode_button(edit_mode_name)
	if is_instance_valid(edit_mode_button):
		edit_mode_button.disabled = true


func get_current_edit_tool_name() -> String:
	return _current_edit_tool_name


func get_edit_tool(edit_tool_name : String) -> EditTool:
	if edit_tool_name in _edit_tools:
		return _edit_tools.get(edit_tool_name)[0]
	else:
		push_error("VoxelObjectEditor doesn't have EditTool with given name!")
		return null


func get_edit_tool_button(edit_tool_name : String) -> Button:
	if edit_tool_name in _edit_tools:
		return _edit_tools.get(edit_tool_name)[1]
	else:
		push_error("VoxelObjectEditor doesn't have EditTool with given name!")
		return null


func add_edit_tool(edit_tool : EditTool) -> void:
	if edit_tool.get_name() in _edit_tools:
		push_error("VoxelObjectEditor already has EditTool with given name!")
		return
	
	var edit_tool_button : Button = Button.new()
	edit_tool_button.toggle_mode = true
	edit_tool_button.custom_minimum_size = Vector2(86, 0)
	edit_tool_button.button_group = _edit_tools_button_group
	
	edit_tool_button.text = edit_tool.get_display_name()
	edit_tool_button.icon = edit_tool.get_display_icon()
	edit_tool_button.tooltip_text = edit_tool.get_display_tooltip()
	
	edit_tool_button.toggled.connect(
			Callable(_edit_tool_toggled).bind(edit_tool.get_name()))
	
	_edit_tools[edit_tool.get_name()] = [
		edit_tool,
		edit_tool_button
	]
	
	%EditTools.add_child(edit_tool_button)
	
	edit_tool.loaded(edit_tool_button)


func remove_edit_tool(edit_tool_name : String) -> void:
	var edit_tool : EditTool = get_edit_tool(edit_tool_name)
	
	var edit_tool_button : Button = get_edit_tool_button(edit_tool_name)
	%Edittools.remove_child(edit_tool_button)
	edit_tool_button.queue_free()
	
	edit_tool.unloaded()


func activate_edit_tool(edit_tool_name : String) -> void:
	var edit_tool : EditTool = get_edit_tool(edit_tool_name)
	if is_instance_valid(edit_tool):
		var edit_tool_button : Button = get_edit_tool_button(edit_tool_name)
		if not edit_tool_button.button_pressed:
			edit_tool_button.button_pressed = true
			return
		
		var supported_edit_modes : Array[String] = \
				edit_tool.get_supported_edit_modes()
		
		for edit_mode_name in _edit_modes.keys():
			if edit_mode_name not in supported_edit_modes:
				disable_edit_mode(edit_mode_name)
			else:
				enable_edit_mode(edit_mode_name)
		
		if get_current_edit_mode_name() not in supported_edit_modes:
			activate_edit_mode(supported_edit_modes[0])
		
		_current_edit_tool_name = edit_tool_name
		
		if edit_tool.can_mirror_x():
			enable_mirror_x()
		else:
			disable_mirror_x()
		
		if edit_tool.can_mirror_y():
			enable_mirror_y()
		else:
			disable_mirror_y()
		
		if edit_tool.can_mirror_z():
			enable_mirror_z()
		else:
			disable_mirror_z()
		
		edit_tool.activate()


func deactivate_edit_tool(edit_tool_name : String) -> void:
	var edit_tool : EditTool = get_edit_tool(edit_tool_name)
	if is_instance_valid(edit_tool):
		var edit_tool_button : Button = get_edit_tool_button(edit_tool_name)
		if edit_tool_button.button_pressed:
			edit_tool_button.button_pressed = false
			return
		
		edit_tool.deactivate()


func enable_edit_tool(edit_tool_name : String) -> void:
	var edit_tool_button : Button = get_edit_tool_button(edit_tool_name)
	if is_instance_valid(edit_tool_button):
		edit_tool_button.disabled = false


func disable_edit_tool(edit_tool_name : String) -> void:
	var edit_tool_button : Button = get_edit_tool_button(edit_tool_name)
	if is_instance_valid(edit_tool_button):
		edit_tool_button.disabled = true


func is_mirroring_x() -> bool:
	return _mirror_x


func activate_mirror_x() -> void:
	if not %XMirrorModeButton.button_pressed:
		%XMirrorModeButton.button_pressed = true
		return
	
	_mirror_x = true


func deactivate_mirror_x() -> void:
	if not %XMirrorModeButton.button_pressed:
		%XMirrorModeButton.button_pressed = false
		return
	
	_mirror_x = false


func enable_mirror_x() -> void:
	%XMirrorModeButton.disabled = false
	_mirror_x = false


func disable_mirror_x() -> void:
	%XMirrorModeButton.disabled = true
	_mirror_x = %XMirrorModeButton.button_pressed


func is_mirroring_y() -> bool:
	return _mirror_y


func activate_mirror_y() -> void:
	if not %YMirrorModeButton.button_pressed:
		%YMirrorModeButton.button_pressed = true
		return
	
	_mirror_y = true


func deactivate_mirror_y() -> void:
	if not %YMirrorModeButton.button_pressed:
		%YMirrorModeButton.button_pressed = false
		return
	
	_mirror_y = false


func enable_mirror_y() -> void:
	%YMirrorModeButton.disabled = false
	_mirror_y = false


func disable_mirror_y() -> void:
	%YMirrorModeButton.disabled = true
	_mirror_y = %YMirrorModeButton.button_pressed


func is_mirroring_z() -> bool:
	return _mirror_z


func activate_mirror_z() -> void:
	if not %ZMirrorModeButton.button_pressed:
		%ZMirrorModeButton.button_pressed = true
		return
	
	_mirror_z = true


func deactivate_mirror_z() -> void:
	if not %ZMirrorModeButton.button_pressed:
		%ZMirrorModeButton.button_pressed = false
		return
	
	_mirror_z = false


func enable_mirror_z() -> void:
	%ZMirrorModeButton.disabled = false
	_mirror_z = false


func disable_mirror_z() -> void:
	%ZMirrorModeButton.disabled = true
	_mirror_z = %ZMirrorModeButton.button_pressed


func handle_voxel_object(voxel_object) -> void:
	stop_editing()
	
	_editing_voxel_object = voxel_object


func consume_forward_3d_gui_input(
		camera : Camera3D, event : InputEvent) -> bool:
	if not is_editing():
		return false
	
	if event is InputEventMouse:
		pass
	
	return false



# Private Methods
func _attach_grid() -> void:
	if not is_instance_valid(_grid):
		_grid = Grid.new()
		_grid.update()
	
	_editing_voxel_object.add_child(_grid)


func _detach_grid() -> void:
	if is_instance_valid(_grid) and is_instance_valid(_grid.get_parent()):
		_grid.get_parent().remove_child(_grid)


func _edit_mode_toggled(button_pressed : bool, edit_mode_name : String) -> void:
	if button_pressed:
		activate_edit_mode(edit_mode_name)
	else:
		deactivate_edit_mode(edit_mode_name)


func _edit_tool_toggled(button_pressed : bool, edit_tool_name : String) -> void:
	if button_pressed:
		activate_edit_tool(edit_tool_name)
	else:
		deactivate_edit_tool(edit_tool_name)


func _on_x_mirror_mode_button_pressed() -> void:
	_mirror_x = %XMirrorModeButton.button_pressed


func _on_y_mirror_mode_button_pressed() -> void:
	_mirror_y = %YMirrorModeButton.button_pressed


func _on_z_mirror_mode_button_pressed() -> void:
	_mirror_z = %ZMirrorModeButton.button_pressed


func _on_editing_check_box_toggled(button_pressed : bool) -> void:
	if button_pressed:
		start_editing()
	else:
		stop_editing()
