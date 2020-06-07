tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelection.gd"



# Core
func _init():
	name = "individual"


func select(editor, event : InputEvent, prev_hit : Dictionary) -> Dictionary:
	return {
		"consume": true,
		"selection": [
			editor.last_hit["position"] + editor.last_hit["normal"] * editor.Tools[editor.Tool.get_selected_id()].selection_offset
		]
	}
#	if event is InputEventMouseButton and not event.pressed:
#		Tools[Tool.get_selected_id()].work(self)
#		extrude_face.clear()
#		extrude_amount = 0
#		area_points.clear()
#	selection.append(last_hit["position"] + last_hit["normal"] * Tools[Tool.get_selected_id()].selection_offset)
