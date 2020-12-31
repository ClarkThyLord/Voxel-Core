tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTool.gd"



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
		for direction in Voxel.Directions:
			fill(
				voxel_object,
				position + direction,
				target,
				replacement,
				undo_redo,
				filled
			)


func work(editor) -> void:
	editor.Undo_Redo.create_action("VoxelObjectEditor : Fill voxel(s)")
	for selection in editor.get_selections():
		for position in selection:
			var target = editor.VoxelObjectRef.get_voxel_id(position)
			if target == -1:
				continue
			
			fill(
				editor.VoxelObjectRef,
				position,
				target,
				editor.get_palette(),
				editor.Undo_Redo
			)
	editor.Undo_Redo.add_do_method(editor.VoxelObjectRef, "update_mesh")
	editor.Undo_Redo.add_undo_method(editor.VoxelObjectRef, "update_mesh")
	editor.Undo_Redo.commit_action()
