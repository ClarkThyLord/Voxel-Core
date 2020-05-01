tool
extends EditorPlugin



# Imports
const VoxelObject := preload("res://addons/Voxel-Core/classes/VoxelObject.gd")

const VoxelSetEditor := preload("res://addons/Voxel-Core/engine/VoxelSetEditor/VoxelSetEditor.tscn")



# Declarations
var handling : Object

var VoxelSetEditorRef



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
	print("Voxel-Core is active...")

func _exit_tree():
	print("Voxel-Core is inactive!")


func show_voxel_set_editor(voxelset : VoxelSet) -> void:
	if not VoxelSetEditorRef:
		VoxelSetEditorRef = VoxelSetEditor.instance()
		add_control_to_bottom_panel(VoxelSetEditorRef, "VoxelSet")
	VoxelSetEditorRef.edit_voxel_set(voxelset)
	make_bottom_panel_item_visible(VoxelSetEditorRef)

func close_voxel_set_editor() -> void:
	if VoxelSetEditorRef:
		remove_control_from_bottom_panel(VoxelSetEditorRef)
		VoxelSetEditorRef.queue_free()
		VoxelSetEditorRef = null


func handles(object : Object) -> bool:
	if typeof_voxel_core(object) == VoxelCore.VOXEL_SET:
		handling = object
		show_voxel_set_editor(handling)
		return true
	elif handling:
		match typeof_voxel_core(handling):
			VoxelCore.VOXEL_SET:
				close_voxel_set_editor()
		handling = null
	return false
