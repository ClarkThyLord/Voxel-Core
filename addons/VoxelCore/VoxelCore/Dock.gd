tool
extends VBoxContainer



# Refrences
onready var tool_selector := $options/tools/ToolSelector

onready var paint_color : ColorPickerButton = $options/tools/color

onready var mirror_x : CheckBox = $options/mirrors/x
onready var mirror_y : CheckBox = $options/mirrors/y
onready var mirror_z : CheckBox = $options/mirrors/z

onready var voxel_set_viewer := $options/VoxelSetViewer

onready var edit_mode : CheckBox = $settings/editor/HBoxContainer2/edit
onready var autosave : CheckBox = $settings/editor/HBoxContainer2/autosave

onready var cursor_color : ColorPickerButton = $settings/cursor/color
onready var cursor_visible : CheckBox = $settings/cursor/visible

onready var floor_visible : CheckBox = $settings/floor/HBoxContainer/visible
onready var floor_color : ColorPickerButton = $settings/floor/HBoxContainer/color
onready var floor_constant : CheckBox = $settings/floor/HBoxContainer2/constant
onready var floor_solid : CheckBox = $settings/floor/HBoxContainer2/solid



# Core
func _ready() -> void:
	tool_selector.connect('item_selected', get_node('/root/CoreVoxelEditor'), 'set_tool')
	get_node('/root/CoreVoxelEditor').connect('set_tool', tool_selector, '_select_int')
	
	paint_color.color = get_node('/root/CoreVoxelEditor').PaintColor
	get_node('/root/CoreVoxelEditor').connect('set_paint_color', self, 'set_paint_color')
	
	voxel_set_viewer.voxelset = get_node('/root/CoreVoxelEditor').VoxelObjectRef.voxelset
	get_node('/root/CoreVoxelEditor').VoxelObjectRef.connect('set_voxelset', voxel_set_viewer, 'set_voxelset')
	
	mirror_x.pressed = get_node('/root/CoreVoxelEditor').Mirror_X
	mirror_x.disabled = get_node('/root/CoreVoxelEditor').Mirror_X_Lock
	get_node('/root/CoreVoxelEditor').connect('set_mirror_x', mirror_x, 'set_pressed')
	get_node('/root/CoreVoxelEditor').connect('set_mirror_x_lock', mirror_x, 'set_disabled')
	
	mirror_y.pressed = get_node('/root/CoreVoxelEditor').Mirror_Y
	mirror_y.disabled = get_node('/root/CoreVoxelEditor').Mirror_Y_Lock
	get_node('/root/CoreVoxelEditor').connect('set_mirror_y', mirror_y, 'set_pressed')
	get_node('/root/CoreVoxelEditor').connect('set_mirror_y_lock', mirror_y, 'set_disabled')
	
	mirror_z.pressed = get_node('/root/CoreVoxelEditor').Mirror_Z
	mirror_z.disabled = get_node('/root/CoreVoxelEditor').Mirror_Z_Lock
	get_node('/root/CoreVoxelEditor').connect('set_mirror_z', mirror_z, 'set_pressed')
	get_node('/root/CoreVoxelEditor').connect('set_mirror_z_lock', mirror_z, 'set_disabled')
	
	
	edit_mode.pressed = get_node('/root/CoreVoxelEditor').Edit
	edit_mode.disabled = get_node('/root/CoreVoxelEditor').EditLock
	get_node('/root/CoreVoxelEditor').connect('set_edit', edit_mode, 'set_pressed')
	get_node('/root/CoreVoxelEditor').connect('set_edit_lock', edit_mode, 'set_disabled')
	
	
	cursor_visible.pressed = get_node('/root/CoreVoxelEditor').CursorVisible
	cursor_color.color = get_node('/root/CoreVoxelEditor').CursorColor
	get_node('/root/CoreVoxelEditor').connect('set_cursor_visible', cursor_visible, 'set_pressed')
	get_node('/root/CoreVoxelEditor').connect('set_cursor_color', cursor_color, 'set_pick_color')
	
	floor_visible.pressed = get_node('/root/CoreVoxelEditor').FloorVisible
	floor_visible.disabled = get_node('/root/CoreVoxelEditor').FloorConstant
	floor_color.color = get_node('/root/CoreVoxelEditor').FloorColor
	floor_constant.pressed = get_node('/root/CoreVoxelEditor').FloorConstant
	get_node('/root/CoreVoxelEditor').connect('set_floor_visible', floor_visible, 'set_pressed')
	get_node('/root/CoreVoxelEditor').connect('set_floor_color', floor_color, 'set_pick_color')
	get_node('/root/CoreVoxelEditor').connect('set_floor_constant', floor_visible, 'set_disabled')
	get_node('/root/CoreVoxelEditor').connect('set_floor_constant', floor_constant, 'set_pressed')


func paint_color_visible(visible=null) -> void:
	visible = !paint_color.get_popup().visible if visible == null else visible
	
	if visible: paint_color.get_popup().popup_centered()
	else: paint_color.get_popup().visible = false

func set_paint_color(color : Color) -> void:
	paint_color.color = color

func _on_color_color_changed(color) -> void:
	get_node('/root/CoreVoxelEditor').set_paint_color(color)


func _on_set_active_voxel(active_voxel):
	get_node('/root/CoreVoxelEditor').set_working_voxel(null if active_voxel == null else active_voxel.represents)


func _on_x_toggled(button_pressed) -> void:
	get_node('/root/CoreVoxelEditor').set_mirror_x(button_pressed)

func _on_y_toggled(button_pressed) -> void:
	get_node('/root/CoreVoxelEditor').set_mirror_y(button_pressed)

func _on_z_toggled(button_pressed) -> void:
	get_node('/root/CoreVoxelEditor').set_mirror_z(button_pressed)


func _on_custom_editor_toggled(button_pressed) -> void:
	emit_signal('set_custom_editor', button_pressed)

func _on_edit_toggled(button_pressed) -> void:
	get_node('/root/CoreVoxelEditor').set_edit(button_pressed)

signal set_autosave(enabled)
func set_autosave(enabled) -> void:
	autosave.pressed = enabled

func _on_autosave_toggled(button_pressed) -> void:
	emit_signal('set_autosave', button_pressed)


func cursor_color_visible(visible=null) -> void:
	visible = !cursor_color.get_popup().visible if visible == null else visible
	
	if visible: cursor_color.get_popup().popup_centered()
	else: cursor_color.get_popup().visible = false

func _on_cursor_visible_toggled(button_pressed) -> void:
	get_node('/root/CoreVoxelEditor').set_cursor_visible(button_pressed)

func _on_cursor_color_changed(color) -> void:
	get_node('/root/CoreVoxelEditor').set_cursor_color(color)


func floor_color_visible(visible=null) -> void:
	visible = !floor_color.get_popup().visible if visible == null else visible
	
	if visible: floor_color.get_popup().popup_centered()
	else: floor_color.get_popup().visible = false

func _on_floor_visible_toggled(button_pressed) -> void:
	get_node('/root/CoreVoxelEditor').set_floor_visible(button_pressed)

func _on_floor_color_changed(color) -> void:
	get_node('/root/CoreVoxelEditor').set_floor_color(color)

func _on_solid_toggled(button_pressed):
	get_node('/root/CoreVoxelEditor').set_floor_solid(button_pressed)

func _on_floor_constant_toggled(button_pressed) -> void:
	get_node('/root/CoreVoxelEditor').set_floor_constant(button_pressed)
