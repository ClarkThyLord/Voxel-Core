tool
extends Panel



# References
const VoxelEditEngineClass := preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')

onready var SettingsTabs := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/')

onready var FloorVisible := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Floor/HBoxContainer/CheckBox')
onready var FloorColor := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Floor/HBoxContainer/ColorRect')

onready var CursorVisible := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/HBoxContainer/CheckBox')
onready var CursorColor := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/HBoxContainer/ColorRect')



# Declarations
signal set_voxel_edit(voxeledit)
var VoxelEdit : VoxelEditEngineClass setget set_voxel_edit
func set_voxel_edit(voxeledit : VoxelEditEngineClass, emit := true) -> void:
	if not voxeledit == VoxelEdit:
		if VoxelEdit:
			VoxelEdit.disconnect('set_floor_visible', FloorVisible, 'set_toggle_mode')
			FloorVisible.disconnect('toggled', VoxelEdit, 'set_floor_visible')
			VoxelEdit.disconnect('set_floor_color', FloorColor, 'set_pick_color')
			FloorColor.disconnect('color_changed', VoxelEdit, 'set_floor_color')
			
			VoxelEdit.disconnect('set_cursor_visible', CursorVisible, 'set_cursor_mode')
			CursorVisible.disconnect('toggled', VoxelEdit, 'set_cursor_visible')
			VoxelEdit.disconnect('set_cursor_color', CursorColor, 'set_cursor_color')
			CursorColor.disconnect('color_changed', VoxelEdit, 'set_cursor_color')
		
		VoxelEdit = voxeledit
		
		VoxelEdit.connect('set_floor_visible', FloorVisible, 'set_toggle_mode')
		FloorVisible.connect('toggled', VoxelEdit, 'set_floor_visible')
		VoxelEdit.connect('set_floor_color', FloorColor, 'set_pick_color')
		FloorColor.connect('color_changed', VoxelEdit, 'set_floor_color')
		
		VoxelEdit.connect('set_cursor_visible', CursorVisible, 'set_toggle_mode')
		CursorVisible.connect('toggled', VoxelEdit, 'set_cursor_visible')
		VoxelEdit.connect('set_cursor_color', CursorColor, 'set_pick_color')
		CursorColor.connect('color_changed', VoxelEdit, 'set_cursor_color')
		
		if emit: emit_signal('set_voxel_edit', VoxelEdit)


# Core
func _ready():
	SettingsTabs.set_tab_disabled(0, true)
	SettingsTabs.current_tab = 1


func set_floor_visible(visible : bool) -> void:
	FloorVisible.pressed = visible

