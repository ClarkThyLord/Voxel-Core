tool
extends Spatial
class_name VoxelEditor, 'res://addons/Voxel-Core/assets/VoxelEditor.png'



# Refrences
const VoxelObjectClass = preload('res://addons/Voxel-Core/src/VoxelObject.gd')



# Declarations
var undo_redo := UndoRedo.new()


signal set_lock(lock)
export(bool) var Lock := true setget set_lock
func set_lock(lock := !Lock, emit := true) -> void:
	Lock = lock
	if emit: emit_signal('set_lock', Lock)


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


signal set_cursor_visible(visible)
export(bool) var CursorVisible := true setget set_cursor_visible
func set_cursor_visible(visible := !CursorVisible, emit := true) -> void:
	CursorVisible = visible
	if emit: emit_signal('set_cursor_visible', CursorVisible)

signal set_cursor_color(color)
export(Color) var CursorColor := Color(1, 0, 0, 0.6) setget set_cursor_color
func set_cursor_color(color : Color, emit := true) -> void:
	CursorColor = color
	if emit: emit_signal('set_cursor_color', CursorColor)


signal set_floor_visible(visible)
export(bool) var FloorVisible := true setget set_floor_visible
func set_floor_visible(visible := !FloorVisible, emit := true) -> void:
	FloorVisible = visible
	if emit: emit_signal('set_floor_visible', FloorVisible)

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


func set_options(options := DefaultOptions) -> void:
	for option in options.keys():
		self.set(option, options[option])

export(Dictionary) var DefaultOptions : Dictionary setget set_default_options
func set_default_options(defaultoptions := {
		'Lock': true,
		'Tool': Tools.PAN,
		'ToolMode': ToolModes.INDIVIDUAL,
		'ColorPrimary': Color.white,
		'ColorSecondary': Color.black,
		'MirrorX': false,
		'MirrorY': false,
		'MirrorZ': false
	}, reset := false) -> void:
	DefaultOptions = defaultoptions
	_save()
	if reset: set_options()


var VoxelObject : VoxelObjectClass setget edit
var VoxelObjectData : Dictionary setget set_voxel_object_data
func set_voxel_object_data(voxelobjectdata : Dictionary) -> void: return   #   VoxelObjectData shouldn't be settable externally


# Core
func _load() -> void:
	if has_meta('DefaultOptions'): set_default_options(get_meta('DefaultOptions'), true)

func _save() -> void:
	set_meta('DefaultOptions', DefaultOptions)


# The following will initialize the object as needed
func _init() -> void: _load()
func _ready() -> void:
	set_default_options()
	set_options()
	_load()


signal editing
func edit(voxelobject : VoxelObjectClass, options := {}, emit := true) -> void:
	if VoxelObjectClass and VoxelObject is VoxelObjectClass:
		cancel(emit)
	
	
	set_options(DefaultOptions if options.get('reset', false) else options)
	VoxelObject = voxelobject
	VoxelObjectData = {
		'voxels': voxelobject.get_voxels(),
		'MeshType': voxelobject.MeshType,
		'BuildStaticBody': voxelobject.BuildStaticBody,
	}
	voxelobject.MeshType = voxelobject.MeshTypes.NAIVE
	voxelobject.BuildStaticBody = true
	
	if emit: emit_signal('editing')

signal committed
func commit(emit := true) -> void:
	if emit: emit_signal('committed')

signal canceled
func cancel(emit := true) -> void:
	VoxelObject.set_voxels(VoxelObjectData['voxels'], false)
	VoxelObject.set_mesh_type(VoxelObjectData['MeshType'], false, false)
	VoxelObject.set_build_static_body(VoxelObjectData['BuildStaticBody'], false, false)
	
	VoxelObject = null
	VoxelObjectData.clear()
	undo_redo.clear_history()
	if emit: emit_signal('canceled')


func __input(event : InputEvent, camera := get_viewport().get_camera()):
	pass
