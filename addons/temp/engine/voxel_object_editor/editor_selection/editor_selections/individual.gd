tool
extends "res://addons/voxel-core/engine/voxel_object_editor/editor_selection/editor_selection.gd"



## Built-In Virtual Methods
func _init():
	name = "individual"



## Public Methods
func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> bool:
	editor.set_cursors_visibility(true)
	
	if (event is InputEventMouseButton and not event.pressed) and not editor.last_hit.empty():
		editor.work_tool()
	elif Input.is_mouse_button_pressed(BUTTON_LEFT) and Input.is_key_pressed(KEY_SHIFT):
		editor.work_tool()
	
	if not (editor.last_hit.get("position") == prev_hit.get("position") and editor.last_hit.get("normal") == prev_hit.get("normal")):
		if editor.last_hit.empty():
			editor.set_cursors_selections([])
		else:
			editor.set_cursors_selections([editor.get_selection()])
	
	return true
