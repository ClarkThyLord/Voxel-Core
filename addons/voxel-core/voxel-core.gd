tool
extends EditorPlugin



## Enums
enum VoxelCore {
	OTHER = -1,
	VOXEL_SET,
	VOXEL_OBJECT,
	VOXEL_MESH,
}



## Constants
const VoxelObject := preload("res://addons/voxel-core/classes/voxel_object.gd")

const VoxelSetEditor := preload("res://addons/voxel-core/engine/voxel_set_editor/voxel_set_editor.tscn")

const VoxelObjectEditor := preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor.tscn")



## Private Variables
var _current_main_scene : String

var _handling_voxel_set : VoxelSet

var _editing_voxel_object : bool = false

var _handling_voxel_object : VoxelObject

var voxel_set_editor

var voxel_object_editor

var Meshes := preload("res://addons/voxel-core/engine/importers/voxel_meshes.gd").new()

var VoxelObjects := preload("res://addons/voxel-core/engine/importers/voxel_objects.gd").new()

var VoxelSets := preload("res://addons/voxel-core/engine/importers/voxel_sets.gd").new()

var VoxelScenes := preload("res://addons/voxel-core/engine/importers/voxel_scenes.gd").new()



## Built-In Virtual Methods
func _enter_tree():
	add_import_plugin(Meshes)
	add_import_plugin(VoxelObjects)
	add_import_plugin(VoxelSets)
	add_import_plugin(VoxelScenes)
	
	connect("scene_closed", self, "_on_scene_closed")
	connect("main_screen_changed", self, "_on_main_screen_changed")
	
	print("Voxel-Core is active...")


func _exit_tree():
	remove_import_plugin(Meshes)
	remove_import_plugin(VoxelObjects)
	remove_import_plugin(VoxelSets)
	remove_import_plugin(VoxelScenes)
	
	close_voxel_set_editor()
	close_voxel_object_editor()
	
	print("Voxel-Core is inactive!")


func handles(object : Object) -> bool:
	if _current_main_scene != "3D":
		close_voxel_object_editor()
	if is_instance_valid(_handling_voxel_object):
		var selections := get_editor_interface().get_selection().get_selected_nodes()
		if not _editing_voxel_object\
				and (selections.size() != 1 or not selections.has(_handling_voxel_object)):
			_handling_voxel_object = null
			close_voxel_object_editor()
	return true if typeof_voxel_core(object) > VoxelCore.OTHER else false


func edit(object):
	match typeof_voxel_core(object):
		VoxelCore.VOXEL_SET:
			_handling_voxel_set = object
			if not is_instance_valid(voxel_object_editor) or not voxel_object_editor.is_editing():
				show_voxel_set_editor(object)
			return true
		VoxelCore.VOXEL_OBJECT:
			_handling_voxel_object = object
			if _current_main_scene == "3D":
				show_voxel_object_editor(object)
			return true


func forward_spatial_gui_input(camera : Camera, event : InputEvent) -> bool:
	return voxel_object_editor.handle_input(camera, event) if is_instance_valid(voxel_object_editor) else false



## Public Methods
static func typeof_voxel_core(object : Object) -> int:
	var type_of = VoxelCore.OTHER
	
	if object is VoxelSet:
		type_of = VoxelCore.VOXEL_SET
	elif object is VoxelObject:
		type_of = VoxelCore.VOXEL_OBJECT
	elif object is VoxelMesh:
		type_of = VoxelCore.VOXEL_MESH
	
	return type_of


func show_voxel_set_editor(voxel_set : VoxelSet) -> void:
	if not is_instance_valid(voxel_set_editor):
		voxel_set_editor = VoxelSetEditor.instance()
		voxel_set_editor.undo_redo = get_undo_redo()
		voxel_set_editor.connect("close", self, "close_voxel_set_editor")
		add_control_to_bottom_panel(voxel_set_editor, "VoxelSet")
	voxel_set_editor.voxel_set = voxel_set
	make_bottom_panel_item_visible(voxel_set_editor)


func close_voxel_set_editor() -> void:
	if is_instance_valid(voxel_set_editor):
		remove_control_from_bottom_panel(voxel_set_editor)
		voxel_set_editor.queue_free()
		voxel_set_editor = null


func show_voxel_object_editor(voxel_object : VoxelObject) -> void:
	if not is_instance_valid(voxel_object_editor):
		voxel_object_editor = VoxelObjectEditor.instance()
		voxel_object_editor.undo_redo = get_undo_redo()
		voxel_object_editor.connect("editing", self, "_on_voxel_object_editor_editing_toggled")
		voxel_object_editor.connect("close", self, "close_voxel_object_editor")
		add_control_to_bottom_panel(voxel_object_editor, "VoxelObject")
	voxel_object_editor.start_editing(voxel_object)
	make_bottom_panel_item_visible(voxel_object_editor)


func close_voxel_object_editor() -> void:
	if is_instance_valid(voxel_object_editor):
		voxel_object_editor.stop_editing()
		remove_control_from_bottom_panel(voxel_object_editor)
		voxel_object_editor.queue_free()
		voxel_object_editor = null



## Private Methods
func _on_main_screen_changed(screen_name : String) -> void:
	_current_main_scene = screen_name
	if screen_name == "3D" and is_instance_valid(_handling_voxel_object):
		show_voxel_object_editor(_handling_voxel_object)
	else:
		close_voxel_object_editor()


func _on_scene_closed(filepath : String) -> void:
	close_voxel_object_editor()


func _on_voxel_object_editor_editing_toggled(toggled : bool) -> void:
	_editing_voxel_object = toggled
	if is_instance_valid(voxel_object_editor) and voxel_object_editor.voxel_object == _handling_voxel_object:
		if toggled:
			get_editor_interface().get_selection().clear()
		else:
			get_editor_interface().get_selection().add_node(_handling_voxel_object)
