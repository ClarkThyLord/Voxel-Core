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
	set_hovered_face(Vector3.ZERO)
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


var HoveredFace := Vector3.ZERO setget set_hovered_face
func set_hovered_face(hovered_face : Vector3) -> void:
	HoveredFace = hovered_face

export(Vector3) var SelectedFace := Vector3.ZERO setget set_selected_face
func set_selected_face(selected_face : Vector3) -> void:
	SelectedFace = selected_face
	
	var select_name := ""
	var select_rot := Vector3.INF
	match SelectedFace:
		Vector3.RIGHT:
			select_name = "Right"
			select_rot = Vector3(0, 0, -90)
		Vector3.LEFT:
			select_name = "Left"
			select_rot = Vector3(0, 0, 90)
		Vector3.UP:
			select_name = "Top"
			select_rot = Vector3.ZERO
		Vector3.DOWN:
			select_name = "Bottom"
			select_rot = Vector3(180, 0, 0)
		Vector3.FORWARD:
			select_name = "Front"
			select_rot = Vector3(-90, 0, 0)
		Vector3.BACK:
			select_name = "Back"
			select_rot = Vector3(90, 0, 0)
	
	
	if SelectPivot:
		SelectPivot.visible = not select_rot == Vector3.INF
		if not select_rot == Vector3.INF:
			SelectPivot.rotation_degrees = select_rot


export(int, 0, 100) var MouseSensitivity := 6



# Core
func _ready():
	set_view_mode(ViewMode)
	set_select_color(SelectColor)
	set_selected_face(SelectedFace)


func _process(delta):
	
	var selected := ""
	match SelectedFace:
		Vector3.RIGHT:
			selected = "RIGHT"
		Vector3.LEFT:
			selected = "LEFT"
		Vector3.UP:
			selected = "TOP"
		Vector3.DOWN:
			selected = "BOTTOM"
		Vector3.FORWARD:
			selected = "FRONT"
		Vector3.BACK:
			selected = "BACK"
	
	var hovered := ""
	match HoveredFace:
		Vector3.RIGHT:
			hovered = "RIGHT"
		Vector3.LEFT:
			hovered = "LEFT"
		Vector3.UP:
			hovered = "TOP"
		Vector3.DOWN:
			hovered = "BOTTOM"
		Vector3.FORWARD:
			hovered = "FRONT"
		Vector3.BACK:
			hovered = "BACK"
	
	if ViewerHint:
		ViewerHint.text = selected
		if selected.length() > 0 and hovered.length() > 0:
			ViewerHint.text += " | "
		ViewerHint.text += hovered

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
	HoveredFace = Vector3.ZERO
	Input.set_default_cursor_shape(Control.CURSOR_ARROW)

func _on_VoxelStaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if not dragging:
		Input.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed() and event.doubleclick:
		set_selected_face(click_normal.round())
	elif not click_normal.round() == SelectedFace:
		HoveredFace = click_normal.round()
	else: HoveredFace = Vector3.ZERO
