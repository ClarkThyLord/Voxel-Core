tool
extends VoxelEditorGUI



# References
onready var camera : Camera = $root/VBoxContainer/ViewportContainer/Viewport/Origin/Camera
onready var light : DirectionalLight = $root/VBoxContainer/ViewportContainer/Viewport/Origin/Camera/DirectionalLight
onready var voxelobject : VoxelObject = $root/VBoxContainer/ViewportContainer/Viewport/VoxelObject

onready var tool_selector := get_node('root/VBoxContainer/toolbar/HBoxContainer/tools/ToolSelector')

onready var paint_color : ColorPickerButton = $root/VBoxContainer/toolbar/HBoxContainer/tools/color

onready var mirror_x : CheckBox = $root/VBoxContainer/toolbar/HBoxContainer/mirror/x
onready var mirror_y : CheckBox = $root/VBoxContainer/toolbar/HBoxContainer/mirror/y
onready var mirror_z : CheckBox = $root/VBoxContainer/toolbar/HBoxContainer/mirror/z

onready var voxel_set_viewer := $VoxelSetViewer

onready var settings : Button = $root/VBoxContainer/toolbar/HBoxContainer/editor/settings
onready var settings_dialog : WindowDialog = $editor_settings
onready var custom_editor : CheckBox = $editor_settings/CenterContainer/editor/custom_editor
onready var editor_color : ColorPickerButton = $editor_settings/CenterContainer/editor/color
onready var cursor_visible : CheckBox = $editor_settings/CenterContainer/cursor/visible
onready var cursor_color : ColorPickerButton = $editor_settings/CenterContainer/cursor/color
onready var floor_solid : CheckBox = $editor_settings/CenterContainer/floor/solid
onready var floor_constant : CheckBox = $editor_settings/CenterContainer/floor/constant
onready var floor_color : ColorPickerButton = $editor_settings/CenterContainer/floor/color

onready var commit : Button = $root/VBoxContainer/toolbar/HBoxContainer/options/commit
onready var commit_confirm : ConfirmationDialog = $confirm_commit
onready var clear : Button = $root/VBoxContainer/toolbar/HBoxContainer/options/clear
onready var clear_confirm : ConfirmationDialog = $confirm_clear



# Declarations
var VoxelObjectRef : VoxelObject = null

export var mouse_zoom_sensitivity : float = 0.5
export var mouse_movement_sensitivity : int = 2
export var sensitivity_multiplier : float = 2


func is_fixed_level(fixed_level : int = 1) -> bool:
	return .is_fixed_level(2)


# Sets the VoxelEditor GUI's VoxelEditor to which it will send it's input to; NOTE: setting VoxelEditorOwner is necessary
func set_voxeleditorowner(voxeleditorowner : VoxelEditor, emit : bool = true) -> void:
	if VoxelEditorOwner:
		voxeleditorowner.disconnect('begined', self, 'update_voxelobject')

		VoxelEditorOwner.disconnect('set_tool', tool_selector, '_select_int')

		VoxelEditorOwner.disconnect('set_paint_color', paint_color, 'set_pick_color')

		VoxelEditorOwner.disconnect('set_mirror_x', mirror_x, 'set_pressed')
		VoxelEditorOwner.disconnect('set_mirror_x_lock', mirror_x, 'set_disabled')
		VoxelEditorOwner.disconnect('set_mirror_y', mirror_y, 'set_pressed')
		VoxelEditorOwner.disconnect('set_mirror_y_lock', mirror_y, 'set_disabled')
		VoxelEditorOwner.disconnect('set_mirror_z', mirror_z, 'set_pressed')
		VoxelEditorOwner.disconnect('set_mirror_z_lock', mirror_z, 'set_disabled')

		VoxelEditorOwner.disconnect('set_cursor_visible', cursor_visible, 'set_pressed')
		VoxelEditorOwner.disconnect('set_cursor_color', cursor_color, 'set_pick_color')
		VoxelEditorOwner.disconnect('set_floor_solid', floor_solid, 'set_pressed')
		VoxelEditorOwner.disconnect('set_floor_constant', floor_constant, 'set_pressed')
		VoxelEditorOwner.disconnect('set_floor_color', cursor_color, 'set_pick_color')

	voxeleditorowner.connect('begined', self, 'update_voxelobject')

	voxeleditorowner.connect('set_tool', tool_selector, '_select_int')

	voxeleditorowner.connect('set_paint_color', paint_color, 'set_pick_color')

	voxeleditorowner.connect('set_mirror_x', mirror_x, 'set_pressed')
	voxeleditorowner.connect('set_mirror_x_lock', mirror_x, 'set_disabled')
	voxeleditorowner.connect('set_mirror_y', mirror_y, 'set_pressed')
	voxeleditorowner.connect('set_mirror_y_lock', mirror_y, 'set_disabled')
	voxeleditorowner.connect('set_mirror_z', mirror_z, 'set_pressed')
	voxeleditorowner.connect('set_mirror_z_lock', mirror_z, 'set_disabled')

	voxeleditorowner.connect('set_cursor_visible', cursor_visible, 'set_pressed')
	voxeleditorowner.connect('set_cursor_color', cursor_color, 'set_pick_color')
	voxeleditorowner.connect('set_floor_solid', floor_solid, 'set_pressed')
	voxeleditorowner.connect('set_floor_constant', floor_constant, 'set_pressed')
	voxeleditorowner.connect('set_floor_color', cursor_color, 'set_pick_color')
	
	.set_voxeleditorowner(voxeleditorowner, emit)


# Sets the VoxelEditor's GUI active status
# active        :   bool          -   true, is active and visible; false, is not active and invisible
# voxelobject   :   VoxelObject   -   VoxelObject to be edited
# options       :   Dictionary    -   options for custom usage
# gui_options   :   Dictionary    -   options ::
#                                      tools     :   Array     :   array of Tools to be enabled
#                                       Example:
#                                         { 'tools': [ VoxelEditor.Tools.ADD, VoxelEditor.Tools.PAINT ] } -> (enable add and paint tool)
#                                      mirrors   :   Vector3   :   mirror options to enable
#                                       Example:
#                                         { 'mirrors': Vector3(1, 0, 1) } -> (enable x,z mirror and disable y mirror)
# emit          :   bool          -   true, emit 'set_active' signal; false, don't emit 'set_active' signal
#
# Example:
#   set_active(true, [VoxelObject], { ... }, false)
#
func set_active(active : bool = !Active, voxelobject = null, options : Dictionary = {}, emit : bool = true) -> void:
	if active:
		if voxelobject == null and VoxelEditorOwner.VoxelObjectRef: update_voxelobject()

		set_tools(options['tools'] if options.has('tools') else [
				VoxelEditor.Tools.ADD,
				VoxelEditor.Tools.REMOVE,
				VoxelEditor.Tools.PAINT,
				VoxelEditor.Tools.COLOR_PICKER
			]
		)
		
		set_mirrors(options['mirrors'] if options.has('mirrors') else Vector3.ONE)
		
		commit_disabled(!options['commit'] if options.has('commit') else false)
		clear_disabled(!options['clear'] if options.has('clear') else false)

	if voxelobject != null: update_voxelobject(voxelobject)
	if options.get('prompt') == 'commit' and self.voxelobject == VoxelEditorOwner.VoxelObjectRef:
		VoxelObjectRef.Voxels = self.voxelobject.Voxels
	if options.get('prompt') == 'commit' or options.get('prompt') == 'clear': VoxelObjectRef = null

	.set_active(active, self.voxelobject if active else null, options, emit)


signal set_tools(tools)
export var Tools : Array = [] setget set_tools
# Sets the array of Tools to be enabled
# tools   :   Array   -   array of Tools to be enabled
# emit    :   bool    -   true, emit 'set_tools' signal; false, don't emit 'set_tools' signal
#
# Example:
#   set_tools([ VoxelEditor.Tools.ADD, VoxelEditor.Tools.PAINT ], false) -> (enable add and paint tool)
#
func set_tools(tools : Array, emit : bool = true) -> void:
	tool_selector.set_visible_tools(tools)
	
	Tools = tools
	
	if emit: emit_signal('set_tools', Tools)

signal set_mirrors(mirrros)
export var Mirrors : Vector3 = Vector3(1, 1, 1) setget set_mirrors
# Sets the mirror options to enable
# mirrors   :   Vector3   -   mirror options to enable
# emit      :   bool      -   true, emit 'set_mirrors' signal; false, don't emit 'set_mirrors' signal
#
# Example:
#   set_mirrors(Vector3(1, 0, 1), false)
#
func set_mirrors(mirrors : Vector3, emit : bool = true):
	mirror_x.visible = mirrors.x > 0
	mirror_y.visible = mirrors.y > 0
	mirror_z.visible = mirrors.z > 0
	
	Mirrors = mirrors
	
	if emit: emit_signal('set_mirrors', Mirrors)



# Core
func _ready() -> void:
	if !Engine.editor_hint: custom_editor.visible = false
	else: visible = Active
	
	set_process_input(false)
	set_process_unhandled_key_input(false)
	
	if is_fixed_level(): set_voxeleditorownerpath(VoxelEditorOwnerPath)


func update_voxelobject(voxelobject := VoxelEditorOwner.VoxelObjectRef) -> void:
	if voxelobject != self.voxelobject:
		VoxelObjectRef = voxelobject
		
		self.voxelobject.copy(voxelobject, false)
		self.voxelobject.update(true)
		
		editor_color.color = camera.environment.background_color
		camera.translation = self.voxelobject.Dimensions
		camera.look_at_from_position(Vector3(0, self.voxelobject.Dimensions.y, self.voxelobject.Dimensions.z) * Voxel.GridStep, Vector3(0, 0, 0), Vector3(0, 1, 0))


func _input(event : InputEvent) -> void:
	if VoxelEditorOwner.handle_input(event, camera, voxelobject):
		get_tree().set_input_as_handled()
	elif event is InputEventMouseButton:
		if event.get_button_index() == 4 and camera.translation.length() > 3:
			camera.translate(Vector3(0, 0, -mouse_zoom_sensitivity * (sensitivity_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1)))
		if event.get_button_index() == 5 and camera.translation.length() < voxelobject.Dimensions.length():
			camera.translate(Vector3(0, 0, mouse_zoom_sensitivity * (sensitivity_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1)))
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_RIGHT):
		var camRot = get_node('root/VBoxContainer/ViewportContainer/Viewport/Origin').get_rotation_degrees()
		
		camRot.y -= event.get_relative().x / mouse_movement_sensitivity * (sensitivity_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1) 
		camRot.x -= event.get_relative().y / mouse_movement_sensitivity * (sensitivity_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1)
		
		get_node('root/VBoxContainer/ViewportContainer/Viewport/Origin').set_rotation_degrees(camRot)

func _unhandled_key_input(event) -> void:
	if !event.pressed and !Input.is_mouse_button_pressed(BUTTON_RIGHT):
		match event.scancode:
			KEY_A:
				if Tools.has(VoxelEditor.Tools.ADD):
					VoxelEditorOwner.set_tool(VoxelEditor.Tools.ADD)
					get_tree().set_input_as_handled()
			KEY_S:
				if Tools.has(VoxelEditor.Tools.REMOVE):
					VoxelEditorOwner.set_tool(VoxelEditor.Tools.REMOVE)
					get_tree().set_input_as_handled()
			KEY_D:
				if Tools.has(VoxelEditor.Tools.PAINT):
					VoxelEditorOwner.set_tool(VoxelEditor.Tools.PAINT)
					get_tree().set_input_as_handled()
			KEY_C:
				if Tools.has(VoxelEditor.Tools.PAINT):
					paint_color_visible()
					get_tree().set_input_as_handled()
			KEY_G:
				if Tools.has(VoxelEditor.Tools.COLOR_PICKER):
					VoxelEditorOwner.set_tool(VoxelEditor.Tools.COLOR_PICKER)
					get_tree().set_input_as_handled()
			KEY_Q:
				if Mirrors.x > 0:
					VoxelEditorOwner.set_mirror_x(!mirror_x.pressed)
					get_tree().set_input_as_handled()
			KEY_W:
				if Mirrors.y > 0:
					VoxelEditorOwner.set_mirror_y(!mirror_y.pressed)
					get_tree().set_input_as_handled()
			KEY_E:
				if Mirrors.z > 0:
					VoxelEditorOwner.set_mirror_z(!mirror_z.pressed)
					get_tree().set_input_as_handled()


func _on_ViewportContainer_mouse_entered() -> void:
	set_process_input(true)
	set_process_unhandled_key_input(true)

func _on_ViewportContainer_mouse_exited() -> void:
	set_process_input(false)
	set_process_unhandled_key_input(false)


func _on_ToolSelector_item_selected(tool_id):
	VoxelEditorOwner.set_tool(tool_id)


func paint_color_visible(visible=null) -> void:
	visible = !paint_color.get_popup().visible if visible == null else visible
	
	if visible: paint_color.get_popup().popup_centered()
	else: paint_color.get_popup().visible = false

func _on_paint_color_changed(color) -> void:
	VoxelEditorOwner.set_paint_color(color)


func _on_set_active_voxel(active_voxel) -> void:
	VoxelEditorOwner.set_working_voxel(null if active_voxel == null else active_voxel.represents)


func _on_mirror_x_toggled(button_pressed):
	VoxelEditorOwner.set_mirror_x(button_pressed)


func _on_mirror_y_toggled(button_pressed):
	VoxelEditorOwner.set_mirror_y(button_pressed)


func _on_mirror_z_toggled(button_pressed):
	VoxelEditorOwner.set_mirror_z(button_pressed)


func _on_voxels_view_pressed():
	voxel_set_viewer.visible = !voxel_set_viewer.visible


func _on_settings_pressed():
	settings_dialog.popup_centered()

signal set_custom_editor(enabled)
func _on_custom_editor_toggled(button_pressed):
	emit_signal('set_custom_editor', button_pressed)

func _on_editor_color_changed(color):
	camera.environment.background_color = color

func _on_cursor_visible_toggled(button_pressed):
	VoxelEditorOwner.set_cursor_visible(button_pressed)

func _on_cursor_color_changed(color):
	VoxelEditorOwner.set_cursor_color(color)

func _on_floor_solid_toggled(button_pressed):
	VoxelEditorOwner.set_floor_solid(button_pressed)

func _on_floor_constant_toggled(button_pressed):
	VoxelEditorOwner.set_floor_constant(button_pressed)

func _on_floor_color_changed(color):
	VoxelEditorOwner.set_floor_color(color)


func commit_disabled(disabled : bool = !commit.pressed):
	commit.disabled = disabled
	commit.visible = !disabled

func _on_Commit_pressed() -> void:
	commit_confirm.popup_centered()

func _on_confirm_commit_confirmed():
	set_active(false, null, {'prompt': 'commit', 'voxels': voxelobject.Voxels})


func clear_disabled(disabled : bool = !clear.pressed):
	clear.disabled = disabled
	clear.visible = !disabled

func _on_clear_pressed() -> void:
	clear_confirm.popup_centered()

func _on_confirm_clear_confirmed():
	set_active(false, null, {'prompt': 'clear'})
