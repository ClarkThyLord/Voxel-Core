tool
extends OptionButton



# Declarations
# Descriptions for Tools
const ToolDescriptions : Array = [
	'Add Tool       :   (key : a)\nAdd voxels to VoxelObject',
	'Remove Tool    :   (key : s)\nRemove voxels to VoxelObject',
	'Paint Tool     :   (key : d)\nPaint voxels to VoxelObject',
	'Color Picker   :   (key : g)\nPick a color from a voxel'
]

# Array of id of Tools Tool to make visible and selectable
export(Array, int) var VisibleTools : Array = [
	VoxelEditor.Tools.ADD,
	VoxelEditor.Tools.REMOVE,
	VoxelEditor.Tools.PAINT,
	VoxelEditor.Tools.COLOR_PICKER
] setget set_visible_tools
# Setter for VisibleTools
# tools   :   Array<int[Tools]>   -   Array of id of Tools Tool to set
#
# Example:
#   set_visible_tools([VoxelEditor.Tools.ADD, VoxelEditor.Tools.COLOR_PICKER])
#
func set_visible_tools(tools : Array) -> void:
	clear()
	tools.sort()
	
	if tools.has(VoxelEditor.Tools.ADD): add_icon_item(preload('res://addons/VoxelCore/assets/add.png'), 'Add', VoxelEditor.Tools.ADD)
	if tools.has(VoxelEditor.Tools.REMOVE): add_icon_item(preload('res://addons/VoxelCore/assets/remove.png'), 'Remove', VoxelEditor.Tools.REMOVE)
	if tools.has(VoxelEditor.Tools.PAINT): add_icon_item(preload('res://addons/VoxelCore/assets/paint.png'), 'Paint', VoxelEditor.Tools.PAINT)
	if tools.has(VoxelEditor.Tools.COLOR_PICKER): add_icon_item(preload('res://addons/VoxelCore/assets/picker.png'), 'Color Picker', VoxelEditor.Tools.COLOR_PICKER)
	
	if tools.size() > 1: selected = tools[0] 
	else: visible = false
	
	VisibleTools = tools



# Core
func _ready() -> void:
	set_tooltip(selected)
	set_visible_tools(VisibleTools)


# Set tooltip with VoxelEditor's Tools Tool id
# tool_id     :   int   -   VoxelEditor's Tools Tool id
#
# Example:
#   set_tooltip(VoxelEditor.Tools.REMOVE)
#
func set_tooltip(tool_id) -> void: hint_tooltip = ToolDescriptions[tool_id]
