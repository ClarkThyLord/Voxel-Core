@tool
extends EditorPlugin



# Constants
const _voxel_object_editor_scene := preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor.tscn")



# Private Variables
var _current_main_screen : String

var _current_handled_voxel_object : Object

var _voxel_object_editor

var _voxel_object_editor_button : Button

var _current_handled_voxel_set : VoxelSet

var _voxel_set_editor

var _voxel_set_editor_button : Button



# Built-In Virtual Methods
func _enter_tree():
	main_screen_changed.connect(_on_main_screen_changed, CONNECT_PERSIST)
	
	print("Voxel-Core is active!")


func _exit_tree():
	hide_voxel_object_editor()
	
	main_screen_changed.disconnect(_on_main_screen_changed)
	
	print("Voxel-Core is inactive!")


func _handles(object) -> bool:
	if object is VoxelMeshInstance3D:
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


func _edit(object) -> void:
	pass



# Public Methods
func is_voxel_object_editor_shown() -> bool:
	return is_instance_valid(_voxel_object_editor)


func show_voxel_object_editor() -> void:
	if not is_instance_valid(_voxel_object_editor):
		_voxel_object_editor = _voxel_object_editor_scene.instantiate()
		_voxel_object_editor_button = add_control_to_bottom_panel(_voxel_object_editor, "VoxelObject Editor")
	make_bottom_panel_item_visible(_voxel_object_editor)


func hide_voxel_object_editor() -> void:
	if is_instance_valid(_voxel_object_editor):
		remove_control_from_bottom_panel(_voxel_object_editor)
		_voxel_object_editor.queue_free()


func toggle_voxel_object_editor() -> void:
	if is_voxel_object_editor_shown():
		hide_voxel_object_editor()
	else:
		show_voxel_object_editor()



# Private Methods
func _handle_state_change(
	current_main_screen : String,
	current_handled_voxel_object : Object,
	current_handled_voxel_set : Object) -> void:
	
	if current_main_screen == "3D":
		if (current_main_screen != _current_main_screen and is_instance_valid(current_handled_voxel_object))\
				or current_handled_voxel_object != _current_handled_voxel_object:
			show_voxel_object_editor()
		elif not is_instance_valid(current_handled_voxel_object):
			hide_voxel_object_editor()
	else:
		hide_voxel_object_editor()
	
	_current_main_screen = current_main_screen
	_current_handled_voxel_object = current_handled_voxel_object
	_current_handled_voxel_set = current_handled_voxel_set


func _on_main_screen_changed(current_main_screen : String) -> void:
	_handle_state_change(
			current_main_screen, 
			_current_handled_voxel_object, 
			_current_handled_voxel_set)
