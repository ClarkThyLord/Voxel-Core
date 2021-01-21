tool
extends "res://addons/voxel-core/engine/voxel_object_editor/editor_tool/editor_tool.gd"



## Built-In Virtual Methods
func _init():
	name = "sub"



## Public Methods
# Removes voxel id at given grid position in given VoxelObject and commits it to provided UndoRedo
func sub(voxel_object, position : Vector3, undo_redo : UndoRedo) -> void:
	var voxel = voxel_object.get_voxel_id(position)
	if voxel > -1:
		undo_redo.add_do_method(voxel_object, 'erase_voxel', position)
		undo_redo.add_undo_method(voxel_object, 'set_voxel', position, voxel)


func work(editor) -> void:
	editor.undo_redo.create_action("VoxelObjectEditor : Sub voxel")
	for cursor_selection in editor.get_selections():
		for selection in cursor_selection:
			match typeof(selection):
				TYPE_VECTOR3:
					sub(editor.voxel_object, selection, editor.undo_redo)
				TYPE_ARRAY:
					var origin := Vector3(
							selection[0 if selection[0].x < selection[1].x else 1].x,
							selection[0 if selection[0].y < selection[1].y else 1].y,
							selection[0 if selection[0].z < selection[1].z else 1].z)
					var dimensions : Vector3 = (selection[0] - selection[1]).abs()
					for x in range(origin.x, origin.x + dimensions.x + 1):
						for y in range(origin.y, origin.y + dimensions.y + 1):
							for z in range(origin.z, origin.z + dimensions.z + 1):
								sub(
										editor.voxel_object, Vector3(x, y, z),
										editor.undo_redo)
	editor.undo_redo.add_do_method(editor.voxel_object, "update_mesh")
	editor.undo_redo.add_undo_method(editor.voxel_object, "update_mesh")
	editor.undo_redo.commit_action()
