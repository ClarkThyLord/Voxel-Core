tool
extends "res://addons/voxel-core/engine/voxel_object_editor/editor_selection/editor_selection.gd"



## Private Variables
var _selection := []



## Built-In Virtual Methods
func _init():
	name = "area"



## Public Methods
func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> bool:
	editor.set_cursors_visibility(true)
	
	if event is InputEventMouseButton and not editor.last_hit.empty():
		if event.pressed:
			_selection.clear()
			_selection.append(editor.get_selection())
			_selection.append(editor.get_selection())
		else:
			if not _selection.empty():
				editor.work_tool()
				_selection.clear()
	elif event is InputEventMouseMotion:
		if not (editor.last_hit.get("position") == prev_hit.get("position") and editor.last_hit.get("normal") == prev_hit.get("normal")):
			if not editor.last_hit.empty():
				if _selection.empty():
					editor.set_cursors_selections([editor.get_selection()])
				else:
					_selection[1] = editor.get_selection()
					editor.set_cursors_selections([_selection])
	
	return true
