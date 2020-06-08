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
	return result
#	if event is InputEventMouseButton and not event.pressed:
#		Tools[Tool.get_selected_id()].work(self)
#		extrude_face.clear()
#		extrude_amount = 0
#		area_points.clear()
#	selection.append(last_hit["position"] + last_hit["normal"] * Tools[Tool.get_selected_id()].selection_offset)
