tool
extends ScrollContainer



# References
const VoxelEditorEngineClass := preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')

onready var RawData := get_node('PanelContainer/MarginContainer/HBoxContainer/Tools/HBoxContainer/HBoxContainer/Raw')

onready var Tool := get_node('PanelContainer/MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer3/Tools')
onready var ToolPalette := get_node('PanelContainer/MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer3/ToolPalettesDropdown')
onready var ToolMode := get_node('PanelContainer/MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer3/ToolMode')


onready var PrimaryColor := get_node('PanelContainer/MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer2/PrimaryColor')
onready var SecondaryColor := get_node('PanelContainer/MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer2/SecondaryColor')

onready var VoxelSetView := get_node('PanelContainer/MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer4/VoxelSetView')

onready var MirrorX := get_node('PanelContainer/MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer/MirrorX')
onready var MirrorY := get_node('PanelContainer/MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer/MirrorY')
onready var MirrorZ := get_node('PanelContainer/MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer/MirrorZ')


onready var Lock := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/HBoxContainer/HBoxContainer/Lock')
onready var Commit := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/HBoxContainer/HBoxContainer/Commit')
onready var Cancel := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/HBoxContainer/HBoxContainer/Cancel')


onready var SettingsTabs := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer')

onready var AutoSave := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/General/VBoxContainer/AutoSave')

onready var CursorVisible := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/VBoxContainer/CursorVisible')
onready var CursorColor := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/VBoxContainer/HBoxContainer/CursorColor')
onready var CursorType := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/VBoxContainer/CursorTypesDropdown')

onready var FloorVisible := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/FloorVisible')
onready var FloorConstant := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/FloorConstant')
onready var FloorColor := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/HBoxContainer/FloorColor')
onready var FloorType := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/FloorTypesDropdown')



# Declarations
var VoxelCore



# Core
func _ready():
	SettingsTabs.set_tab_icon(0, preload('res://addons/Voxel-Core/assets/BottomPanel/general.png'))
	SettingsTabs.set_tab_icon(1, preload('res://addons/Voxel-Core/assets/BottomPanel/individual.png'))
	SettingsTabs.set_tab_icon(2, preload('res://addons/Voxel-Core/assets/BottomPanel/floor.png'))
	SettingsTabs.set_tab_icon(3, preload('res://addons/Voxel-Core/assets/BottomPanel/about.png'))


func setup(voxelcore) -> void:
	VoxelCore = voxelcore
	
	RawData.set_pressed(voxelcore.VoxelEditor.RawData)
	voxelcore.VoxelEditor.connect('set_rawdata', RawData, 'set_pressed')
	RawData.connect('toggled', voxelcore.VoxelEditor, 'set_rawdata')
	
	Tool.select(voxelcore.VoxelEditor.Tool)
	voxelcore.VoxelEditor.connect('set_tool', Tool, 'select')
	Tool.connect('item_selected', voxelcore.VoxelEditor, 'set_tool')
	
	ToolPalette.select(voxelcore.VoxelEditor.ToolPalette)
	voxelcore.VoxelEditor.connect('set_tool_palette', ToolPalette, 'select')
	ToolPalette.connect('item_selected', voxelcore.VoxelEditor, 'set_tool_palette')
	
	ToolMode.select(voxelcore.VoxelEditor.ToolMode)
	voxelcore.VoxelEditor.connect('set_tool_mode', ToolMode, 'select')
	ToolMode.connect('item_selected', voxelcore.VoxelEditor, 'set_tool_mode')
	
	PrimaryColor.set_pick_color(voxelcore.VoxelEditor.PrimaryColor)
	voxelcore.VoxelEditor.connect('set_primary_color', PrimaryColor, 'set_pick_color')
	PrimaryColor.connect('color_changed', voxelcore.VoxelEditor, 'set_primary_color')
	
	SecondaryColor.set_pick_color(voxelcore.VoxelEditor.SecondaryColor)
	voxelcore.VoxelEditor.connect('set_secondary_color', SecondaryColor, 'set_pick_color')
	SecondaryColor.connect('color_changed', voxelcore.VoxelEditor, 'set_secondary_color')
	
	
	VoxelSetView.set_primary(voxelcore.VoxelEditor.Primary)
	VoxelSetView.connect('set_primary', voxelcore.VoxelEditor, 'set_primary', [false])
	voxelcore.VoxelEditor.connect('set_primary', VoxelSetView, 'set_primary', [false])
	VoxelSetView.set_primary_color(voxelcore.VoxelEditor.PrimaryColor)
	voxelcore.VoxelEditor.connect('set_primary_color', VoxelSetView, 'set_primary_color')
	
	VoxelSetView.set_secondary(voxelcore.VoxelEditor.Secondary)
	VoxelSetView.connect('set_secondary', voxelcore.VoxelEditor, 'set_secondary', [false])
	voxelcore.VoxelEditor.connect('set_secondary', VoxelSetView, 'set_secondary', [false])
	VoxelSetView.set_secondary_color(voxelcore.VoxelEditor.SecondaryColor)
	voxelcore.VoxelEditor.connect('set_secondary_color', VoxelSetView, 'set_secondary_color')
	
	VoxelSetView.set_voxel_set(voxelcore.VoxelEditor.VoxelObject.VoxelSet)
	voxelcore.VoxelEditor.VoxelObject.connect('set_voxel_set', VoxelSetView, 'set_voxel_set')
	VoxelSetView.connect('set_voxel_set', voxelcore.VoxelEditor.VoxelObject, 'set_voxel_set')
	
	
	MirrorX.set_pressed(voxelcore.VoxelEditor.MirrorX)
	voxelcore.VoxelEditor.connect('set_mirror_x', MirrorX, 'set_pressed')
	MirrorX.connect('pressed', voxelcore.VoxelEditor, 'set_mirror_x')
	
	MirrorY.set_pressed(voxelcore.VoxelEditor.MirrorY)
	voxelcore.VoxelEditor.connect('set_mirror_y', MirrorY, 'set_pressed')
	MirrorY.connect('pressed', voxelcore.VoxelEditor, 'set_mirror_y')
	
	MirrorZ.set_pressed(voxelcore.VoxelEditor.MirrorZ)
	voxelcore.VoxelEditor.connect('set_mirror_z', MirrorZ, 'set_pressed')
	MirrorZ.connect('pressed', voxelcore.VoxelEditor, 'set_mirror_z')
	
	
	_on_VoxelObject_modified(voxelcore.VoxelEditor.Modified)
	voxelcore.VoxelEditor.connect('modified', self, '_on_VoxelObject_modified')
	
	Lock.connect('toggled', voxelcore, 'select')
	Lock.connect('toggled', voxelcore, 'handle_lock')
	Lock.set_pressed(voxelcore.VoxelEditor.Lock)
	voxelcore.VoxelEditor.connect('set_lock', Lock, 'set_pressed')
	Lock.connect('toggled', voxelcore.VoxelEditor, 'set_lock')
	
	
	AutoSave.set_pressed(voxelcore.AutoSave)
	voxelcore.connect('set_auto_save', AutoSave, 'set_pressed')
	AutoSave.connect('pressed', voxelcore, 'set_auto_save')
	
	CursorVisible.set_pressed(voxelcore.VoxelEditor.CursorVisible)
	voxelcore.VoxelEditor.connect('set_cursor_visible', CursorVisible, 'set_pressed')
	CursorVisible.connect('pressed', voxelcore.VoxelEditor, 'set_cursor_visible')
	
	CursorColor.set_pick_color(voxelcore.VoxelEditor.CursorColor)
	voxelcore.VoxelEditor.connect('set_cursor_color', CursorColor, 'set_pick_color')
	CursorColor.connect('color_changed', voxelcore.VoxelEditor, 'set_cursor_color')
	
	CursorType.select(voxelcore.VoxelEditor.CursorType)
	voxelcore.VoxelEditor.connect('set_cursor_type', CursorType, 'select')
	CursorType.connect('item_selected', voxelcore.VoxelEditor, 'set_cursor_type')
	
	FloorVisible.set_pressed(voxelcore.VoxelEditor.FloorVisible)
	voxelcore.VoxelEditor.connect('set_floor_visible', FloorVisible, 'set_pressed')
	FloorVisible.set_disabled(voxelcore.VoxelEditor.FloorConstant)
	voxelcore.VoxelEditor.connect('set_floor_constant', FloorVisible, 'set_disabled')
	FloorVisible.connect('pressed', voxelcore.VoxelEditor, 'set_floor_visible')
	
	FloorConstant.set_pressed(voxelcore.VoxelEditor.FloorConstant)
	voxelcore.VoxelEditor.connect('set_floor_constant', FloorConstant, 'set_pressed')
	FloorConstant.connect('pressed', voxelcore.VoxelEditor, 'set_floor_constant')
	
	FloorColor.set_pick_color(voxelcore.VoxelEditor.FloorColor)
	voxelcore.VoxelEditor.connect('set_floor_color', FloorColor, 'set_pick_color')
	FloorColor.connect('color_changed', voxelcore.VoxelEditor, 'set_floor_color')
	
	FloorType.select(voxelcore.VoxelEditor.FloorType)
	voxelcore.VoxelEditor.connect('set_floor_type', FloorType, 'select')
	FloorType.connect('item_selected', voxelcore.VoxelEditor, 'set_floor_type')


func primary_color_popup_visible(visible := !PrimaryColor.get_popup().visible) -> void:
	if visible: PrimaryColor.get_popup().popup_centered()
	else: PrimaryColor.get_popup().hide()

func secondary_color_popup_visible(visible := !SecondaryColor.get_popup().visible) -> void:
	if visible: SecondaryColor.get_popup().popup_centered()
	else: SecondaryColor.get_popup().hide()


func _on_VoxelObject_modified(modified : bool) -> void:
	Commit.disabled = !modified
	Cancel.disabled = !modified

func _on_Commit_pressed():
	VoxelCore._commit()

func _on_Cancel_pressed():
	VoxelCore._cancel()


func _on_Godot_pressed():
	OS.shell_open('https://godotengine.org/asset-library/asset')

func _on_GitHub_pressed():
	OS.shell_open('https://github.com/ClarkThyLord/Voxel-Core')


func _on_Reset_pressed():
	VoxelCore.VoxelEditor.set_options()


func _unhandled_key_input(event : InputEventKey):
	if event.pressed and not event.echo:
		if event.scancode == KEY_QUOTELEFT and not Input.is_key_pressed(KEY_CONTROL) and not Input.is_key_pressed(KEY_ALT):
			if Input.is_key_pressed(KEY_SHIFT):
				ToolMode.set_mode((ToolMode.Mode + 1) % VoxelEditorEngineClass.ToolModes.size())
				get_tree().set_input_as_handled()
			else:
				ToolPalette.set_palette((ToolPalette.Palette + 1) % VoxelEditorEngineClass.ToolPalettes.size())
				get_tree().set_input_as_handled()
		if event.scancode >= KEY_1 and event.scancode <= KEY_0 + VoxelEditorEngineClass.Tools.size():
			Tool.set_tool(event.scancode - 49)
			get_tree().set_input_as_handled()
