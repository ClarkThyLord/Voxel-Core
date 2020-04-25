tool
extends Control



# Refrences
onready var ViewerHint := get_node("ToolBar/Hint")


onready var _2DView := get_node("2DView")


onready var _3DView := get_node("3DView")

onready var CameraPivot := get_node("3DView/Viewport/CameraPivot")

onready var SelectPivot := get_node("3DView/Viewport/SelectPivot")
onready var Select := get_node("3DView/Viewport/SelectPivot/Select")



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


export(Color) var SelectColor := Color("6400ffff") setget set_select_color
func set_select_color(select_color : Color) -> void:
	SelectColor = select_color
	
	if Select:
		Select.material_override.albedo_color = SelectColor

export(Vector3) var SelectedFace := Vector3.ZERO setget set_selected_face
func set_selected_face(selected_face : Vector3) -> void:
	SelectedFace = selected_face
	
	var hint := ""
	var select_rot := Vector3.INF
	match SelectedFace:
		Vector3.RIGHT:
			hint = "RIGHT"
			select_rot = Vector3(0, 0, -90)
		Vector3.LEFT:
			hint = "LEFT"
			select_rot = Vector3(0, 0, 90)
		Vector3.UP:
			hint = "UP"
			select_rot = Vector3.ZERO
		Vector3.DOWN:
			hint = "DOWN"
			select_rot = Vector3(180, 0, 0)
		Vector3.FORWARD:
			hint = "FRONT"
			select_rot = Vector3(-90, 0, 0)
		Vector3.BACK:
			hint = "BACK"
			select_rot = Vector3(90, 0, 0)
	
	if SelectPivot:
		SelectPivot.visible = not select_rot == Vector3.INF
		if not select_rot == Vector3.INF:
			SelectPivot.rotation_degrees = select_rot
	if ViewerHint:
		ViewerHint.text = hint


export(int, 0, 100) var MouseSensitivity := 6



# Core
func _unhandled_input(event):
	match ViewMode:
		ViewModes._2D:
			pass
		ViewModes._3D:
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_LEFT:
					if event.is_pressed():
						dragging = true
						Input.set_default_cursor_shape(Control.CURSOR_MOVE)
					else:
						dragging = false
						Input.set_default_cursor_shape(Control.CURSOR_ARROW)
			elif dragging and event is InputEventMouseMotion:
				var motion = event.relative.normalized()
				CameraPivot.rotation_degrees.x += -motion.y * MouseSensitivity
				CameraPivot.rotation_degrees.y += -motion.x * MouseSensitivity


func _on_VoxelStaticBody_mouse_exited():
	Input.set_default_cursor_shape(Control.CURSOR_ARROW)

func _on_VoxelStaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if not dragging:
		Input.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed() and event.doubleclick:
		set_selected_face(click_normal.round())
