tool
extends Panel



# References
const VoxelEditorEngineClass := preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')


onready var Lock := get_node('MarginContainer/HBoxContainer/Tools/HBoxContainer/HBoxContainer/Lock')

onready var Tool := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer3/Tools')
onready var ToolMode := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer3/ToolMode')

onready var PrimaryColor := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer2/PrimaryColor')
onready var SecondaryColor := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer2/SecondaryColor')

onready var MirrorX := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer/MirrorX')
onready var MirrorY := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer/MirrorY')
onready var MirrorZ := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer/MirrorZ')


onready var Properties := get_node('MarginContainer/HBoxContainer/Properties')


onready var SettingsTabs := get_node('MarginContainer/HBoxContainer/Settings/TabContainer')

signal set_auto_save(autosave)
onready var AutoSave := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/General/VBoxContainer/AutoSave')
func set_auto_save(autosave, emit := true) -> void:
	AutoSave.pressed = autosave
	if emit: emit_signal('set_auto_save', autosave)

onready var CursorVisible := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/VBoxContainer/CursorVisible')
onready var CursorColor := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/VBoxContainer/HBoxContainer/CursorColor')

onready var FloorVisible := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/FloorVisible')
onready var FloorColor := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/HBoxContainer/FloorColor')
onready var FloorType := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/FloorTypesDropdown')



# Declarations
signal set_voxel_editor(voxeledit)
var VoxelEditor : VoxelEditorEngineClass setget set_voxel_editor
func set_voxel_editor(voxeledit : VoxelEditorEngineClass, emit := true) -> void:
	if VoxelEditor:
		VoxelEditor.disconnect('set_floor_visible', FloorVisible, 'set_pressed')
		FloorVisible.disconnect('toggled', VoxelEditor, 'set_floor_visible')
		VoxelEditor.disconnect('set_floor_color', FloorColor, 'set_pick_color')
		FloorColor.disconnect('color_changed', VoxelEditor, 'set_floor_color')
		
		VoxelEditor.disconnect('set_cursor_visible', CursorVisible, 'set_pressed')
		CursorVisible.disconnect('toggled', VoxelEditor, 'set_cursor_visible')
		VoxelEditor.disconnect('set_cursor_color', CursorColor, 'set_pick_color')
		CursorColor.disconnect('color_changed', VoxelEditor, 'set_cursor_color')
	if voxeledit is VoxelEditorEngineClass and not voxeledit == VoxelEditor:
		VoxelEditor = voxeledit
		
		VoxelEditor.connect('set_floor_visible', FloorVisible, 'set_pressed')
		FloorVisible.connect('toggled', VoxelEditor, 'set_floor_visible')
		VoxelEditor.connect('set_floor_color', FloorColor, 'set_pick_color')
		FloorColor.connect('color_changed', VoxelEditor, 'set_floor_color')
		
		VoxelEditor.connect('set_cursor_visible', CursorVisible, 'set_pressed')
		CursorVisible.connect('toggled', VoxelEditor, 'set_cursor_visible')
		VoxelEditor.connect('set_cursor_color', CursorColor, 'set_pick_color')
		CursorColor.connect('color_changed', VoxelEditor, 'set_cursor_color')
		
		if emit: emit_signal('set_voxel_editor', VoxelEditor)


# Core
func _on_Godot_pressed():
	OS.shell_open('https://godotengine.org/asset-library/asset')

func _on_GitHub_pressed():
	OS.shell_open('https://github.com/ClarkThyLord/Voxel-Core')
