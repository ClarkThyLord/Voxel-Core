tool
extends Control



# Refrences
onready var _2DView := get_node("2DView")

onready var _3DView := get_node("3DView")
onready var CameraPivot := get_node("3DView/Viewport/CameraPivot")



# Declarations
var dragging := false


enum ViewModes { _2D, _3D }
export(ViewModes) var ViewMode := ViewModes._3D setget set_view_mode
func set_view_mode(view_mode : int) -> void:
	ViewMode = int(clamp(view_mode, 0, 1))
	if _2DView:
		_2DView.visible = ViewMode == ViewModes._2D
	if _3DView:
		_3DView.visible = ViewMode == ViewModes._3D


export(int, 0, 100) var MouseSensitivity := 6



# Core
func _on_3DView_gui_input(event : InputEvent):
	match ViewMode:
		ViewModes._2D:
			pass
		ViewModes._3D:
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_LEFT:
					if event.is_pressed():
						dragging = true
						_3DView.mouse_default_cursor_shape = Control.CURSOR_MOVE
					else:
						dragging = false
						_3DView.mouse_default_cursor_shape = Control.CURSOR_ARROW
					accept_event()
			elif dragging and event is InputEventMouseMotion:
				var motion = event.relative.normalized()
				CameraPivot.rotation_degrees.x += -motion.y * MouseSensitivity
				CameraPivot.rotation_degrees.y += -motion.x * MouseSensitivity
				accept_event()
