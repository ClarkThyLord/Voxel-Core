tool
extends Panel



# References
const VoxelEditorEngineClass := preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')


onready var Tool := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer3/Tools')
onready var ToolMode := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer3/ToolMode')

onready var PrimaryColor := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer2/PrimaryColor')
onready var SecondaryColor := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer2/SecondaryColor')

onready var VoxelSetView := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer4/VoxelSetView')

onready var MirrorX := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer/MirrorX')
onready var MirrorY := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer/MirrorY')
onready var MirrorZ := get_node('MarginContainer/HBoxContainer/Tools/ScrollContainer/VBoxContainer/HBoxContainer/MirrorZ')


onready var Lock := get_node('MarginContainer/HBoxContainer/Info/HBoxContainer/HBoxContainer/Lock')
onready var Commit := get_node('MarginContainer/HBoxContainer/Info/HBoxContainer/HBoxContainer/Commit')
onready var Cancel := get_node('MarginContainer/HBoxContainer/Info/HBoxContainer/HBoxContainer/Cancel')


onready var SettingsTabs := get_node('MarginContainer/HBoxContainer/Settings/TabContainer')

onready var AutoSave := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/General/VBoxContainer/AutoSave')

onready var CursorVisible := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/VBoxContainer/CursorVisible')
onready var CursorColor := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/VBoxContainer/HBoxContainer/CursorColor')

onready var FloorVisible := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/FloorVisible')
onready var FloorColor := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/HBoxContainer/FloorColor')
onready var FloorType := get_node('MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/FloorTypesDropdown')



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
	
	Tool.select(voxelcore.VoxelEditor.Tool)
	voxelcore.VoxelEditor.connect('set_tool', Tool, 'select')
	Tool.connect('item_selected', voxelcore.VoxelEditor, 'set_tool')
	
	ToolMode.select(voxelcore.VoxelEditor.ToolMode)
	voxelcore.VoxelEditor.connect('set_tool_mode', ToolMode, 'select')
	ToolMode.connect('item_selected', voxelcore.VoxelEditor, 'set_tool_mode')
	
	PrimaryColor.set_pick_color(voxelcore.VoxelEditor.PrimaryColor)
	voxelcore.VoxelEditor.connect('set_primary_color', PrimaryColor, 'set_pick_color')
	PrimaryColor.connect('color_changed', voxelcore.VoxelEditor, 'set_primary_color')
	
	SecondaryColor.set_pick_color(voxelcore.VoxelEditor.SecondaryColor)
	voxelcore.VoxelEditor.connect('set_secondary_color', SecondaryColor, 'set_pick_color')
	SecondaryColor.connect('color_changed', voxelcore.VoxelEditor, 'set_secondary_color')
	
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
	
	
	_on_VoxelObject_modified(false)
	
	Lock.set_pressed(voxelcore.VoxelEditor.Lock)
	voxelcore.VoxelEditor.connect('set_lock', Lock, 'set_pressed')
	Lock.connect('pressed', voxelcore.VoxelEditor, 'set_lock')
	
	
	AutoSave.set_pressed(voxelcore.AutoSave)
	voxelcore.connect('set_auto_save', AutoSave, 'set_pressed')
	AutoSave.connect('pressed', voxelcore, 'set_auto_save')
	
	CursorVisible.set_pressed(voxelcore.VoxelEditor.CursorVisible)
	voxelcore.VoxelEditor.connect('set_cursor_visible', CursorVisible, 'set_pressed')
	CursorVisible.connect('pressed', voxelcore.VoxelEditor, 'set_cursor_visible')
	
	CursorColor.set_pick_color(voxelcore.VoxelEditor.CursorColor)
	voxelcore.VoxelEditor.connect('set_cursor_color', CursorColor, 'set_pick_color')
	CursorColor.connect('color_changed', voxelcore.VoxelEditor, 'set_cursor_color')
	
	FloorVisible.set_pressed(voxelcore.VoxelEditor.FloorVisible)
	voxelcore.VoxelEditor.connect('set_floor_visible', FloorVisible, 'set_pressed')
	FloorVisible.connect('pressed', voxelcore.VoxelEditor, 'set_floor_visible')
	
	FloorColor.set_pick_color(voxelcore.VoxelEditor.FloorColor)
	voxelcore.VoxelEditor.connect('set_floor_color', FloorColor, 'set_pick_color')
	FloorColor.connect('color_changed', voxelcore.VoxelEditor, 'set_floor_color')
	
	FloorType.select(voxelcore.VoxelEditor.FloorType)
	voxelcore.VoxelEditor.connect('set_floor_type', FloorType, 'select')
	FloorType.connect('item_selected', voxelcore.VoxelEditor, 'set_floor_type')


func _on_VoxelObject_modified(modified : bool) -> void:
	Commit.disabled = !modified
	Cancel.disabled = !modified


func _on_VoxelSetView_selected(index):
	match index:
		0:
			VoxelCore.VoxelEditor.set_primary(VoxelSetView.Selected[index].ID)
		1:
			VoxelCore.VoxelEditor.set_secondary(VoxelSetView.Selected[index].ID)

func _on_VoxelSetView_unselected(index):
	match index:
		0:
			VoxelCore.VoxelEditor.set_primary(null)
		1:
			VoxelCore.VoxelEditor.set_secondary(null)


func _on_Godot_pressed():
	OS.shell_open('https://godotengine.org/asset-library/asset')

func _on_GitHub_pressed():
	OS.shell_open('https://github.com/ClarkThyLord/Voxel-Core')
