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
	
	return true
