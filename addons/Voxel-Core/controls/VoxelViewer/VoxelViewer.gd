tool
extends Control



# Refrences
onready var View2D := get_node("View2D")
onready var View3D := get_node("View3D")

onready var CameraPivot := get_node("View3D/Viewport/CameraPivot")
onready var CameraRef := get_node("View3D/Viewport/CameraPivot/Camera")

onready var VoxelPreview := get_node("View3D/Viewport/VoxelPreview")
onready var Select := get_node("View3D/Viewport/Select")

onready var ViewModeRef := get_node("ToolBar/ViewMode")
onready var ViewerHint := get_node("ToolBar/Hint")

onready var ContextMenu := get_node("ContextMenu")

onready var ColorMenu := get_node("ColorMenu")
onready var VoxelColor := get_node("ColorMenu/VBoxContainer/VoxelColor")

onready var TextureMenu := get_node("TextureMenu")
onready var VoxelTexture := get_node("TextureMenu/VBoxContainer/ScrollContainer/VoxelTexture")



# Declarations
signal selected_face(face)
signal unselected_face(face)


var Undo_Redo : UndoRedo

var VT := VoxelTool.new()


var is_dragging := false
var last_hovered_face := Vector3.ZERO setget set_last_hovered_face
func set_last_hovered_face(hovered_face : Vector3) -> void:
	last_hovered_face = hovered_face
	update_hint()


var unedited_voxel := {}
var editing_action := -1
var editing_face := Vector3.ZERO
var editing_multiple := false


export(bool) var AllowEdit := false setget set_allow_edit
func set_allow_edit(allow_edit : bool) -> void:
	AllowEdit = allow_edit

var Selections := [] setget set_selections
func set_selections(selections : Array) -> void: pass

export(int, 0, 6) var AllowedSelections := 0 setget set_allowed_selections
func set_allowed_selections(allowed_selections : int, update := true) -> void:
	AllowedSelections = clamp(allowed_selections, 0, 6)
	unselect_shrink()
	if update: self.update()

enum ViewModes { View2D, View3D }
export(ViewModes) var ViewMode := ViewModes.View3D setget set_view_mode
func set_view_mode(view_mode : int) -> void:
	last_hovered_face = Vector3.ZERO
	ViewMode = int(clamp(view_mode, 0, ViewModes.size()))
	
	if is_instance_valid(ViewModeRef):
		ViewModeRef.selected = ViewMode
	if is_instance_valid(View2D):
		View2D.visible = ViewMode == ViewModes.View2D
	if is_instance_valid(View3D):
		View3D.visible = ViewMode == ViewModes.View3D

export(int, 0, 100) var ViewSensitivity := 8

export var VoxelID : int setget set_voxel_id
func set_voxel_id(voxel_id : int, update := true) -> void:
	VoxelID = voxel_id
	if update: update_view()

export(Resource) var VoxelSetRef = null setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if not typeof(voxel_set) == TYPE_NIL and not voxel_set is VoxelSet:
		printerr("Invalid Resource given expected VoxelSet")
		return
	
	if is_instance_valid(VoxelSetRef):
		if VoxelSetRef.is_connected("requested_refresh", self, "update_view"):
			VoxelSetRef.disconnect("requested_refresh", self, "update_view") 
	
	VoxelSetRef = voxel_set
	if is_instance_valid(VoxelSetRef):
		VoxelSetRef.connect("requested_refresh", self, "update_view")
		
		if is_instance_valid(VoxelTexture):
			VoxelTexture.VoxelSetRef = VoxelSetRef
	
	if update: update_view()



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
	set_voxel_set(VoxelSetRef)
	
	if not is_instance_valid(Undo_Redo):
		Undo_Redo = UndoRedo.new()


func get_viewing_voxel() -> Dictionary:
	return VoxelSetRef.get_voxel(VoxelID) if is_instance_valid(VoxelSetRef) else {}

func get_voxle_button(face_normal : Vector3):
	return View2D.find_node(normal_to_string(face_normal).capitalize())


func select(face : Vector3, emit := true) -> void:
	if AllowedSelections != 0:
		unselect_shrink(AllowedSelections - 1)
		Selections.append(face)
		var voxel_button = get_voxle_button(face)
		if is_instance_valid(voxel_button):
			voxel_button.pressed = true
		if emit:
			emit_signal("selected_face", face)

func unselect(face : Vector3, emit := true) -> void:
	if Selections.has(face):
		Selections.erase(face)
		var voxel_button = get_voxle_button(face)
		if is_instance_valid(voxel_button):
			voxel_button.pressed = false
		if emit:
			emit_signal("unselected_face", face)

func unselect_all() -> void:
	while not Selections.empty():
		unselect(Selections.back())

func unselect_shrink(size := AllowedSelections, emit := true) -> void:
	if size >= 0:
		while Selections.size() > size:
			unselect(Selections.back(), emit)


func update_hint() -> void:
	if is_instance_valid(ViewerHint):
		ViewerHint.text = ""
		
		if not Selections.empty():
			for i in range(len(Selections)):
				if i > 0:
					ViewerHint.text += ", "
				ViewerHint.text += normal_to_string(Selections[i]).to_upper()
		
		if last_hovered_face != Vector3.ZERO:
			if not ViewerHint.text.empty():
				ViewerHint.text += " | "
			ViewerHint.text += normal_to_string(last_hovered_face).to_upper()

func update_view() -> void:
	if is_instance_valid(View2D):
		for voxel_button in View2D.get_children():
			voxel_button.setup(VoxelSetRef, VoxelID, string_to_normal(voxel_button.name))
			voxel_button.hint_tooltip = voxel_button.name
	
	if is_instance_valid(VoxelPreview):
		VT.start(true, VoxelSetRef, 2)
		for direction in Voxel.Directions:
			VT.add_face(
				get_viewing_voxel(),
				direction,
				-Vector3.ONE / 2
			)
		VoxelPreview.mesh = VT.end()
		
		VT.start(true, VoxelSetRef, 2)
		for selection in Selections:
			VT.add_face(
				Voxel.colored(Color(0, 0, 0, 0.75)),
				selection,
				-Vector3.ONE / 2
			)
		Select.mesh = VT.end()


func _on_Face_gui_input(event : InputEvent, normal : Vector3) -> void:
	last_hovered_face = normal
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			if AllowedSelections > 0:
				if Selections.has(normal):
					unselect(normal)
				else:
					select(normal)
				accept_event()
			else:
				get_voxle_button(normal).pressed = false
		elif event.button_index == BUTTON_RIGHT:
			if AllowEdit:
				setup_context_menu(event.global_position, last_hovered_face)
	update_hint()


func _on_View3D_gui_input(event : InputEvent) -> void:
	if event is InputEventMouse:
		var from = CameraRef.project_ray_origin(event.position)
		var to = from + CameraRef.project_ray_normal(event.position) * 1000
		var hit = CameraRef.get_world().direct_space_state.intersect_ray(from, to)
		if hit.empty():
			last_hovered_face = Vector3.ZERO
		else:
			hit["normal"] = hit["normal"].round()
			last_hovered_face = hit["normal"]
		
		if event is InputEventMouseMotion:
			if is_dragging:
				var motion = event.relative.normalized()
				CameraPivot.rotation_degrees.x += -motion.y * ViewSensitivity
				CameraPivot.rotation_degrees.y += -motion.x * ViewSensitivity
		elif event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.doubleclick:
					if not hit.empty() and AllowedSelections > 0:
						if Selections.has(hit["normal"]):
							unselect(hit["normal"])
						else:
							select(hit["normal"])
				elif event.is_pressed():
					is_dragging = true
				else:
					is_dragging = false
			elif event.button_index == BUTTON_RIGHT and not last_hovered_face == Vector3.ZERO:
				if AllowEdit:
					setup_context_menu(event.global_position, last_hovered_face)
		
		if is_dragging: View3D.set_default_cursor_shape(Control.CURSOR_MOVE)
		elif hit: View3D.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
		else: View3D.set_default_cursor_shape(Control.CURSOR_ARROW)
		update_hint()
		update_view()


func setup_context_menu(global_position : Vector2, face := last_hovered_face) -> void:
	editing_face = face
	editing_multiple = false
	if is_instance_valid(ContextMenu) and is_instance_valid(VoxelSetRef):
		ContextMenu.clear()
		ContextMenu.add_item("Color side", 0)
		if Voxel.has_color_side(get_viewing_voxel(), editing_face):
			ContextMenu.add_item("Remove side color", 1)
		
		ContextMenu.add_item("Texture side", 2)
		if Voxel.has_texture_side(get_viewing_voxel(), editing_face):
			ContextMenu.add_item("Remove side texture", 3)
		
		if Selections.size() > 1:
			ContextMenu.add_separator()
			ContextMenu.add_item("Color sides", 7)
			if Voxel.has_color_side(get_viewing_voxel(), editing_face):
				ContextMenu.add_item("Remove side colors", 8)
			
			ContextMenu.add_item("Texture sides", 9)
			if Voxel.has_texture_side(get_viewing_voxel(), editing_face):
				ContextMenu.add_item("Remove side textures", 10)
			
			ContextMenu.add_item("Unselect all", 11)
		
		ContextMenu.add_separator()
		ContextMenu.add_item("Color voxel", 4)
		
		ContextMenu.add_item("Texture voxel", 5)
		if Voxel.has_texture(get_viewing_voxel()):
			ContextMenu.add_item("Remove voxel texture", 6)
		ContextMenu.set_as_minsize()
		
		ContextMenu.popup(Rect2(
			global_position,
			ContextMenu.rect_size
		))

func _on_ContextMenu_id_pressed(id : int):
	editing_action = id
	editing_multiple = false
	match id:
		0: # Color editing face
			unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelColor.color = Voxel.get_color_side(get_viewing_voxel(), editing_face)
			ColorMenu.popup_centered()
		1: # Remove editing face color
			var voxel = get_viewing_voxel()
			Undo_Redo.create_action("VoxelViewer : Remove side color")
			Undo_Redo.add_do_method(Voxel, "remove_color_side", voxel, editing_face)
			Undo_Redo.add_undo_method(Voxel, "set_color_side", voxel, editing_face, Voxel.get_color_side(voxel, editing_face))
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
		2: # Texture editing face
			unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelTexture.unselect_all()
			VoxelTexture.select(Voxel.get_texture_side(get_viewing_voxel(), editing_face))
			TextureMenu.popup_centered()
		3: # Remove editing face texture
			var voxel := get_viewing_voxel()
			Undo_Redo.create_action("VoxelViewer : Remove side texture")
			Undo_Redo.add_do_method(Voxel, "remove_texture_side", voxel, editing_face)
			Undo_Redo.add_undo_method(Voxel, "set_texture_side", voxel, editing_face, Voxel.get_texture_side(voxel, editing_face))
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
		7: # Color selected faces
			editing_multiple = true
			unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelColor.color = Voxel.get_color_side(get_viewing_voxel(), editing_face)
			ColorMenu.popup_centered()
		8: # Remove selected faces color
			editing_multiple = true
			var voxel = get_viewing_voxel()
			Undo_Redo.create_action("VoxelViewer : Remove side colors")
			for selection in Selections:
				Undo_Redo.add_do_method(Voxel, "remove_color_side", voxel, selection)
				Undo_Redo.add_undo_method(Voxel, "set_color_side", voxel, selection, Voxel.get_color_side(voxel, selection))
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
		9: # Texture selected face
			editing_multiple = true
			unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelTexture.unselect_all()
			VoxelTexture.select(Voxel.get_texture_side(get_viewing_voxel(), editing_face))
			TextureMenu.popup_centered()
		10: # Remove selected face texture
			editing_multiple = true
			var voxel := get_viewing_voxel()
			Undo_Redo.create_action("VoxelViewer : Remove side textures")
			for selection in Selections:
				Undo_Redo.add_do_method(Voxel, "remove_texture_side", voxel, selection)
				Undo_Redo.add_undo_method(Voxel, "set_texture_side", voxel, selection, Voxel.get_texture_side(voxel, selection))
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
		4: # Set voxel color
			unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelColor.color = Voxel.get_color(get_viewing_voxel())
			ColorMenu.popup_centered()
		5: # Set voxel texture
			unedited_voxel = get_viewing_voxel().duplicate(true)
			VoxelTexture.unselect_all()
			VoxelTexture.select(Voxel.get_texture(get_viewing_voxel()))
			TextureMenu.popup_centered()
		6: # Remove voxel texture
			var voxel = VoxelSetRef.get_voxel(VoxelID)
			Undo_Redo.create_action("VoxelViewer : Remove texture")
			Undo_Redo.add_do_method(Voxel, "remove_texture", voxel)
			Undo_Redo.add_undo_method(Voxel, "set_texture", voxel, Voxel.get_texture(voxel))
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
		11: unselect_all()


func _on_ColorPicker_color_changed(color : Color):
	match editing_action:
		0, 7:
			for selection in (Selections if editing_multiple else [editing_face]):
				Voxel.set_color_side(get_viewing_voxel(), selection, color)
		4: Voxel.set_color(get_viewing_voxel(), color)
	update_view()

func close_ColorMenu():
	if is_instance_valid(ColorMenu):
		ColorMenu.hide()
	update_view()

func _on_ColorMenu_Cancel_pressed():
	VoxelSetRef.Voxels[VoxelID] = unedited_voxel
	
	close_ColorMenu()

func _on_ColorMenu_Confirm_pressed():
	match editing_action:
		0, 7:
			var voxel = get_viewing_voxel()
			Undo_Redo.create_action("VoxelViewer : Set side color(s)")
			for selection in (Selections if editing_multiple else [editing_face]):
				var color = Voxel.get_color_side(voxel, selection)
				Undo_Redo.add_do_method(Voxel, "set_color_side", voxel, selection, Voxel.get_color_side(get_viewing_voxel(), Selections[0]))
				if color == Color.transparent:
					Undo_Redo.add_undo_method(Voxel, "remove_color_side", voxel, selection)
				else:
					Undo_Redo.add_undo_method(Voxel, "set_color_side", voxel, selection, color)
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
		4:
			var voxel = get_viewing_voxel()
			var color = Voxel.get_color(voxel)
			Undo_Redo.create_action("VoxelViewer : Set color")
			Undo_Redo.add_do_method(Voxel, "set_color", voxel, Voxel.get_color(get_viewing_voxel()))
			if color.a == 0:
				Undo_Redo.add_undo_method(Voxel, "remove_color", voxel)
			else:
				Undo_Redo.add_undo_method(Voxel, "set_color", voxel, color)
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
	close_ColorMenu()


func _on_VoxelTexture_selected_uv(uv : Vector2):
	match editing_action:
		2, 9: 
			for selection in (Selections if editing_multiple else [editing_face]):
				Voxel.set_texture_side(get_viewing_voxel(), selection, uv)
		5: Voxel.set_texture(get_viewing_voxel(), uv)
	update_view()

func close_TextureMenu():
	if is_instance_valid(TextureMenu):
		TextureMenu.hide()
	update_view()

func _on_TextureMenu_Cancel_pressed():
	VoxelSetRef.Voxels[VoxelID] = unedited_voxel
	
	close_TextureMenu()

func _on_TextureMenu_Confirm_pressed():
	match editing_action:
		2, 9:
			var voxel = get_viewing_voxel()
			Undo_Redo.create_action("VoxelViewer : Set side texture(s)")
			for selection in (Selections if editing_multiple else [editing_face]):
				var texture = Voxel.get_texture_side(voxel, selection)
				Undo_Redo.add_do_method(Voxel, "set_texture_side", voxel, selection, Voxel.get_texture_side(voxel, Selections[0]))
				if texture == -Vector2.ONE:
					Undo_Redo.add_undo_method(Voxel, "remove_texture_side", voxel, selection)
				else:
					Undo_Redo.add_undo_method(Voxel, "set_texture_side", voxel, selection, texture)
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
		5:
			var voxel = get_viewing_voxel()
			var texture = Voxel.get_texture(voxel)
			Undo_Redo.create_action("VoxelViewer : Set texture")
			Undo_Redo.add_do_method(Voxel, "set_texture", voxel, Voxel.get_texture(voxel))
			if texture == -Vector2.ONE:
				Undo_Redo.add_undo_method(Voxel, "remove_texture", voxel)
			else:
				Undo_Redo.add_undo_method(Voxel, "set_texture", voxel, texture)
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
	close_TextureMenu()
