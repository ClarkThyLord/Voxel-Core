tool
extends OptionButton



# References
const VoxelEditorEngineClass := preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')



# Declarations
export(VoxelEditorEngineClass.Tools) var Tool := VoxelEditorEngineClass.Tools.PAN setget set_tool, get_tool
func get_tool() -> int: return selected
func set_tool(_tool : int, emit := true) -> void:
	Tool = _tool
	_select_int(_tool)
	if emit: emit_signal('item_selected', Tool)



# Core
func _ready() -> void:
	if not get_item_count() == VoxelEditorEngineClass.Tools.size():
		clear()
		var file := File.new()
		var _tools := VoxelEditorEngineClass.Tools.keys()
		for _tool in range(len(_tools)):
			add_item(_tools[_tool].capitalize(), _tool)
			if file.file_exists('res://addons/Voxel-Core/assets/BottomPanel/' + _tools[_tool].to_lower() + '.png'):
				set_item_icon(_tool, load('res://addons/Voxel-Core/assets/BottomPanel/' + _tools[_tool].to_lower() + '.png'))
	set_tool(Tool)
	set_button_icon(get_item_icon(Tool))
