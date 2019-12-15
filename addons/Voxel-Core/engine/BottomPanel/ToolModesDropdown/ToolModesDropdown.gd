tool
extends OptionButton



# References
const VoxelEditorEngineClass := preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')



# Declarations
export(VoxelEditorEngineClass.ToolModes) var Tool := VoxelEditorEngineClass.ToolModes.INDIVIDUAL setget set_mode, get_mode
func get_mode() -> int: return selected
func set_mode(mode : int, emit := true) -> void: _select_int(mode)



# Core
func _ready() -> void:
	if not get_item_count() == VoxelEditorEngineClass.ToolModes.size():
		clear()
		var file := File.new()
		var modes := VoxelEditorEngineClass.ToolModes.keys()
		for mode in range(len(modes)):
			add_item(modes[mode].capitalize(), mode)
			if file.file_exists('res://addons/Voxel-Core/assets/BottomPanel/' + modes[mode].to_lower() + '.png'):
				set_item_icon(mode, load('res://addons/Voxel-Core/assets/BottomPanel/' + modes[mode].to_lower() + '.png'))
	set_mode(Tool)
	set_button_icon(get_item_icon(Tool))
