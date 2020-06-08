tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelection.gd"



# Declarations
var area_points := []



# Core
func _init():
	name = "area"


func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> Dictionary:
	var result := .select(editor, event, prev_hit)
	
	
	
	return result
#	if event is InputEventMouseButton:
#		if event.pressed:
#			area_points = [
#				last_hit["position"] + last_hit["normal"] * Tools[Tool.get_selected_id()].selection_offset,
#				last_hit["position"] + last_hit["normal"] * Tools[Tool.get_selected_id()].selection_offset
#			]
#			selection.append(area_points)
#		else: continue
#	elif event is InputEventMouseMotion:
#		if not area_points.empty():
#			if event.button_mask & BUTTON_MASK_LEFT == BUTTON_MASK_LEFT:
#				area_points[1] = last_hit["position"] + last_hit["normal"] * Tools[Tool.get_selected_id()].selection_offset
#			selection.append(area_points)
#		else: continue
