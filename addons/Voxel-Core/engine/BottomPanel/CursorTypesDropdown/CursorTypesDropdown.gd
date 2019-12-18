tool
extends OptionButton



# References
const VoxelCursor := preload('res://addons/Voxel-Core/engine/VoxelCursor.gd')



# Declarations
export(VoxelCursor.CursorTypes) var Type := VoxelCursor.CursorTypes.SOLID setget set_type, get_type
func get_type() -> int: return selected
func set_type(type : int, emit := true) -> void: _select_int(type)



# Core
func _ready() -> void:
	if not get_item_count() == VoxelCursor.CursorTypes.size():
		clear()
		var file := File.new()
		var types := VoxelCursor.CursorTypes.keys()
		for type in range(len(types)):
			add_item(types[type].capitalize(), type)
			if file.file_exists('res://addons/Voxel-Core/assets/BottomPanel/' + types[type].to_lower() + '.png'):
				set_item_icon(type, load('res://addons/Voxel-Core/assets/BottomPanel/' + types[type].to_lower() + '.png'))
	set_type(Type)
	set_button_icon(get_item_icon(Type))
