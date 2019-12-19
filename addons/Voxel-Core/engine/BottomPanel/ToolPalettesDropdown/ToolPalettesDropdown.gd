tool
extends OptionButton



# References
const VoxelEditorEngineClass := preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')



# Declarations
export(VoxelEditorEngineClass.ToolPalettes) var Palette := VoxelEditorEngineClass.ToolPalettes.PRIMARY setget set_mode, get_mode
func get_mode() -> int: return selected
func set_mode(mode : int, emit := true) -> void: _select_int(mode)



# Core
func _ready() -> void:
	if not get_item_count() == VoxelEditorEngineClass.ToolPalettes.size():
		clear()
		var file := File.new()
		var palettes := VoxelEditorEngineClass.ToolPalettes.keys()
		for mode in range(len(palettes)):
			add_item(palettes[mode].capitalize(), mode)
			if file.file_exists('res://addons/Voxel-Core/assets/BottomPanel/' + palettes[mode].to_lower() + '.png'):
				set_item_icon(mode, load('res://addons/Voxel-Core/assets/BottomPanel/' + palettes[mode].to_lower() + '.png'))
	set_mode(Palette)
	set_button_icon(get_item_icon(Palette))
