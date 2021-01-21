tool
extends "res://addons/voxel-core/engine/voxel_object_editor/editor_selection/editor_selection.gd"



## Private Variables
# Face area being selected
var _face := []

# Flag indicating if currently extruding
var _extruding := false

# How much extrusion is being applied currently
var _extrude_amount := 1

# Normal of extrusion
var _extrude_normal := Vector3.ZERO



## Built-In Virtual Methods
func _init():
	name = "extrude"


## Public Methods
func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> bool:
	editor.set_cursors_visibility(true)
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if not _face.empty():
				_extruding = true
				_extrude_normal = editor.last_hit["normal"]
		else:
			if _extruding:
				editor.work_tool()
				_face.clear()
				_extrude_amount = 1
				_extrude_normal = Vector3.ZERO
			_extruding = false
		editor.set_cursors_selections(_face)
	elif event is InputEventMouseMotion:
		if _extruding:
			var extrude := []
			_extrude_amount = clamp(_extrude_amount + clamp(event.relative.normalized().x, -1, 1), 1, 100)
			var extrude_direction := 1 if editor.get_tool_normal() > 0 else -1
			for e in range(_extrude_amount):
				for position in _face:
					extrude.append(position + _extrude_normal * extrude_direction * e)
			editor.set_cursors_selections(extrude)
		else:
			if not editor.last_hit.empty():
				if editor.voxel_object.get_voxel_id(editor.last_hit["position"]) > -1:
					if editor.last_hit.empty() or not (editor.last_hit.get("position") == prev_hit.get("position") and editor.last_hit.get("normal") == prev_hit.get("normal")):
						if Input.is_key_pressed(KEY_SHIFT):
							_face = editor.voxel_object.select_face_similar(editor.last_hit["position"], editor.last_hit["normal"])
						else:
							_face = editor.voxel_object.select_face(editor.last_hit["position"], editor.last_hit["normal"])
						if editor.get_tool_normal() > 0:
							for i in range(_face.size()):
								_face[i] += editor.last_hit["normal"]
				else:
					_face.clear()
			else:
				_face.clear()
			editor.set_cursors_selections(_face)
	
	return true
