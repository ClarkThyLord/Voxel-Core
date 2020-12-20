tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelection.gd"



# Core
func _init():
	name = "individual"


func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> bool:
	editor.set_cursors_visibility(true)
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and not editor.last_hit.empty():
		editor.Tools[editor.Tool.get_selected_id()].work(editor)
	
	if event is InputEventMouseMotion:
		if not (editor.last_hit.get("position") == prev_hit.get("position") and editor.last_hit.get("normal") == prev_hit.get("normal")):
			if editor.last_hit.empty():
				editor.set_cursors_selections([])
			else:
				editor.set_cursors_selections([editor.get_selection()])
	
	return true
