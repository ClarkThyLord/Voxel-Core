tool
extends "res://addons/voxel-core/engine/voxel_object_editor/editor_tool/editor_tool.gd"



## Built-In Virtual Methods
func _init():
	name = "fill"
	selection_modes = PoolStringArray([
		"individual"
	])



## Public Methods
# Replaces all matching connected voxels in VoxelObject starting at given position and commits it to provided UndoRedo
func fill(voxel_object, position : Vector3, target : int, replacement : int, undo_redo : UndoRedo, filled := []) -> void:
	var voxel = voxel_object.get_voxel_id(position)
	if voxel > -1 and voxel == target and not filled.has(position):
		filled.append(position)
		undo_redo.add_do_method(voxel_object, 'set_voxel', position, replacement)
		undo_redo.add_undo_method(voxel_object, 'set_voxel', position, target)
		for face in Voxel.Faces:
			fill(
					voxel_object, position + face, target, replacement,
					undo_redo, filled)


func work(editor) -> void:
	editor.undo_redo.create_action("VoxelObjectEditor : Fill voxel(s)")
	for selection in editor.get_selections():
		for position in selection:
			var target = editor.voxel_object.get_voxel_id(position)
			if target == -1:
				continue
			
			fill(
					editor.voxel_object, position, target, editor.get_palette(),
					editor.undo_redo)
	editor.undo_redo.add_do_method(editor.voxel_object, "update_mesh")
	editor.undo_redo.add_undo_method(editor.voxel_object, "update_mesh")
	editor.undo_redo.commit_action()
