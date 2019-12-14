tool
extends Spatial
class_name VoxelEditor, 'res://addons/Voxel-Core/assets/VoxelEditor.png'



# Refrences
const VoxelObjectClass = preload('res://addons/Voxel-Core/src/VoxelObject.gd')



# Declarations
var undo_redo := UndoRedo.new()


signal set_tool(_tool)
enum Tools { PAN, ADD, SUB, PICK, SELECT, FILL }
export(Tools) var Tool := Tools.PAN setget set_tool
func set_tool(_tool : int, emit := true) -> void:
	Tool = _tool
	if emit: emit_signal('set_tool', Tool)

signal set_tool_mode(tool_mode)
enum ToolModes { INDIVIDUAL, AREA }
export(ToolModes) var ToolMode := ToolModes.INDIVIDUAL setget set_tool_mode
func set_tool_mode(toolmode : int, emit := true) -> void:
	ToolMode = toolmode
	if emit: emit_signal('set_tool_mode', ToolMode)


signal set_color_primary(color)
export(Color) var ColorPrimary := Color.white setget set_color_primary
func set_color_primary(color : Color, emit := true) -> void:
	ColorPrimary = color
	if emit: emit_signal('set_color_primary', ColorPrimary)

signal set_color_secondary(color)
export(Color) var ColorSecondary := Color.black setget set_color_secondary
func set_color_secondary(color : Color, emit := true) -> void:
	ColorSecondary = color
	if emit: emit_signal('set_color_secondary', ColorSecondary)


signal set_lock(lock)
export(bool) var Lock := false setget set_lock
func set_lock(lock := !Lock, emit := true) -> void:
	Lock = lock
	if emit: emit_signal('set_lock', Lock)


signal set_mirror_x(mirror_x)
export(bool) var MirrorX := false setget set_mirror_x
func set_mirror_x(mirrorx := !MirrorX, emit := true) -> void:
	MirrorX = mirrorx
	if emit: emit_signal('set_mirror_x', MirrorX)

signal set_mirror_y(mirror_y)
export(bool) var MirrorY := false setget set_mirror_y
func set_mirror_y(mirrory := !MirrorY, emit := true) -> void:
	MirrorY = mirrory
	if emit: emit_signal('set_mirror_y', MirrorY)

signal set_mirror_z(mirror_z)
export(bool) var MirrorZ := false setget set_mirror_z
func set_mirror_z(mirrorz := !MirrorZ, emit := true) -> void:
	MirrorZ = mirrorz
	if emit: emit_signal('set_mirror_z', MirrorZ)


signal set_cursor_color(color)
export(Color) var CursorColor := Color(1, 0, 0, 0.6) setget set_cursor_color
func set_cursor_color(color : Color, emit := true) -> void:
	CursorColor = color
	if emit: emit_signal('set_cursor_color', CursorColor)


signal set_floor_color(color)
export(Color) var FloorColor := Color.green setget set_floor_color
func set_floor_color(color : Color, emit := true) -> void:
	FloorColor = color
	if emit: emit_signal('set_floor_color', FloorColor)

signal set_floor_type(floortype)
enum FloorTypes { SOLID, WIRED }
export(FloorTypes) var FloorType := FloorTypes.WIRED setget set_floor_type
func set_floor_type(floortype : int, emit := true) -> void:
	FloorType = floortype
	if emit: emit_signal('set_floor_type', FloorType)


var VoxelObject : VoxelObjectClass setget edit



# Core
signal editing
func edit(voxelobject : VoxelObjectClass, options := {}, emit := true) -> void:
	VoxelObject = voxelobject
	if emit: emit_signal('editing')

signal committed
func commit(emit := true) -> void:
	if emit: emit_signal('committed')

signal canceled
func cancel(emit := true) -> void:
	if emit: emit_signal('canceled')


func __input(event : InputEvent, camera := get_viewport().get_camera()):
	pass
