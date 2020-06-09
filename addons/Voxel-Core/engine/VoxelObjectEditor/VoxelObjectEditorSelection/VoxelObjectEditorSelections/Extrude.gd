tool
extends "res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelection.gd"



# Declarations
var face := []
var extrude_amount := 1
var extrude_normal := Vector3.ZERO



# Core
func _init():
	name = "extrude"


func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> bool:
	editor.set_cursors_visibility(true)
	
	if event is InputEventMouseButton and not editor.last_hit.empty():
		if event.pressed:
			extrude_normal = editor.last_hit["normal"]
			editor.set_cursors_selections(face)
		else:
			if not face.empty():
				editor.Tools[editor.Tool.get_selected_id()].work(editor)
				face.clear()
				extrude_amount = 1
				extrude_normal = Vector3.ZERO
			editor.set_cursors_selections(face)
	elif event is InputEventMouseMotion:
		if extrude_normal != Vector3.ZERO:
			extrude_amount = clamp(
				extrude_amount + event.relative.normalized().x,
				1,
				1000
			)
			
			var extrude := []
			var extrude_direction := 1 if editor.Tools[editor.Tool.get_selected_id()].tool_normal > 0 else -1
			for e in range(0, extrude_amount):
				for position in face:
					extrude.append(
						position + extrude_normal * extrude_direction * e
					)
			editor.set_cursors_selections(extrude)
		elif not editor.last_hit.empty() and not (editor.last_hit.get("position") == prev_hit.get("position") and editor.last_hit.get("normal") == prev_hit.get("normal")):
			face = Voxel.face_select(
				editor.VoxelObjectRef,
				editor.last_hit["position"],
				editor.last_hit["normal"]
			)
			if editor.Tools[editor.Tool.get_selected_id()].tool_normal > 0:
				var extrude := []
				for position in face:
					extrude.append(
						position + editor.last_hit["normal"]
					)
				face = extrude
			editor.set_cursors_selections(face)
	
	return true
