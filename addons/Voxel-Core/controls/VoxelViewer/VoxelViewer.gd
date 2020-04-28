tool
extends Control



# Refrences
onready var ContextMenu := get_node("ContextMenu")


onready var ViewerHint := get_node("ToolBar/Hint")


onready var _2DView := get_node("2DView")


onready var _3DView := get_node("3DView")

onready var CameraPivot := get_node("3DView/Viewport/CameraPivot")

onready var SelectPivot := get_node("3DView/Viewport/SelectPivot")
onready var Select := get_node("3DView/Viewport/SelectPivot/Select")



# Declarations
signal selected_face(normal)


var Represents := [null, null] setget set_represents
func set_represents(represents : Array) -> void: pass


var dragging := false


export(bool) var EditMode := false setget set_edit_mode
func set_edit_mode(edit_mode : bool) -> void:
	EditMode = edit_mode

export(bool) var SelectMode := false setget set_select_mode
func set_select_mode(select_mode : bool) -> void:
	SelectMode = select_mode
	
	if not SelectMode: set_selected_face(Vector3.ZERO)


enum ViewModes { _2D, _3D }
export(ViewModes) var ViewMode := ViewModes._3D setget set_view_mode
func set_view_mode(view_mode : int) -> void:
	set_hovered_face(Vector3.ZERO)
	ViewMode = int(clamp(view_mode, 0, 1))
	if _2DView:
		_2DView.visible = ViewMode == ViewModes._2D
	if _3DView:
		_3DView.visible = ViewMode == ViewModes._3D


var HoveredFace := Vector3.ZERO setget set_hovered_face
func set_hovered_face(hovered_face : Vector3) -> void:
	HoveredFace = hovered_face
	update_hint()

export(Vector3) var SelectedFace := Vector3.ZERO setget set_selected_face
func set_selected_face(selected_face : Vector3) -> void:
	SelectedFace = selected_face
	
	var select_rot := Vector3.INF
	match SelectedFace:
		Vector3.RIGHT:select_rot = Vector3(0, 0, -90)
		Vector3.LEFT:select_rot = Vector3(0, 0, 90)
		Vector3.UP:select_rot = Vector3.ZERO
		Vector3.DOWN:select_rot = Vector3(180, 0, 0)
		Vector3.FORWARD:select_rot = Vector3(-90, 0, 0)
		Vector3.BACK:select_rot = Vector3(90, 0, 0)
	
	if _2DView:
		for side in _2DView.get_children():
			if side.name == normal_to_string(SelectedFace).capitalize():
				side.disabled = true
				side.modulate = Color.white.contrasted()
			else:
				side.disabled = false
				side.modulate = Color.white
	
	if SelectPivot:
		SelectPivot.visible = not select_rot == Vector3.INF
		if not select_rot == Vector3.INF:
			SelectPivot.rotation_degrees = select_rot
		if Select:
			Select.material_override.albedo_color = Color.white.contrasted()
	
	update_hint()
	emit_signal("selected_face", SelectedFace)


export(int, 0, 100) var MouseSensitivity := 6



# Helpers
func normal_to_string(normal : Vector3) -> String:
	var string := ""
	match normal:
		Vector3.RIGHT:string = "RIGHT"
		Vector3.LEFT: string = "LEFT"
		Vector3.UP: string = "TOP"
		Vector3.DOWN: string = "BOTTOM"
		Vector3.FORWARD: string = "FRONT"
		Vector3.BACK: string = "BACK"
	return string



# Core
func _ready():
	set_view_mode(ViewMode)
	set_selected_face(SelectedFace)


func setup_voxel(voxel : int, voxelset : VoxelSet) -> void:
	setup_rvoxel(
		voxelset.get_voxel(voxel),
		voxelset
	)
	Represents[0] = voxel

func setup_rvoxel(voxel : Dictionary, voxelset : VoxelSet = null) -> void:
	Represents[0] = voxel
	Represents[1] = voxelset


func update_hint() -> void:
	if ViewerHint:
		ViewerHint.text = normal_to_string(SelectedFace).to_upper()
		if SelectedFace != HoveredFace and HoveredFace != Vector3.ZERO:
			if not ViewerHint.text.empty(): ViewerHint.text += " | "
			ViewerHint.text += normal_to_string(HoveredFace).to_upper()


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
	update_hint()

func _on_VoxelStaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if not dragging:
		Input.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed() and event.doubleclick:
			if SelectMode: set_selected_face(click_normal.round())
		elif event.button_index == BUTTON_RIGHT :
			if EditMode: ContextMenu.popup(Rect2(
				event.position,
				Vector2(90, 124)
			))
	set_hovered_face(click_normal.round())
