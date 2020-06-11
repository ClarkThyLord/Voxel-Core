tool
extends EditorPlugin



# Imports
const VoxelObject := preload("res://addons/Voxel-Core/classes/VoxelObject.gd")

const VoxelSetEditor := preload("res://addons/Voxel-Core/engine/VoxelSetEditor/VoxelSetEditor.tscn")
const VoxelObjectEditor := preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditor.tscn")



# Declarations
var current_main_scene : String

var handling_voxel_set : VoxelSet
var handling_voxel_object : VoxelObject

var VoxelSetEditorRef
var VoxelObjectEditorRef



# Helpers
enum VoxelCore {
	OTHER = -1,
	VOXEL_SET,
	VOXEL_OBJECT,
	VOXEL_MESH
}
static func typeof_voxel_core(object : Object) -> int:
	var type_of = VoxelCore.OTHER
	if object is VoxelSet: type_of = VoxelCore.VOXEL_SET
	elif object is VoxelObject: type_of = VoxelCore.VOXEL_OBJECT
	elif object is VoxelMesh: type_of = VoxelCore.VOXEL_MESH
	return type_of



# Core
func _enter_tree():
	connect("scene_closed", self, "on_scene_closed")
	connect("main_screen_changed", self, "on_main_screen_changed")
	
	print("Voxel-Core is active...")

func _exit_tree():
	close_voxel_set_editor()
	close_voxel_object_editor()
	
	print("Voxel-Core is inactive!")


func show_voxel_set_editor(voxel_set : VoxelSet) -> void:
	if not is_instance_valid(VoxelSetEditorRef):
		VoxelSetEditorRef = VoxelSetEditor.instance()
		VoxelSetEditorRef.Undo_Redo = get_undo_redo()
		VoxelSetEditorRef.connect("close", self, "close_voxel_set_editor")
		add_control_to_bottom_panel(VoxelSetEditorRef, "VoxelSet")
	VoxelSetEditorRef.Voxel_Set = voxel_set
	make_bottom_panel_item_visible(VoxelSetEditorRef)

func close_voxel_set_editor() -> void:
	if is_instance_valid(VoxelSetEditorRef):
		remove_control_from_bottom_panel(VoxelSetEditorRef)
		VoxelSetEditorRef.queue_free()
		VoxelSetEditorRef = null


func show_voxel_object_editor(voxel_object : VoxelObject) -> void:
	if not is_instance_valid(VoxelObjectEditorRef):
		VoxelObjectEditorRef = VoxelObjectEditor.instance()
		VoxelObjectEditorRef.Undo_Redo = get_undo_redo()
		VoxelObjectEditorRef.connect("editing", self, "on_voxel_object_editor_editing_toggled")
		VoxelObjectEditorRef.connect("close", self, "close_voxel_object_editor")
		add_control_to_bottom_panel(VoxelObjectEditorRef, "VoxelObject")
	VoxelObjectEditorRef.begin(voxel_object)
	make_bottom_panel_item_visible(VoxelObjectEditorRef)

func close_voxel_object_editor() -> void:
	if is_instance_valid(VoxelObjectEditorRef):
		VoxelObjectEditorRef.cancel()
		remove_control_from_bottom_panel(VoxelObjectEditorRef)
		VoxelObjectEditorRef.queue_free()
		VoxelObjectEditorRef = null

func on_voxel_object_editor_editing_toggled(toggled : bool) -> void:
	if is_instance_valid(VoxelObjectEditorRef) and VoxelObjectEditorRef.VoxelObjectRef == handling_voxel_object:
		if toggled: get_editor_interface().get_selection().clear()
		else: get_editor_interface().get_selection().add_node(handling_voxel_object)


func handles(object : Object) -> bool:
	match typeof_voxel_core(object):
		VoxelCore.VOXEL_SET:
			handling_voxel_set = object
			show_voxel_set_editor(object)
			return true
		VoxelCore.VOXEL_OBJECT:
			handling_voxel_object = object
			if current_main_scene == "3D":
				show_voxel_object_editor(object)
			else: close_voxel_object_editor()
			return true
	if is_instance_valid(handling_voxel_object):
		handling_voxel_object = null
		close_voxel_object_editor()
	return false


func on_scene_closed(filepath : String) -> void:
	close_voxel_object_editor()

func on_main_screen_changed(screen_name : String) -> void:
	current_main_scene = screen_name
	if screen_name == "3D" and is_instance_valid(handling_voxel_object):
		show_voxel_object_editor(handling_voxel_object)
	else: close_voxel_object_editor()


func forward_spatial_gui_input(camera : Camera, event : InputEvent) -> bool:
	return VoxelObjectEditorRef.handle_input(camera, event) if is_instance_valid(VoxelObjectEditorRef) else false
