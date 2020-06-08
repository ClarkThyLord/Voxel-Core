tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelection.gd"



# Declarations
var selection := []



# Core
func _init():
	name = "area"


func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> bool:
#	var selection =
#
#	if not editor.last_hit.empty():
#		if event is InputEventMouseButton:
#			if event.pressed:
#				selection.clear()
#				selection.append(editor.get_selection())
#				selection.append(editor.get_selection())
#				result["selection"].append(selection)
#			else:
#				editor.Tools[editor.Tool.get_selected_id()].work(editor)
#				selection.clear()
#		elif event is InputEventMouseMotion:
#			if not selection.empty():
#				selection[1] = editor.get_selection()
#				result["selection"].append(selection)
	editor.set_cursors_visibility(true)
	
	if event is InputEventMouseButton and not editor.last_hit.empty():
		if event.pressed:
			selection.clear()
			selection.append(editor.get_selection())
			selection.append(editor.get_selection())
		else:
			if not selection.empty():
				editor.Tools[editor.Tool.get_selected_id()].work(editor)
				selection.clear()
	elif event is InputEventMouseMotion:
		if not (editor.last_hit.get("position") == prev_hit.get("position") and editor.last_hit.get("normal") == prev_hit.get("normal")):
			if not editor.last_hit.empty():
				if selection.empty():
					editor.set_cursors_selections([editor.get_selection()])
				else:
					selection[1] = editor.get_selection()
					editor.set_cursors_selections([selection])
	
	return true
