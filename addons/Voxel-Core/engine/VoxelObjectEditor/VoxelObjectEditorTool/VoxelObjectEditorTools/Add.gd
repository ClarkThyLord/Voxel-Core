tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTool.gd"



# Core
func _init():
	name = "add"
	tool_normal = 1


func add(voxel_object, position : Vector3, voxel, undo_redo : UndoRedo) -> void:
	undo_redo.add_do_method(voxel_object, "set_voxel", position, voxel)
	voxel = voxel_object.get_voxel(position)
	if typeof(voxel) == TYPE_NIL:
		undo_redo.add_undo_method(voxel_object, "erase_voxel", position)
	else:
		undo_redo.add_undo_method(voxel_object, "set_voxel", position, voxel)


func work(editor) -> void:
	var voxel = editor.get_palette()
	if voxel == -1:
		return
	
	editor.Undo_Redo.create_action("VoxelObjectEditor : Add voxel")
	for cursor_selection in editor.get_selections():
		for selection in cursor_selection:
			match typeof(selection):
				TYPE_VECTOR3:
					add(editor.VoxelObjectRef, selection, voxel, editor.Undo_Redo)
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
								add(editor.VoxelObjectRef, Vector3(x, y, z), voxel, editor.Undo_Redo)
	editor.Undo_Redo.add_do_method(editor.VoxelObjectRef, "update_mesh")
	editor.Undo_Redo.add_undo_method(editor.VoxelObjectRef, "update_mesh")
	editor.Undo_Redo.commit_action()
