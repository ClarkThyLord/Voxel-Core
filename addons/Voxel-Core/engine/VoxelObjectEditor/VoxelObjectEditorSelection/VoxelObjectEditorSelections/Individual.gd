tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelection.gd"



# Core
func _init():
	name = "individual"


func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> Dictionary:
	var result := .select(editor, event, prev_hit)
	
	if not editor.last_hit.empty():
		result["selection"].append(editor.get_selection())
	if event is InputEventMouseButton and not event.pressed:
		result["work"] = true
	
	return result
