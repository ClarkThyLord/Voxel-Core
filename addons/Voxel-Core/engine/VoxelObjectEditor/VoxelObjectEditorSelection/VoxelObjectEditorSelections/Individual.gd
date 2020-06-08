tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelection.gd"



# Core
func _init():
	name = "individual"


func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> Dictionary:
	var result := .select(editor, event, prev_hit)
	if not editor.last_hit.empty():
		result["selection"] = [
			editor.last_hit["position"] + editor.last_hit["normal"] * editor.Tools[editor.Tool.get_selected_id()].selection_offset
		]
	if event is InputEventMouseButton and not event.pressed:
		result["work"] = true
	return result
