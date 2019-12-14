tool
extends EditorPlugin



# Refrences
const VoxelEditorEngineClass = preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')



# Declarations
var VoxelEdit := VoxelEditorEngineClass.new()

var BottomPanel : ToolButton
var BottomPanelControl := preload('res://addons/Voxel-Core/engine/gui/BottomPanel.tscn').instance()



# Core
func _enter_tree():
	add_autoload_singleton('VoxelSet', 'res://addons/Voxel-Core/defaults/VoxelSet.default.gd')
	
	print('Loaded Voxel-Core.')

func _ready():
	BottomPanel = add_control_to_bottom_panel(BottomPanelControl, 'Voxel-Core')
	BottomPanelControl.set_voxel_edit(VoxelEdit)
	make_bottom_panel_item_visible(BottomPanelControl)

func _exit_tree():
	remove_autoload_singleton('VoxelSet')
	
	remove_control_from_bottom_panel(BottomPanelControl)
	
	print('Unloaded Voxel-Core.')
