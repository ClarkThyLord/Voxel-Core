@tool
extends Control
## Voxel Viewer Class



# Public Variables
@export_range(1, 100, 1)
var _camera_sensitivity : int = 8



# Private Variables
var _is_dragging : bool = false



# Private Methods
func _on_sub_viewport_container_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = event.pressed
	elif event is InputEventMouseMotion:
		if _is_dragging:
			var motion : Vector2 = event.relative.normalized()
			%CameraPivot.rotation_degrees.x += -motion.y * _camera_sensitivity
			%CameraPivot.rotation_degrees.y += -motion.x * _camera_sensitivity
