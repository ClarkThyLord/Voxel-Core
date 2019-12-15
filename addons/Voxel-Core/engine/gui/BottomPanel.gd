tool
extends Panel



# References
const VoxelEditorEngineClass := preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')

onready var SettingsTabs := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/')

signal set_auto_save(autosave)
onready var AutoSave := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/General/HBoxContainer/CheckBox')
func set_auto_save(autosave, emit := true) -> void:
	AutoSave.pressed = autosave
	if emit: emit_signal('set_auto_save', autosave)

onready var FloorVisible := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Floor/HBoxContainer/CheckBox')
onready var FloorColor := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Floor/HBoxContainer/ColorRect')

onready var CursorVisible := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/HBoxContainer/CheckBox')
onready var CursorColor := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/HBoxContainer/ColorRect')



# Declarations
signal set_voxel_edit(voxeledit)
var VoxelEditor : VoxelEditorEngineClass setget set_voxel_edit
func set_voxel_edit(voxeledit : VoxelEditorEngineClass, emit := true) -> void:
	if not voxeledit == VoxelEditor:
		if VoxelEditor:
			VoxelEditor.disconnect('set_floor_visible', FloorVisible, 'set_pressed')
			FloorVisible.disconnect('toggled', VoxelEditor, 'set_floor_visible')
			VoxelEditor.disconnect('set_floor_color', FloorColor, 'set_pick_color')
			FloorColor.disconnect('color_changed', VoxelEditor, 'set_floor_color')
			
			VoxelEditor.disconnect('set_cursor_visible', CursorVisible, 'set_pressed')
			CursorVisible.disconnect('toggled', VoxelEditor, 'set_cursor_visible')
			VoxelEditor.disconnect('set_cursor_color', CursorColor, 'set_pick_color')
			CursorColor.disconnect('color_changed', VoxelEditor, 'set_cursor_color')
		
		VoxelEditor = voxeledit
		
		VoxelEditor.connect('set_floor_visible', FloorVisible, 'set_pressed')
		FloorVisible.connect('toggled', VoxelEditor, 'set_floor_visible')
		VoxelEditor.connect('set_floor_color', FloorColor, 'set_pick_color')
		FloorColor.connect('color_changed', VoxelEditor, 'set_floor_color')
		
		VoxelEditor.connect('set_cursor_visible', CursorVisible, 'set_pressed')
		CursorVisible.connect('toggled', VoxelEditor, 'set_cursor_visible')
		VoxelEditor.connect('set_cursor_color', CursorColor, 'set_pick_color')
		CursorColor.connect('color_changed', VoxelEditor, 'set_cursor_color')
		
		if emit: emit_signal('set_voxel_edit', VoxelEditor)


# Core
func _ready():
	SettingsTabs.set_tab_disabled(0, true)
	SettingsTabs.current_tab = 1
	
	AutoSave.connect('toggled', self, 'set_auto_save')
