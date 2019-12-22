tool
extends OptionButton



# References
const VoxelEditorEngineClass := preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')



# Declarations
export(VoxelEditorEngineClass.FloorTypes) var Type := VoxelEditorEngineClass.FloorTypes.SOLID setget set_type, get_type
func get_type() -> int: return selected
func set_type(type : int, emit := true) -> void:
	Type = type
	_select_int(type)
	if emit: emit_signal('item_selected', Type)



# Core
func _ready() -> void:
	if not get_item_count() == VoxelEditorEngineClass.FloorTypes.size():
		clear()
		var file := File.new()
		var types := VoxelEditorEngineClass.FloorTypes.keys()
		for type in range(len(types)):
			add_item(types[type].capitalize(), type)
			if file.file_exists('res://addons/Voxel-Core/assets/BottomPanel/' + types[type].to_lower() + '.png'):
				set_item_icon(type, load('res://addons/Voxel-Core/assets/BottomPanel/' + types[type].to_lower() + '.png'))
	set_type(Type)
	set_button_icon(get_item_icon(Type))
