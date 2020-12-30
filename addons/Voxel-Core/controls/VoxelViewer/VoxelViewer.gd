tool
extends Control
# 2D / 3D preview of a voxel, that allows for selection and editing of faces.



## Signals
# Emitted when a voxel face has been selected
signal selected_face(face)
# Emitted when a voxel face has been unselected
signal unselected_face(face)



## Enums
# View modes available
enum ViewModes { VIEW_2D, VIEW_3D }



## Exported Variables
# Number of uv positions that can be selected at any one time
export(int, 0, 6) var selection_max := 0 setget set_selection_max

# Flag indicating whether edits are allowed
export var allow_edit := false setget set_allow_edit

# Current view being shown
export(ViewModes) var view_mode := ViewModes.VIEW_3D setget set_view_mode

# View sensitivity for the 3D view
export(int, 0, 100) var camera_sensitivity := 8

# ID of voxel to represented
export var voxel_id : int setget set_voxel_id

# VoxelSet beings used
export(Resource) var voxel_set = null setget set_voxel_set



## Public Variables
# UndoRedo used to commit operations
var undo_redo : UndoRedo



## Private Variables
# Selected voxel ids
var _selections := []

# VoxelTool used for Mesh generation
var _voxel_tool := VoxelTool.new()

# Internal flag used to know whether user is dragging in 3D view
var _is_dragging := false

# Internal flag used to know the last face the user hovered
var _last_hovered_face := Vector3.ZERO

# Internal value used to revert to old versions of voxel data
var _unedited_voxel := {}

# Internal flag used to indicate the operation being committed
var _editing_action := -1

# Internal flag used to indicate the face being edited
var _editing_face := Vector3.ZERO

# Internal flag used to indicate whether multiple faces are being edited
var _editing_multiple := false



## OnReady Variables
onready var View2D := get_node("View2D")
onready var View3D := get_node("View3D")

onready var CameraPivot := get_node("View3D/Viewport/CameraPivot")
onready var CameraRef := get_node("View3D/Viewport/CameraPivot/Camera")

onready var VoxelPreview := get_node("View3D/Viewport/VoxelPreview")
onready var Select := get_node("View3D/Viewport/Select")

onready var view_modeRef := get_node("ToolBar/ViewMode")
onready var ViewerHint := get_node("ToolBar/Hint")

onready var ContextMenu := get_node("ContextMenu")

onready var ColorMenu := get_node("ColorMenu")
onready var VoxelColor := get_node("ColorMenu/VBoxContainer/VoxelColor")

onready var TextureMenu := get_node("TextureMenu")
onready var VoxelTexture := get_node("TextureMenu/VBoxContainer/ScrollContainer/VoxelTexture")



## Built-In Virtual Methods
func _ready():
	set_view_mode(view_mode)
	set_voxel_set(voxel_set)
	
	if not is_instance_valid(undo_redo):
		undo_redo = UndoRedo.new()



## Public Methods
func set_selection_max(value : int, update := true) -> void:
	selection_max = clamp(value, 0, 6)
	unselect_shrink()
	if update:
		self.update()


# Sets allow_edit
func set_allow_edit(allow_edit : bool) -> void:
	allow_edit = allow_edit


# Sets view_mode
func set_view_mode(value : int) -> void:
	_last_hovered_face = Vector3.ZERO
	view_mode = int(clamp(value, 0, ViewModes.size()))
	
	if is_instance_valid(view_modeRef):
		view_modeRef.selected = view_mode
	if is_instance_valid(View2D):
		View2D.visible = view_mode == ViewModes.VIEW_2D
	if is_instance_valid(View3D):
		View3D.visible = view_mode == ViewModes.VIEW_2D


# Sets voxel_id, calls on update_view by defalut
func set_voxel_id(value : int, update := true) -> void:
	voxel_id = value
	if update:
		update_view()


# Sets voxel_set, and calls on update by default
func set_voxel_set(value : Resource, update := true) -> void:
	if not (typeof(value) == TYPE_NIL or value is VoxelSet):
		printerr("Invalid Resource given expected VoxelSet")
		return
	
	if is_instance_valid(voxel_set):
		if voxel_set.is_connected("requested_refresh", self, "update_view"):
			voxel_set.disconnect("requested_refresh", self, "update_view") 
	
	voxel_set = value
	if is_instance_valid(voxel_set):
		voxel_set.connect("requested_refresh", self, "update_view")
	if is_instance_valid(VoxelTexture):
		VoxelTexture.voxel_set = voxel_set
	
	if update:
		update_view()


# Return normal associated with given name
func string_to_face(string : String) -> Vector3:
	string = string.to_upper()
	var normal := Vector3.ZERO
	match string:
		"RIGHT":
			normal = Vector3.RIGHT
		"LEFT":
			normal = Vector3.LEFT
		"TOP":
			normal = Vector3.UP
		"BOTTOM":
			normal = Vector3.DOWN
		"FRONT":
			normal = Vector3.FORWARD
		"BACK":
			normal = Vector3.BACK
	return normal

# Return name associated with given face
func face_to_string(face : Vector3) -> String:
	var string := ""
	match face:
		Vector3.RIGHT:
			string = "RIGHT"
		Vector3.LEFT:
			string = "LEFT"
		Vector3.UP:
			string = "TOP"
		Vector3.DOWN:
			string = "BOTTOM"
		Vector3.FORWARD:
			string = "FRONT"
		Vector3.BACK:
			string = "BACK"
	return string


# Quick setup of voxel_set, voxel_id; calls on update_view and update_hint
func setup(voxel_set : VoxelSet, voxel_set_id : int) -> void:
	set_voxel_set(voxel_set, false)
	set_voxel_id(voxel_set_id, false)
	update_view()
	update_hint()


# Returns the voxel data of current voxel, returns a empty Dictionary if not set
func get_viewing_voxel() -> Dictionary:
	return voxel_set.get_voxel(voxel_id) if is_instance_valid(voxel_set) else {}


# Returns the VoxelButton associated with face normal
func get_voxle_button(face_normal : Vector3):
	return View2D.find_node(face_to_string(face_normal).capitalize())


# Selects given face, and emits selected_face
func select(face : Vector3, emit := true) -> void:
	if selection_max != 0:
		unselect_shrink(selection_max - 1)
		_selections.append(face)
		var voxel_button = get_voxle_button(face)
		if is_instance_valid(voxel_button):
			voxel_button.pressed = true
		if emit:
			emit_signal("selected_face", face)


# Unselects given face, and emits unselected_face
func unselect(face : Vector3, emit := true) -> void:
	if _selections.has(face):
		_selections.erase(face)
		var voxel_button = get_voxle_button(face)
		if is_instance_valid(voxel_button):
			voxel_button.pressed = false
		if emit:
			emit_signal("unselected_face", face)


# Unselects all the faces
func unselect_all() -> void:
	while not _selections.empty():
		unselect(_selections.back())


# Unselects all faces until given size is met
func unselect_shrink(size := selection_max, emit := true) -> void:
	if size >= 0:
		while _selections.size() > size:
			unselect(_selections.back(), emit)


# Updates the hint message
func update_hint() -> void:
	if is_instance_valid(ViewerHint):
		ViewerHint.text = ""
		
		if not _selections.empty():
			for i in range(len(_selections)):
				if i > 0:
					ViewerHint.text += ", "
				ViewerHint.text += face_to_string(_selections[i]).to_upper()
		
		if _last_hovered_face != Vector3.ZERO:
			if not ViewerHint.text.empty():
				ViewerHint.text += " | "
			ViewerHint.text += face_to_string(_last_hovered_face).to_upper()


# Updates the view
func update_view() -> void:
	if not is_instance_valid(voxel_set):
		return
	
	if is_instance_valid(View2D):
		for voxel_button in View2D.get_children():
			voxel_button.setup(voxel_set, voxel_id, string_to_face(voxel_button.name))
			voxel_button.hint_tooltip = voxel_button.name
	
	if is_instance_valid(VoxelPreview):
		_voxel_tool.start(true, voxel_set, 2)
		for direction in Voxel.Directions:
			_voxel_tool.add_face(
				get_viewing_voxel(),
				direction,
				-Vector3.ONE / 2
			)
		VoxelPreview.mesh = _voxel_tool.end()
		
		_voxel_tool.start(true, voxel_set, 2)
		for selection in _selections:
			_voxel_tool.add_face(
				Voxel.colored(Color(0, 0, 0, 0.75)),
				selection,
				-Vector3.ONE / 2
			)
		Select.mesh = _voxel_tool.end()


func _on_Face_gui_input(event : InputEvent, normal : Vector3) -> void:
	_last_hovered_face = normal
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			if selection_max > 0:
				if _selections.has(normal):
					unselect(normal)
				else:
					select(normal)
				accept_event()
			else:
				get_voxle_button(normal).pressed = false
		elif event.button_index == BUTTON_RIGHT:
			if allow_edit:
				setup_context_menu(event.global_position, _last_hovered_face)
	update_hint()


func _on_View3D_gui_input(event : InputEvent) -> void:
	if event is InputEventMouse:
		var from = CameraRef.project_ray_origin(event.position)
		var to = from + CameraRef.project_ray_normal(event.position) * 1000
		var hit = CameraRef.get_world().direct_space_state.intersect_ray(from, to)
		if hit.empty():
			_last_hovered_face = Vector3.ZERO
		else:
			hit["normal"] = hit["normal"].round()
			_last_hovered_face = hit["normal"]
		
		if event is InputEventMouseMotion:
			if _is_dragging:
				var motion = event.relative.normalized()
				CameraPivot.rotation_degrees.x += -motion.y * camera_sensitivity
				CameraPivot.rotation_degrees.y += -motion.x * camera_sensitivity
		elif event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.doubleclick:
					if not hit.empty() and selection_max > 0:
						if _selections.has(hit["normal"]):
							unselect(hit["normal"])
						else:
							select(hit["normal"])
				elif event.is_pressed():
					_is_dragging = true
				else:
					_is_dragging = false
			elif event.button_index == BUTTON_RIGHT and not _last_hovered_face == Vector3.ZERO:
				if allow_edit:
					setup_context_menu(event.global_position, _last_hovered_face)
		
		if _is_dragging: View3D.set_default_cursor_shape(Control.CURSOR_MOVE)
		elif hit: View3D.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
		else: View3D.set_default_cursor_shape(Control.CURSOR_ARROW)
		update_hint()
		update_view()


func setup_context_menu(global_position : Vector2, face := _last_hovered_face) -> void:
	_editing_face = face
	_editing_multiple = false
	if is_instance_valid(ContextMenu) and is_instance_valid(voxel_set):
		ContextMenu.clear()
		ContextMenu.add_item("Color side", 0)
		if Voxel.has_face_color(get_viewing_voxel(), _editing_face):
			ContextMenu.add_item("Remove side color", 1)
		
		if voxel_set.UVReady:
			ContextMenu.add_item("Texture side", 2)
		if Voxel.has_face_texture(get_viewing_voxel(), _editing_face):
			ContextMenu.add_item("Remove side texture", 3)
		
		if _selections.size() > 1:
			ContextMenu.add_separator()
			ContextMenu.add_item("Color sides", 7)
			if Voxel.has_face_color(get_viewing_voxel(), _editing_face):
				ContextMenu.add_item("Remove side colors", 8)
			
			
			if voxel_set.UVReady:
				ContextMenu.add_item("Texture sides", 9)
			if Voxel.has_face_texture(get_viewing_voxel(), _editing_face):
				ContextMenu.add_item("Remove side textures", 10)
			
			ContextMenu.add_item("Unselect all", 11)
		
		ContextMenu.add_separator()
		ContextMenu.add_item("Color voxel", 4)
		
		if voxel_set.UVReady:
			ContextMenu.add_item("Texture voxel", 5)
		if Voxel.has_texture(get_viewing_voxel()):
			ContextMenu.add_item("Remove voxel texture", 6)
		ContextMenu.set_as_minsize()
		
		ContextMenu.popup(Rect2(
			global_position,
			ContextMenu.rect_size
		))


func _on_ContextMenu_id_pressed(id : int):
	_editing_action = id
	_editing_multiple = false
	match id:
		0: # Color editing face
			_unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelColor.color = Voxel.get_face_color(get_viewing_voxel(), _editing_face)
			ColorMenu.popup_centered()
		1: # Remove editing face color
			var voxel = get_viewing_voxel()
			undo_redo.create_action("VoxelViewer : Remove side color")
			undo_redo.add_do_method(Voxel, "remove_face_color", voxel, _editing_face)
			undo_redo.add_undo_method(Voxel, "set_face_color", voxel, _editing_face, Voxel.get_face_color(voxel, _editing_face))
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		2: # Texture editing face
			_unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelTexture.unselect_all()
			VoxelTexture.select(Voxel.get_face_texture(get_viewing_voxel(), _editing_face))
			TextureMenu.popup_centered()
		3: # Remove editing face texture
			var voxel := get_viewing_voxel()
			undo_redo.create_action("VoxelViewer : Remove side texture")
			undo_redo.add_do_method(Voxel, "remove_face_texture", voxel, _editing_face)
			undo_redo.add_undo_method(Voxel, "set_face_texture", voxel, _editing_face, Voxel.get_face_texture(voxel, _editing_face))
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		7: # Color selected faces
			_editing_multiple = true
			_unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelColor.color = Voxel.get_face_color(get_viewing_voxel(), _editing_face)
			ColorMenu.popup_centered()
		8: # Remove selected faces color
			_editing_multiple = true
			var voxel = get_viewing_voxel()
			undo_redo.create_action("VoxelViewer : Remove side colors")
			for selection in _selections:
				undo_redo.add_do_method(Voxel, "remove_face_color", voxel, selection)
				undo_redo.add_undo_method(Voxel, "set_face_color", voxel, selection, Voxel.get_face_color(voxel, selection))
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		9: # Texture selected face
			_editing_multiple = true
			_unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelTexture.unselect_all()
			VoxelTexture.select(Voxel.get_face_texture(get_viewing_voxel(), _editing_face))
			TextureMenu.popup_centered()
		10: # Remove selected face texture
			_editing_multiple = true
			var voxel := get_viewing_voxel()
			undo_redo.create_action("VoxelViewer : Remove side textures")
			for selection in _selections:
				undo_redo.add_do_method(Voxel, "remove_face_texture", voxel, selection)
				undo_redo.add_undo_method(Voxel, "set_face_texture", voxel, selection, Voxel.get_face_texture(voxel, selection))
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		4: # Set voxel color
			_unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelColor.color = Voxel.get_color(get_viewing_voxel())
			ColorMenu.popup_centered()
		5: # Set voxel texture
			_unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelTexture.unselect_all()
			VoxelTexture.select(Voxel.get_texture(get_viewing_voxel()))
			TextureMenu.popup_centered()
		6: # Remove voxel texture
			var voxel = voxel_set.get_voxel(voxel_id)
			undo_redo.create_action("VoxelViewer : Remove texture")
			undo_redo.add_do_method(Voxel, "remove_texture", voxel)
			undo_redo.add_undo_method(Voxel, "set_texture", voxel, Voxel.get_texture(voxel))
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		11: unselect_all()


func _on_ColorPicker_color_changed(color : Color):
	match _editing_action:
		0, 7:
			for selection in (_selections if _editing_multiple else [_editing_face]):
				Voxel.set_face_color(get_viewing_voxel(), selection, color)
		4: Voxel.set_color(get_viewing_voxel(), color)
	update_view()


func close_ColorMenu():
	if is_instance_valid(ColorMenu):
		ColorMenu.hide()
	update_view()


func _on_ColorMenu_Cancel_pressed():
	voxel_set.Voxels[voxel_id] = _unedited_voxel
	
	close_ColorMenu()


func _on_ColorMenu_Confirm_pressed():
	match _editing_action:
		0, 7:
			var voxel = get_viewing_voxel()
			undo_redo.create_action("VoxelViewer : Set side color(s)")
			for selection in (_selections if _editing_multiple else [_editing_face]):
				var color = Voxel.get_face_color(voxel, selection)
				undo_redo.add_do_method(Voxel, "set_face_color", voxel, selection, Voxel.get_face_color(get_viewing_voxel(), selection))
				if color == Color.transparent:
					undo_redo.add_undo_method(Voxel, "remove_face_color", voxel, selection)
				else:
					undo_redo.add_undo_method(Voxel, "set_face_color", voxel, selection, color)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		4:
			var voxel = get_viewing_voxel()
			var color = Voxel.get_color(voxel)
			undo_redo.create_action("VoxelViewer : Set color")
			undo_redo.add_do_method(Voxel, "set_color", voxel, Voxel.get_color(get_viewing_voxel()))
			if color.a == 0:
				undo_redo.add_undo_method(Voxel, "remove_color", voxel)
			else:
				undo_redo.add_undo_method(Voxel, "set_color", voxel, color)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
	close_ColorMenu()


func _on_VoxelTexture_selected_uv(uv : Vector2):
	match _editing_action:
		2, 9: 
			for selection in (_selections if _editing_multiple else [_editing_face]):
				Voxel.set_face_texture(get_viewing_voxel(), selection, uv)
		5: Voxel.set_texture(get_viewing_voxel(), uv)
	update_view()


func close_TextureMenu():
	if is_instance_valid(TextureMenu):
		TextureMenu.hide()
	update_view()


func _on_TextureMenu_Cancel_pressed():
	voxel_set.Voxels[voxel_id] = _unedited_voxel
	
	close_TextureMenu()


func _on_TextureMenu_Confirm_pressed():
	match _editing_action:
		2, 9:
			var voxel = get_viewing_voxel()
			undo_redo.create_action("VoxelViewer : Set side texture(s)")
			for selection in (_selections if _editing_multiple else [_editing_face]):
				var texture = Voxel.get_face_texture(voxel, selection)
				undo_redo.add_do_method(Voxel, "set_face_texture", voxel, selection, Voxel.get_face_texture(voxel, selection))
				if texture == -Vector2.ONE:
					undo_redo.add_undo_method(Voxel, "remove_face_texture", voxel, selection)
				else:
					undo_redo.add_undo_method(Voxel, "set_face_texture", voxel, selection, texture)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		5:
			var voxel = get_viewing_voxel()
			var texture = Voxel.get_texture(voxel)
			undo_redo.create_action("VoxelViewer : Set texture")
			undo_redo.add_do_method(Voxel, "set_texture", voxel, Voxel.get_texture(voxel))
			if texture == -Vector2.ONE:
				undo_redo.add_undo_method(Voxel, "remove_texture", voxel)
			else:
				undo_redo.add_undo_method(Voxel, "set_texture", voxel, texture)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
	close_TextureMenu()
