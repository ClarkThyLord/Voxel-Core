tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelection.gd"



# Declarations
var face := []
var extruding := false
var extrude_amount := 1
var extrude_normal := Vector3.ZERO



# Core
func _init():
	name = "extrude"


func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> bool:
	editor.set_cursors_visibility(true)
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if not face.empty():
				extruding = true
				extrude_normal = editor.last_hit["normal"]
		else:
			if extruding:
				editor.Tools[editor.Tool.get_selected_id()].work(editor)
				face.clear()
				extrude_amount = 1
				extrude_normal = Vector3.ZERO
			extruding = false
		editor.set_cursors_selections(face)
	elif event is InputEventMouseMotion:
		if extruding:
			var extrude := []
			extrude_amount = clamp(extrude_amount + event.relative.normalized().x, 1, 100)
			var extrude_direction := 1 if editor.Tools[editor.Tool.get_selected_id()].tool_normal > 0 else -1
			for e in range(extrude_amount):
				for position in face:
					extrude.append(position + extrude_normal * extrude_direction * e)
			editor.set_cursors_selections(extrude)
		else:
			if not editor.last_hit.empty():
				if editor.VoxelObjectRef.get_voxel_id(editor.last_hit["position"]) > -1:
					if editor.last_hit.empty() or not (editor.last_hit.get("position") == prev_hit.get("position") and editor.last_hit.get("normal") == prev_hit.get("normal")):
						face = editor.VoxelObjectRef.face_select(editor.last_hit["position"], editor.last_hit["normal"])
						if editor.Tools[editor.Tool.get_selected_id()].tool_normal > 0:
							for i in range(face.size()):
								face[i] += editor.last_hit["normal"]
				else: face.clear()
			else: face.clear()
			editor.set_cursors_selections(face)
	
	return true
