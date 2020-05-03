tool
extends Control



# Refrences
onready var ContextMenu := get_node("ContextMenu")
onready var ColorMenu := get_node("ColorMenu")
onready var TextureMenu := get_node("TextureMenu")


onready var ViewModeRef := get_node("ToolBar/ViewMode")
onready var ViewerHint := get_node("ToolBar/Hint")


onready var _2DView := get_node("2DView")


onready var _3DView := get_node("3DView")

onready var CameraPivot := get_node("3DView/Viewport/CameraPivot")
onready var CameraRef := get_node("3DView/Viewport/CameraPivot/Camera")

onready var SelectPivot := get_node("3DView/Viewport/SelectPivot")
onready var Select := get_node("3DView/Viewport/SelectPivot/Select")

onready var VoxelPreview := get_node("3DView/Viewport/VoxelPreview")

onready var VoxelColor := get_node("ColorMenu/VBoxContainer/VoxelColor")
onready var VoxelTexture := get_node("TextureMenu/VBoxContainer/ScrollContainer/VoxelTexture")



# Declarations
signal selected_face(normal)


var VT := VoxelTool.new()


var dragging := false
var edit_action := -1


var placeholder := {}
var Represents := [null, null] setget set_represents
func set_represents(represents : Array) -> void: pass


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
	
	if ViewModeRef:
		ViewModeRef.selected = ViewMode
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
func string_to_normal(string : String) -> Vector3:
	string = string.to_lower()
	var normal := Vector3.ZERO
	match string:
		"right": normal = Vector3.RIGHT
		"left": normal = Vector3.LEFT
		"top": normal = Vector3.UP
		"bottom": normal = Vector3.DOWN
		"front": normal = Vector3.FORWARD
		"back": normal = Vector3.BACK
	return normal

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
	
	if ContextMenu:
		ContextMenu.add_item("Color side", 0)
		ContextMenu.add_item("Remove side's color", 1)
		ContextMenu.add_item("Texture side", 2)
		ContextMenu.add_item("Remove side's texture", 3)
		ContextMenu.add_separator()
		ContextMenu.add_item("Color voxel", 4)
		ContextMenu.add_item("Texture voxel", 5)
		ContextMenu.add_item("Remove voxel's texture", 6)


func setup_voxel(voxel : int, voxelset : VoxelSet) -> void:
	setup_rvoxel(
		voxelset.get_voxel(voxel),
		voxelset
	)
	Represents[0] = voxel

func setup_rvoxel(voxel : Dictionary, voxelset : VoxelSet = null) -> void:
	placeholder = voxel.duplicate(true)
	Represents[0] = voxel
	Represents[1] = voxelset
	update_voxel_preview()


func get_real_voxel() -> Dictionary:
	var voxel := {}
	match typeof(Represents[0]):
		TYPE_DICTIONARY: voxel = Represents[0]
		TYPE_INT, TYPE_STRING:
			if is_instance_valid(Represents[1]):
				voxel = Represents[1].get_voxel(Represents[0])
	return voxel


func update_hint() -> void:
	if ViewerHint:
		ViewerHint.text = normal_to_string(SelectedFace).to_upper()
		if SelectedFace != HoveredFace and HoveredFace != Vector3.ZERO:
			if not ViewerHint.text.empty(): ViewerHint.text += " | "
			ViewerHint.text += normal_to_string(HoveredFace).to_upper()

func update_voxel_preview() -> void:
	if _2DView:
		for side in _2DView.get_children():
			side.setup_rvoxel(
				placeholder,
				Represents[1],
				string_to_normal(side.name)
			)
	
	if VoxelPreview:
		VT.start(true, 2)
		for direction in [
			Vector3.RIGHT,
			Vector3.LEFT,
			Vector3.UP,
			Vector3.DOWN,
			Vector3.FORWARD,
			Vector3.BACK
		]:
			VT.add_face(
				placeholder,
				direction,
				-Vector3.ONE / 2
			)
		VoxelPreview.mesh = VT.end()


func _on_Face_gui_input(event : InputEvent, normal : Vector3) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed() and event.doubleclick:
			if SelectMode: set_selected_face(normal)
		elif event.button_index == BUTTON_RIGHT :
			if EditMode: ContextMenu.popup(Rect2(
				event.global_position,
				Vector2(90, 124)
			))
	set_hovered_face(normal)


func _on_3DView_gui_input(event : InputEvent) -> void:
	if event is InputEventMouse:
		var from = CameraRef.project_ray_origin(event.position)
		var to = from + CameraRef.project_ray_normal(event.position) * 1000
		var hit = CameraRef.get_world().direct_space_state.intersect_ray(from, to)
		
		if hit:
			hit["normal"] = hit["normal"].round()
			set_hovered_face(hit["normal"])
		else: set_hovered_face(Vector3.ZERO)
		
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.doubleclick:
					if hit and SelectMode: set_selected_face(hit["normal"])
				elif event.is_pressed(): dragging = true
				else: dragging = false
			elif event.button_index == BUTTON_RIGHT and not HoveredFace == Vector3.ZERO:
				if EditMode: ContextMenu.popup(Rect2(
					event.global_position,
					Vector2(90, 124)
				))
		elif event is InputEventMouseMotion:
			if dragging:
				var motion = event.relative.normalized()
				CameraPivot.rotation_degrees.x += -motion.y * MouseSensitivity
				CameraPivot.rotation_degrees.y += -motion.x * MouseSensitivity
		
		if dragging: _3DView.set_default_cursor_shape(Control.CURSOR_MOVE)
		elif hit: _3DView.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
		else: _3DView.set_default_cursor_shape(Control.CURSOR_ARROW)


func _on_ContextMenu_id_pressed(id):
	edit_action = id
	match id:
		0:
			ColorMenu.popup_centered()
		1:
			Voxel.remove_color_side(get_real_voxel(), HoveredFace)
		2:
			TextureMenu.popup_centered()
		3:
			Voxel.remove_texture_side(get_real_voxel(), HoveredFace)
		4:
			ColorMenu.popup_centered()
		5:
			TextureMenu.popup_centered()
		6:
			Voxel.remove_texture(get_real_voxel(), HoveredFace)


func _on_ColorPicker_color_changed(color):
	match edit_action:
		0: Voxel.set_color_side(placeholder, HoveredFace, color)
		4: Voxel.set_color(placeholder, color)
	update_voxel_preview()

func _on_ColorMenu_Cancel_pressed():
	placeholder = get_real_voxel().duplicate(true)
	if ColorMenu: ColorMenu.hide()

func _on_ColorMenu_Confirm_pressed():
	if ColorMenu:
		match edit_action:
			0:
				Voxel.set_color_side(get_real_voxel(), HoveredFace, VoxelColor.color)
			4:
				Voxel.set_color(get_real_voxel(), VoxelColor.color)
		ColorMenu.hide()


func _on_TilesViewer_select(uv):
	match edit_action:
		2:
			Voxel.set_texture_side(placeholder, HoveredFace, uv)
		5:
			Voxel.set_texture_color(placeholder, uv)
	update_voxel_preview()

func _on_TextureMenu_Cancel_pressed():
	placeholder = get_real_voxel().duplicate(true)
	TextureMenu.hide()

func _on_TextureMenu_Confirm_pressed():
	if TextureMenu:
		match edit_action:
			2:
				Voxel.set_texture_side(get_real_voxel(), HoveredFace, VoxelTexture.Selections[0])
			5:
				Voxel.set_texture_color(get_real_voxel(), VoxelTexture.Selections[0])
		TextureMenu.hide()
