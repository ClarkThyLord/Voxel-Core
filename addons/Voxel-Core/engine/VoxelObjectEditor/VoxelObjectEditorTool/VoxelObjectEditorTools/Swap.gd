tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTool.gd"



# Core
func _init():
	name = "swap"


func swap(voxel_object, position : Vector3, voxel, undo_redo : UndoRedo) -> void:
	var prev_voxel = voxel_object.get_voxel(position)
	if not typeof(prev_voxel) == TYPE_NIL:
		undo_redo.add_do_method(voxel_object, 'set_voxel', position, voxel)
		undo_redo.add_undo_method(voxel_object, 'set_voxel', position, prev_voxel)


func work(editor) -> void:
	var voxel = editor.get_palette()
	editor.Undo_Redo.create_action("VoxelObjectEditor : Swap voxel")
	for cursor_selection in editor.get_selections():
		for selection in cursor_selection:
			match typeof(selection):
				TYPE_VECTOR3:
					swap(editor.VoxelObjectRef, selection, voxel, editor.Undo_Redo)
				TYPE_ARRAY:
					var origin := Vector3(
						selection[0 if selection[0].x < selection[1].x else 1].x,
						selection[0 if selection[0].y < selection[1].y else 1].y,
						selection[0 if selection[0].z < selection[1].z else 1].z
					)
					var dimensions : Vector3 = (selection[0] - selection[1]).abs()
					for x in range(origin.x, origin.x + dimensions.x + 1):
						for y in range(origin.y, origin.y + dimensions.y + 1):
							for z in range(origin.z, origin.z + dimensions.z + 1):
								swap(editor.VoxelObjectRef, Vector3(x, y, z), voxel, editor.Undo_Redo)
	editor.Undo_Redo.add_do_method(editor.VoxelObjectRef, "update_mesh")
	editor.Undo_Redo.add_undo_method(editor.VoxelObjectRef, "update_mesh")
	editor.Undo_Redo.commit_action()
