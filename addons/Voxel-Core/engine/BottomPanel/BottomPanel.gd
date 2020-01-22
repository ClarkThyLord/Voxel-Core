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

onready var InfoTabs := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/TabContainer')

onready var VoxelLayersView := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/TabContainer/VoxelObject/VBoxContainer/VoxelLayersView')

onready var VoxelSetPath := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/TabContainer/VoxelObject/VBoxContainer/VoxelSet/VBoxContainer/HBoxContainer/VoxelSetPath')
onready var VoxelSetUV := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/TabContainer/VoxelObject/VBoxContainer/VoxelSet/VBoxContainer/HBoxContainer/VoxelSetUV')

onready var ExportVoxels := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/TabContainer/VoxelObject/VBoxContainer/Voxels/VBoxContainer/HBoxContainer/Export')
onready var ExportFile := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/TabContainer/VoxelObject/VBoxContainer/Voxels/VBoxContainer/HBoxContainer/Export/FileDialog')
onready var ImportVoxels := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/TabContainer/VoxelObject/VBoxContainer/Voxels/VBoxContainer/HBoxContainer/Import')
onready var ImportFile := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/TabContainer/VoxelObject/VBoxContainer/Voxels/VBoxContainer/HBoxContainer/Import/FileDialog')

onready var AlignSetting := get_node('PanelContainer/MarginContainer/HBoxContainer/Info/TabContainer/Effects/ScrollContainer/VBoxContainer/Align/VBoxContainer/HBoxContainer/AlignSetting')


onready var SettingsTabs := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer')

onready var AutoSave := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/General/VBoxContainer/AutoSave')

onready var CursorVisible := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/VBoxContainer/CursorVisible')
onready var CursorDynamic := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/VBoxContainer/CursorDynamic')
onready var CursorColor := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Cursor/VBoxContainer/HBoxContainer/CursorColor')

onready var FloorVisible := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/FloorVisible')
onready var FloorConstant := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/FloorConstant')
onready var FloorColor := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/HBoxContainer/FloorColor')
onready var FloorDimensionsX := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/Size/X')
onready var FloorDimensionsY := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/Size/Y')
onready var FloorDimensionsZ := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/Size/Z')
onready var FloorType := get_node('PanelContainer/MarginContainer/HBoxContainer/Settings/TabContainer/Floor/VBoxContainer/FloorTypesDropdown')



# Declarations
var VoxelCore



# Core
func _ready():
	InfoTabs.set_tab_icon(0, preload('res://addons/Voxel-Core/assets/VoxelEditor.png'))
	InfoTabs.set_tab_icon(1, preload('res://addons/Voxel-Core/assets/BottomPanel/effects.png'))
	
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
	
	VoxelLayersView.visible = VoxelCore.VoxelEditor.VoxelObject is VoxelLayeredMesh
	
	VoxelSetPath.set_text(str(voxelcore.VoxelEditor.VoxelObject.VoxelSetPath))
	VoxelSetUV.set_pressed(voxelcore.VoxelEditor.VoxelObject.VoxelSet and voxelcore.VoxelEditor.VoxelObject.VoxelSet.AlbedoTexture is Texture)
	
	
	AutoSave.set_pressed(voxelcore.AutoSave)
	voxelcore.connect('set_auto_save', AutoSave, 'set_pressed')
	AutoSave.connect('pressed', voxelcore, 'set_auto_save')
	
	CursorVisible.set_pressed(voxelcore.VoxelEditor.CursorVisible)
	voxelcore.VoxelEditor.connect('set_cursor_visible', CursorVisible, 'set_pressed')
	CursorVisible.connect('pressed', voxelcore.VoxelEditor, 'set_cursor_visible')
	
	CursorDynamic.set_pressed(voxelcore.VoxelEditor.CursorDynamic)
	voxelcore.VoxelEditor.connect('set_cursor_dynamic', CursorColor, 'set_disabled')
	voxelcore.VoxelEditor.connect('set_cursor_dynamic', CursorDynamic, 'set_pressed')
	CursorDynamic.connect('pressed', voxelcore.VoxelEditor, 'set_cursor_dynamic')
	
	CursorColor.set_disabled(voxelcore.VoxelEditor.CursorDynamic)
	CursorColor.set_pick_color(voxelcore.VoxelEditor.CursorColor)
	voxelcore.VoxelEditor.connect('set_cursor_color', CursorColor, 'set_pick_color')
	CursorColor.connect('color_changed', voxelcore.VoxelEditor, 'set_cursor_color')
	
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
	
	set_floor_dimensions(voxelcore.VoxelEditor.FloorDimensions)
	voxelcore.VoxelEditor.connect('set_floor_dimensions', self, 'set_floor_dimensions')
	connect('set_floor_dimensions', voxelcore.VoxelEditor, 'set_floor_dimensions')
	
	FloorType.select(voxelcore.VoxelEditor.FloorType)
	voxelcore.VoxelEditor.connect('set_floor_type', FloorType, 'select')
	FloorType.connect('item_selected', voxelcore.VoxelEditor, 'set_floor_type')


func set_primary_color_popup_visible(visible := !PrimaryColor.get_popup().visible) -> void:
	if visible: PrimaryColor.get_popup().popup_centered()
	else: PrimaryColor.get_popup().hide()

func set_secondary_color_popup_visible(visible := !SecondaryColor.get_popup().visible) -> void:
	if visible: SecondaryColor.get_popup().popup_centered()
	else: SecondaryColor.get_popup().hide()


func set_floor_dimensions(dimensions : Vector3) -> void:
	FloorDimensionsX.value = dimensions.x
	FloorDimensionsY.value = dimensions.y
	FloorDimensionsZ.value = dimensions.z

signal set_floor_dimensions(floordimensions)
func updated_floor_dimensions(value : float) -> void:
	emit_signal('set_floor_dimensions', Vector3(FloorDimensionsX.value, FloorDimensionsY.value, FloorDimensionsZ.value))


func _on_VoxelObject_modified(modified : bool) -> void:
	Commit.disabled = !modified
	Cancel.disabled = !modified

func _on_Commit_pressed():
	var modified = VoxelCore.VoxelEditor.Modified
	VoxelCore._commit(true, true)
	if modified: VoxelCore._save()

func _on_Cancel_pressed():
	var modified = VoxelCore.VoxelEditor.Modified
	VoxelCore._cancel(true, true)
	if modified: VoxelCore._save()



func _on_VoxelsExport_pressed():
	ExportFile.popup_centered()

func _on_VoxelsExport_file_selected(path : String):
	var file = File.new()
	if file.open(path, File.WRITE) != OK:
		printerr("Error exporting voxels...")
		return
	
	file.store_line(to_json(VoxelCore.VoxelEditor.VoxelObject.get_voxels()))
	file.close()

func _on_VoxelsImport_pressed():
	ImportFile.popup_centered()

func _on_VoxelsImport_file_selected(path : String):
	var voxels := {}
	
	match path.get_extension().to_lower():
		'vox':
			var file := File.new()
			var error = file.open(path, File.READ)
			if error != OK:
				printerr("Could not open `", path, "`")
				if file.is_open(): file.close()
				return error
			
			voxels = Voxel.vox_to_voxels(file)
			file.close()
		'png', 'jpg':
			var image := Image.new()
			var err = image.load(path)
			if err != OK:
				printerr("Could not load `", path, "`")
				return err
			
			voxels = Voxel.image_to_voxels(image)
		_:
			printerr('Trying to import invalid file...')
	
	if voxels.size() == 0: printerr('No voxel data found...')
	else:
		var undo_redo : UndoRedo = VoxelCore.get_undo_redo()
		undo_redo.create_action('VoxelEditor IMPORT')
		
		undo_redo.add_do_method(VoxelCore.VoxelEditor.VoxelObject, 'set_voxels', voxels)
		undo_redo.add_undo_method(VoxelCore.VoxelEditor.VoxelObject, 'set_voxels', VoxelCore.VoxelEditor.VoxelObject.get_voxels())
		
		undo_redo.add_do_method(VoxelCore.VoxelEditor.VoxelObject, 'update')
		undo_redo.add_undo_method(VoxelCore.VoxelEditor.VoxelObject, 'update')
		undo_redo.commit_action()


func _on_Align_pressed():
	var voxels : Dictionary = VoxelCore.VoxelEditor.VoxelObject.get_voxels()
	if voxels.size() > 0:
		var aligned_voxels = Voxel.center(voxels, AlignSetting.selected == 1)
		
		VoxelCore.VoxelEditor.VoxelObject.set_voxels(voxels)
		var undo_redo : UndoRedo = VoxelCore.get_undo_redo()
		undo_redo.create_action('VoxelEditor ALIGN')
		
		undo_redo.add_do_method(VoxelCore.VoxelEditor.VoxelObject, 'set_voxels', aligned_voxels)
		undo_redo.add_undo_method(VoxelCore.VoxelEditor.VoxelObject, 'set_voxels', voxels)
		
		undo_redo.add_do_method(VoxelCore.VoxelEditor.VoxelObject, 'update')
		undo_redo.add_undo_method(VoxelCore.VoxelEditor.VoxelObject, 'update')
		undo_redo.commit_action()


func _on_Godot_pressed():
	OS.shell_open('https://godotengine.org/asset-library/asset')

func _on_GitHub_pressed():
	OS.shell_open('https://github.com/ClarkThyLord/Voxel-Core')

func _on_Help_pressed():
	OS.shell_open('https://github.com/ClarkThyLord/Voxel-Core/wiki')

func _on_Issue_pressed():
	OS.shell_open('https://github.com/ClarkThyLord/Voxel-Core/issues')


func _on_Reset_pressed():
	VoxelCore.VoxelEditor.set_options()


func _unhandled_key_input(event : InputEventKey):
	if event.pressed and not event.echo and not Input.is_key_pressed(KEY_CONTROL):
		if event.scancode == KEY_QUOTELEFT:
			if Input.is_key_pressed(KEY_SHIFT):
				ToolMode.set_mode((ToolMode.Mode + 1) % VoxelEditorEngineClass.ToolModes.size())
				get_tree().set_input_as_handled()
			else:
				ToolPalette.set_palette((ToolPalette.Palette + 1) % VoxelEditorEngineClass.ToolPalettes.size())
				get_tree().set_input_as_handled()
		elif event.scancode == KEY_C:
			match ToolPalette.Palette:
				VoxelEditorEngineClass.ToolPalettes.PRIMARY:
					set_primary_color_popup_visible()
				VoxelEditorEngineClass.ToolPalettes.SECONDARY:
					set_secondary_color_popup_visible()
		elif event.scancode >= KEY_1 and event.scancode <= KEY_0 + VoxelEditorEngineClass.Tools.size():
			Tool.set_tool(event.scancode - 49)
			get_tree().set_input_as_handled()
