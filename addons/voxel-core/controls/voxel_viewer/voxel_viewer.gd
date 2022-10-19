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



## Constants
# Default environment used
var DefaultEnv := preload("res://addons/voxel-core/controls/voxel_viewer/voxel_viewer_env.tres")



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

# Environment used in 3D view
export(Environment) var environment := DefaultEnv setget set_environment



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

onready var ViewPort := get_node("View3D/Viewport")

onready var CameraPivot := get_node("View3D/Viewport/CameraPivot")

onready var CameraRef := get_node("View3D/Viewport/CameraPivot/Camera")

onready var VoxelPreview := get_node("View3D/Viewport/VoxelPreview")

onready var Select := get_node("View3D/Viewport/Select")

onready var ViewModeRef := get_node("ToolBar/ViewMode")

onready var ViewerHint := get_node("ToolBar/Hint")

onready var ContextMenu := get_node("ContextMenu")

onready var ColorPickerMenu := get_node("ColorPickerMenu")

onready var TilePickerMenu := get_node("TilePickerMenu")

onready var MaterialMenu := get_node("MaterialMenu")

onready var MaterialRef := get_node("MaterialMenu/VBoxContainer/VBoxContainer/HBoxContainer6/Material")

onready var Metallic := get_node("MaterialMenu/VBoxContainer/VBoxContainer/HBoxContainer/Metallic")

onready var Specular := get_node("MaterialMenu/VBoxContainer/VBoxContainer/HBoxContainer2/Specular")

onready var Roughness := get_node("MaterialMenu/VBoxContainer/VBoxContainer/HBoxContainer3/Roughness")

onready var Energy := get_node("MaterialMenu/VBoxContainer/VBoxContainer/HBoxContainer4/Energy")

onready var EnergyColor := get_node("MaterialMenu/VBoxContainer/VBoxContainer/HBoxContainer5/EnergyColor")

onready var EnvironmentMenu := get_node("EnvironmentMenu")



## Built-In Virtual Methods
func _ready():
	set_view_mode(view_mode)
	set_voxel_set(voxel_set)
	load_environment()
	
	if not is_instance_valid(undo_redo):
		undo_redo = UndoRedo.new()



## Public Methods
# Saves the used environment path
func save_environment() -> void:
	if environment == DefaultEnv:
		var dir := Directory.new()
		if dir.file_exists("res://addons/voxel-core/controls/voxel_viewer/config.var"):
			dir.remove("res://addons/voxel-core/controls/voxel_viewer/config.var")
	elif is_instance_valid(environment):
		var file := File.new()
		var opened = file.open(
				"res://addons/voxel-core/controls/voxel_viewer/config.var",
				File.WRITE)
		if opened == OK:
			file.store_string(environment.resource_path)
		if file.is_open():
			file.close()


# Loads and sets the environment file
func load_environment() -> void:
	var loaded := false
	var file := File.new()
	var opened = file.open(
			"res://addons/voxel-core/controls/voxel_viewer/config.var",
			File.READ)
	if opened == OK:
		var environment_path = file.get_as_text()
		if file.file_exists(environment_path):
			var _environment := load(environment_path)
			if _environment is Environment:
				set_environment(_environment)
			loaded = true
	
	if not loaded:
		set_environment(DefaultEnv)
	
	if file.is_open():
		file.close()


# Resets the environment to default
func reset_environment() -> void:
	set_environment(DefaultEnv)
	save_environment()


func set_selection_max(value : int, update := true) -> void:
	selection_max = clamp(value, 0, 6)
	unselect_shrink()
	if update:
		self.update()


# Sets allow_edit
func set_allow_edit(value : bool) -> void:
	allow_edit = value


# Sets view_mode
func set_view_mode(value : int) -> void:
	_last_hovered_face = Vector3.ZERO
	view_mode = int(clamp(value, 0, ViewModes.size()))
	
	if is_instance_valid(ViewModeRef):
		ViewModeRef.selected = view_mode
	if is_instance_valid(View2D):
		View2D.visible = view_mode == ViewModes.VIEW_2D
	if is_instance_valid(View3D):
		View3D.visible = view_mode == ViewModes.VIEW_3D


# Sets voxel_id, calls on update_view by defalut
func set_voxel_id(value : int, update := true) -> void:
	voxel_id = value
	if update:
		update_view()


# Returns true if face is selected
func has_selected(face : Vector3) -> bool:
	return _selections.has(face)


# Returns face selected at given index
func get_selected(index : int) -> Vector3:
	return _selections[index]


# Returns array of selected faces
func get_selections() -> Array:
	return _selections.duplicate()


# Returns number of faces selected
func get_selected_size() -> int:
	return _selections.size()


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
		if not voxel_set.is_connected("requested_refresh", self, "update_view"):
			voxel_set.connect("requested_refresh", self, "update_view")
	if is_instance_valid(TilePickerMenu):
		TilePickerMenu.voxel_set = voxel_set
	
	if update:
		update_view()


func set_environment(value : Environment) -> void:
	environment = value
	if is_instance_valid(ViewPort):
		ViewPort.transparent_bg = environment == DefaultEnv
		ViewPort.world.environment = environment


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
		_voxel_tool.begin(voxel_set, true)
		for face in Voxel.Faces:
			_voxel_tool.add_face(
					get_viewing_voxel(),
					face, -Vector3.ONE / 2)
		VoxelPreview.mesh = _voxel_tool.commit()
		
		_voxel_tool.begin(voxel_set, true)
		for selection in _selections:
			_voxel_tool.add_face(
					Voxel.colored(Color(0, 0, 0, 0.75)),
					selection, -Vector3.ONE / 2)
		Select.mesh = _voxel_tool.commit()


# Shows the context menu and options
func show_context_menu(global_position : Vector2, face := _last_hovered_face) -> void:
	if not is_instance_valid(ContextMenu):
		return
	ContextMenu.clear()
	if _last_hovered_face == Vector3.ZERO:
		ContextMenu.add_item("Change environment", 14)
		if environment != DefaultEnv:
			ContextMenu.add_item("Reset environment", 15)
	elif allow_edit:
		_editing_face = face
		_editing_multiple = false
		var selected_hovered := _selections.has(_editing_face)
		if is_instance_valid(voxel_set):
			var voxel := get_viewing_voxel()
			
			if _selections.size() < 6:
				ContextMenu.add_item("Select all", 13)
			if _selections.size() > 0:
				ContextMenu.add_item("Unselect all", 11)
			
			if _selections.size() == 0 or not selected_hovered:
				ContextMenu.add_separator()
				ContextMenu.add_item("Color side", 0)
				if Voxel.has_face_color(voxel, _editing_face):
					ContextMenu.add_item("Remove side color", 1)
				
				if voxel_set.uv_ready():
					ContextMenu.add_item("Texture side", 2)
				if Voxel.has_face_uv(voxel, _editing_face):
					ContextMenu.add_item("Remove side uv", 3)
			
			if selected_hovered and _selections.size() >= 1:
				ContextMenu.add_separator()
				ContextMenu.add_item("Color side(s)", 7)
				if Voxel.has_face_color(voxel, _editing_face):
					ContextMenu.add_item("Remove side color(s)", 8)
				
				if voxel_set.uv_ready():
					ContextMenu.add_item("Texture side(s)", 9)
				if Voxel.has_face_uv(voxel, _editing_face):
					ContextMenu.add_item("Remove side uv(s)", 10)
			
			ContextMenu.add_separator()
			ContextMenu.add_item("Color voxel", 4)
			
			ContextMenu.add_item("Modify material", 12)
			
			if voxel_set.uv_ready():
				ContextMenu.add_item("Texture voxel", 5)
			if Voxel.has_uv(voxel):
				ContextMenu.add_item("Remove voxel uv", 6)
	ContextMenu.set_as_minsize()
	
	ContextMenu.popup(Rect2(
			global_position,
			ContextMenu.rect_size))


# Shows the color menu centered with given color
func show_color_picker_menu(title : String, color : Color) -> void:
	if is_instance_valid(ColorPickerMenu):
		ColorPickerMenu.window_title = title
		ColorPickerMenu.color = color
		ColorPickerMenu.show_centered()


# Closes the color menu
func hide_color_picker_menu() -> void:
	if is_instance_valid(ColorPickerMenu):
		ColorPickerMenu.hide()
	update_view()


# Shows the texture menu centered with given color
func show_tile_picker_menu(title : String, tile : Vector2) -> void:
	if is_instance_valid(TilePickerMenu):
		TilePickerMenu.tiles_viewer.unselect_all()
		TilePickerMenu.tiles_viewer.select(tile)
		
		TilePickerMenu.window_title = title
		TilePickerMenu.show_centered()


# Closes the texture menu
func hide_tile_picker_menu() -> void:
	if is_instance_valid(TilePickerMenu):
		TilePickerMenu.hide()
	update_view()


# Shows the material menu with given voxel data
func show_material_menu(voxel := get_viewing_voxel()) -> void:
	if is_instance_valid(MaterialMenu):
		MaterialRef.value = Voxel.get_material(voxel)
		MaterialRef.max_value = voxel_set.materials.size() - 1
		Metallic.value = Voxel.get_metallic(voxel)
		Specular.value = Voxel.get_specular(voxel)
		Roughness.value = Voxel.get_roughness(voxel)
		Energy.value = Voxel.get_energy(voxel)
		EnergyColor.color = Voxel.get_energy_color(voxel)
		
		MaterialMenu.show()
		MaterialMenu.set_as_minsize()
		MaterialMenu.rect_size += Vector2(32, 32)
		MaterialMenu.rect_min_size = MaterialMenu.rect_size
		
		MaterialMenu.set_position(
				(get_viewport_rect().size / 2) - (MaterialMenu.rect_min_size / 2))


# Closes the material menu
func hide_material_menu() -> void:
	if is_instance_valid(MaterialMenu):
		MaterialMenu.hide()
	update_view()


func show_environment_change_menu() -> void:
	EnvironmentMenu.popup_centered()
	EnvironmentMenu.set_as_minsize()
	EnvironmentMenu.rect_size += Vector2(32, 32)
	EnvironmentMenu.rect_min_size = EnvironmentMenu.rect_size

func hide_environment_change_menu() -> void:
	EnvironmentMenu.hide()



## Private Methods
func _set_last_hovered_face(face : Vector3):
	_last_hovered_face = face


func _voxel_backup() -> void:
	_unedited_voxel = get_viewing_voxel().duplicate(true)


func _voxel_restore() -> void:
	voxel_set.set_voxel(voxel_id, _unedited_voxel)


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
				show_context_menu(event.global_position, _last_hovered_face)
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
			elif event.button_index == BUTTON_RIGHT and not event.is_pressed():
				show_context_menu(event.global_position, _last_hovered_face)
		
		if _is_dragging:
			View3D.set_default_cursor_shape(Control.CURSOR_MOVE)
		elif hit:
			View3D.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
		else:
			View3D.set_default_cursor_shape(Control.CURSOR_ARROW)
		update_hint()
		update_view()


func _on_ContextMenu_id_pressed(id : int):
	_editing_action = id
	_editing_multiple = false
	_voxel_backup()
	match id:
		0: # Color editing face
			show_color_picker_menu(
					"Edit Voxel's Face Color",
					Voxel.get_face_color(get_viewing_voxel(), _editing_face))
		1: # Remove editing face color
			var voxel = get_viewing_voxel()
			Voxel.remove_face_color(voxel, _editing_face)
			Voxel.clean(voxel)
			
			undo_redo.create_action("VoxelViewer : Remove voxel face color")
			undo_redo.add_do_method(voxel_set, "set_voxel", voxel_id, voxel)
			undo_redo.add_undo_method(voxel_set, "set_voxel", voxel_id, _unedited_voxel)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		2: # Texture editing face
			show_tile_picker_menu(
					"Select Voxel's Face Texture",
					Voxel.get_face_uv(get_viewing_voxel(), _editing_face))
		3: # Remove editing face uv
			var voxel := get_viewing_voxel()
			Voxel.remove_face_uv(voxel, _editing_face)
			Voxel.clean(voxel)
			
			undo_redo.create_action("VoxelViewer : Remove voxel face uv")
			undo_redo.add_do_method(voxel_set, "set_voxel", voxel_id, voxel)
			undo_redo.add_undo_method(voxel_set, "set_voxel", voxel_id, _unedited_voxel)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		7: # Color selected faces
			_editing_multiple = true
			show_color_picker_menu(
					"Edit Voxel's Face(s) Color",
					Voxel.get_face_color(get_viewing_voxel(), _editing_face))
		8: # Remove selected faces color
			_editing_multiple = true
			var voxel = get_viewing_voxel()
			for selection in _selections:
				Voxel.remove_face_color(voxel, selection)
			Voxel.clean(voxel)
			
			undo_redo.create_action("VoxelViewer : Remove voxel face(s) color")
			undo_redo.add_do_method(voxel_set, "set_voxel", voxel_id, voxel)
			undo_redo.add_undo_method(voxel_set, "set_voxel", voxel_id, _unedited_voxel)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		9: # Texture selected face
			_editing_multiple = true
			show_tile_picker_menu(
					"Edit Voxel's Face(s) Texture",
					Voxel.get_face_uv(get_viewing_voxel(), _editing_face))
		10: # Remove selected face uv
			_editing_multiple = true
			var voxel := get_viewing_voxel()
			for selection in _selections:
				Voxel.remove_face_uv(voxel, selection)
			Voxel.clean(voxel)
			
			undo_redo.create_action("VoxelViewer : Remove voxel face(s) uv")
			undo_redo.add_do_method(voxel_set, "set_voxel", voxel_id, voxel)
			undo_redo.add_undo_method(voxel_set, "set_voxel", voxel_id, _unedited_voxel)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		4: # Set voxel color
			show_color_picker_menu(
					"Edit Voxel's Color",
					Voxel.get_color(get_viewing_voxel()))
		5: # Set voxel uv
			show_tile_picker_menu(
					"Edit Voxel's Texture",
					Voxel.get_uv(get_viewing_voxel()))
		6: # Remove voxel uv
			var voxel = voxel_set.get_voxel(voxel_id)
			Voxel.remove_uv(voxel)
			Voxel.clean(voxel)
			
			undo_redo.create_action("VoxelViewer : Remove voxel uv")
			undo_redo.add_do_method(voxel_set, "set_voxel", voxel_id, voxel)
			undo_redo.add_undo_method(voxel_set, "set_voxel", voxel_id, _unedited_voxel)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		13: # Select all
			unselect_all()
			for face in Voxel.Faces:
				select(face)
		11: # Unselect all
			unselect_all()
		12: # Modify material
			show_material_menu()
		14:
			show_environment_change_menu()
		15:
			reset_environment()


func _on_ColorPickerMenu_color_changed(color : Color):
	match _editing_action:
		0, 7:
			for selection in (_selections if _editing_multiple else [_editing_face]):
				Voxel.set_face_color(get_viewing_voxel(), selection, color)
		4: Voxel.set_color(get_viewing_voxel(), color)
	update_view()


func _on_ColorPickerMenu_color_picked(color : Color):
	match _editing_action:
		0, 7:
			var voxel = get_viewing_voxel()
			Voxel.clean(voxel)
			
			undo_redo.create_action("VoxelViewer : Set voxel face(s) color")
			undo_redo.add_do_method(voxel_set, "set_voxel", voxel_id, voxel)
			undo_redo.add_undo_method(voxel_set, "set_voxel", voxel_id, _unedited_voxel)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		4:
			var voxel = get_viewing_voxel()
			Voxel.clean(voxel)
			
			undo_redo.create_action("VoxelViewer : Set voxel color")
			undo_redo.add_do_method(voxel_set, "set_voxel", voxel_id, voxel)
			undo_redo.add_undo_method(voxel_set, "set_voxel", voxel_id, _unedited_voxel)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
	hide_color_picker_menu()


func _on_TilePickerMenu_tile_selected(tile : Vector2) -> void:
	match _editing_action:
		2, 9: 
			for selection in (_selections if _editing_multiple else [_editing_face]):
				Voxel.set_face_uv(get_viewing_voxel(), selection, tile)
		5:
			Voxel.set_uv(get_viewing_voxel(), tile)
	update_view()


func _on_TilePickerMenu_tile_unselected(tile : Vector2) -> void:
	pass # Replace with function body.


func _on_TilePickerMenu_tile_picked(tiles : Array):
	match _editing_action:
		2, 9:
			var voxel = get_viewing_voxel()
			Voxel.clean(voxel)
			
			undo_redo.create_action("VoxelViewer : Set voxel face(s) uv")
			undo_redo.add_do_method(voxel_set, "set_voxel", voxel_id, voxel)
			undo_redo.add_undo_method(voxel_set, "set_voxel", voxel_id, _unedited_voxel)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
		5:
			var voxel = get_viewing_voxel()
			Voxel.clean(voxel)
			
			undo_redo.create_action("VoxelViewer : Set voxel uv")
			undo_redo.add_do_method(voxel_set, "set_voxel", voxel_id, voxel)
			undo_redo.add_undo_method(voxel_set, "set_voxel", voxel_id, _unedited_voxel)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
	hide_tile_picker_menu()


func _on_Metallic_value_changed(metallic : float):
	Voxel.set_metallic(get_viewing_voxel(), metallic)
	update_view()


func _on_Specular_value_changed(specular : float):
	Voxel.set_specular(get_viewing_voxel(), specular)
	update_view()


func _on_Roughness_value_changed(roughness : float):
	Voxel.set_roughness(get_viewing_voxel(), roughness)
	update_view()


func _on_Energy_value_changed(emergy : float):
	Voxel.set_energy(get_viewing_voxel(), emergy)
	update_view()


func _on_EnergyColor_changed(color : Color):
	Voxel.set_energy_color(get_viewing_voxel(), color)
	update_view()


func _on_Material_value_changed(value : int):
	Metallic.editable = value == -1
	Specular.editable = value == -1
	Roughness.editable = value == -1
	Energy.editable = value == -1
	EnergyColor.disabled = value > -1
	
	Voxel.set_material(get_viewing_voxel(), value)
	update_view()


func _on_MaterialMenu_Cancel_pressed():
	_voxel_restore()
	
	hide_material_menu()


func _on_MaterialMenu_Confirm_pressed():
	var voxel = get_viewing_voxel()
	Voxel.clean(voxel)
	
	undo_redo.create_action("VoxelViewer : Set voxel material")
	undo_redo.add_do_method(voxel_set, "set_voxel", voxel_id, voxel)
	undo_redo.add_undo_method(voxel_set, "set_voxel", voxel_id, _unedited_voxel)
	undo_redo.add_do_method(voxel_set, "request_refresh")
	undo_redo.add_undo_method(voxel_set, "request_refresh")
	undo_redo.commit_action()
	
	hide_material_menu()


func _on_EnvironmentMenu_file_selected(path):
	var _environment = load(path)
	if _environment is Environment:
		set_environment(_environment)
		property_list_changed_notify()
		save_environment()
