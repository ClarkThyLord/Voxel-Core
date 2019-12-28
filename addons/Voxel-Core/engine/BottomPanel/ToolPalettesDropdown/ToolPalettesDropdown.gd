tool
extends OptionButton



# References
const VoxelEditorEngineClass := preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')



# Declarations
export(VoxelEditorEngineClass.ToolPalettes) var Palette := VoxelEditorEngineClass.ToolPalettes.PRIMARY setget set_palette, get_palette
func get_palette() -> int: return selected
func set_palette(palette : int, emit := true) -> void:
	Palette = palette
	_select_int(palette)
	if emit: emit_signal('item_selected', Palette)



# Core
func _ready() -> void:
	if not get_item_count() == VoxelEditorEngineClass.ToolPalettes.size():
		clear()
		var file := File.new()
		var palettes := VoxelEditorEngineClass.ToolPalettes.keys()
		for palette in range(len(palettes)):
			add_item(palettes[palette].capitalize(), palette)
			if file.file_exists('res://addons/Voxel-Core/assets/BottomPanel/' + palettes[palette].to_lower() + '.png'):
				set_item_icon(palette, load('res://addons/Voxel-Core/assets/BottomPanel/' + palettes[palette].to_lower() + '.png'))
	set_palette(Palette)
	set_button_icon(get_item_icon(Palette))
