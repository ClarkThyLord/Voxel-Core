tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelection.gd"



# Core
func _init():
	name = "individual"


func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> bool:
	editor.set_cursors_visibility(true)
	
	if event is InputEventMouseButton and not event.pressed and not editor.get_selection() == Vector3.INF:
		editor.Tools[editor.Tool.get_selected_id()].work(editor)
	
	if not (editor.last_hit.get("position") == prev_hit.get("position") and editor.last_hit.get("normal") == prev_hit.get("normal")):
		if editor.last_hit.empty():
			editor.set_cursors_selections([])
		else:
			editor.set_cursors_selections([editor.get_selection()])
	
	return true
