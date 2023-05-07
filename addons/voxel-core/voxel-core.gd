@tool
extends EditorPlugin



# Constants
const PLUGIN_NAME = "VOXEL-CORE"

const PLUGIN_VERSION = "4.0.0"

const PLUGIN_GITHUB = "https://github.com/ClarkThyLord/Voxel-Core"

const _voxel_object_editor_scene := preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor.tscn")



# Private Variables
var _current_main_screen : String

var _current_handled_voxel_object : Node

var _voxel_object_editor : Control

var _voxel_object_editor_button : Button

var _current_handled_voxel_set : VoxelSet

var _voxel_set_editor : VoxelSet

var _voxel_set_editor_button : Button



# Built-In Virtual Methods
func _enter_tree() -> void:
	print("===")
	set_input_event_forwarding_always_enabled()
	
	main_screen_changed.connect(_on_main_screen_changed, CONNECT_PERSIST)
	
	print("PLUGIN ACTIVE: %s v%s" % [PLUGIN_NAME, PLUGIN_VERSION])
	print_rich("SOUCE: [url]%s[/url]" % PLUGIN_GITHUB)
	print("===")


func _exit_tree() -> void:
	print("===")
	hide_voxel_object_editor()
	
	main_screen_changed.disconnect(_on_main_screen_changed)
	
	print("PLUGIN INACTIVE: %s v%s" % [PLUGIN_NAME, PLUGIN_VERSION])
	print("===")


func _handles(object : Object) -> bool:
	if is_voxel_object(object):
		_handle_state_change(
			_current_main_screen, 
			object, 
			_current_handled_voxel_set)
		return true
	else:
		_handle_state_change(
			_current_main_screen, 
			null, 
			_current_handled_voxel_set)
	return false


func _forward_3d_gui_input(camera : Camera3D, event : InputEvent) -> int:
	if _voxel_object_editor.is_editing():
		return EditorPlugin.AFTER_GUI_INPUT_STOP
	else:
		return EditorPlugin.AFTER_GUI_INPUT_PASS



# Public Methods
func is_voxel_object(object : Object) -> bool:
	return object is VoxelMeshInstance3D


func is_voxel_object_editor_shown() -> bool:
	return is_instance_valid(_voxel_object_editor)


func show_voxel_object_editor() -> void:
	if not is_instance_valid(_voxel_object_editor):
		_voxel_object_editor = _voxel_object_editor_scene.instantiate()
		_voxel_object_editor_button = add_control_to_bottom_panel(_voxel_object_editor, "VoxelObject Editor")
	
	make_bottom_panel_item_visible(_voxel_object_editor)
	_voxel_object_editor.handle_voxel_object(_current_handled_voxel_object)
	if not _voxel_object_editor.is_connected(
			"started_editing", _on_voxel_object_editor_started_editing):
		_voxel_object_editor.connect(
				"started_editing", _on_voxel_object_editor_started_editing)
	if not _voxel_object_editor.is_connected(
			"stopped_editing", _on_voxel_object_editor_stopped_editing):
		_voxel_object_editor.connect(
				"stopped_editing", _on_voxel_object_editor_stopped_editing)


func hide_voxel_object_editor() -> void:
	if is_instance_valid(_voxel_object_editor):
		_voxel_object_editor.stop_editing()
		remove_control_from_bottom_panel(_voxel_object_editor)
		_voxel_object_editor.queue_free()


func toggle_voxel_object_editor() -> void:
	if is_voxel_object_editor_shown():
		hide_voxel_object_editor()
	else:
		show_voxel_object_editor()



# Private Methods
func _set_current_handled_voxel_object(
		current_handled_voxel_object : Node) -> void:
	if is_instance_valid(_current_handled_voxel_object):
		_current_handled_voxel_object.disconnect(
				"tree_exiting", _on_current_handled_voxel_object_tree_exiting)
	
	_current_handled_voxel_object = current_handled_voxel_object
	
	if is_instance_valid(_current_handled_voxel_object):
		_current_handled_voxel_object.connect(
				"tree_exiting", _on_current_handled_voxel_object_tree_exiting)


func _on_current_handled_voxel_object_tree_exiting() -> void:
	_handle_state_change(
			_current_main_screen, 
			null, 
			_current_handled_voxel_set)


func _handle_state_change(
	current_main_screen : String,
	current_handled_voxel_object : Node,
	current_handled_voxel_set : VoxelSet) -> void:
	if current_main_screen == "3D":
		if not is_instance_valid(current_handled_voxel_object):
			hide_voxel_object_editor()
		elif (current_main_screen != _current_main_screen and is_instance_valid(current_handled_voxel_object))\
				or current_handled_voxel_object != _current_handled_voxel_object:
			_set_current_handled_voxel_object(current_handled_voxel_object)
			show_voxel_object_editor()
	else:
		hide_voxel_object_editor()
	
	_current_main_screen = current_main_screen
	_set_current_handled_voxel_object(current_handled_voxel_object)
	_current_handled_voxel_set = current_handled_voxel_set


func _on_main_screen_changed(current_main_screen : String) -> void:
	_handle_state_change(
			current_main_screen, 
			_current_handled_voxel_object, 
			_current_handled_voxel_set)


func _on_voxel_object_editor_started_editing() -> void:
	pass
	get_editor_interface().get_selection().clear()


func _on_voxel_object_editor_stopped_editing() -> void:
	if not is_instance_valid(_current_handled_voxel_object):
		return
#	get_editor_interface().get_selection().add_node(
#			_current_handled_voxel_object)
	get_editor_interface().edit_node(_current_handled_voxel_object)
