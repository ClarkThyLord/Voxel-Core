tool
extends "res://addons/Voxel-Core/src/VoxelEditor.gd"



# Declarations
var starting_version : int
var undo_redo := UndoRedo.new()
export(bool) var on_commit_clear_history := false
export(bool) var on_cancel_clear_history := false


signal set_lock(lock)
export(bool) var Lock := true setget set_lock
func set_lock(lock := !Lock, emit := true) -> void:
	Lock = lock
	if emit: emit_signal('set_lock', Lock)


signal set_tool(_tool)
enum Tools { PAN, SELECT, ADD, SUB, PICK, FILL }
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


signal set_primary(voxel)
var Primary := {} setget set_primary
func set_primary(voxel : Dictionary, emit := true) -> void:
	Primary = voxel
	if emit: emit_signal('set_primary', Primary)

signal set_primary_color(color)
export(Color) var PrimaryColor := Color.white setget set_primary_color
func set_primary_color(color : Color, emit := true) -> void:
	PrimaryColor = color
	if emit: emit_signal('set_primary_color', PrimaryColor)

signal set_secondary(voxel)
var Secondary := {} setget set_secondary
func set_secondary(voxel : Dictionary, emit := true) -> void:
	Secondary = voxel
	if emit: emit_signal('set_secondary', Secondary)

signal set_secondary_color(color)
export(Color) var SecondaryColor := Color.black setget set_secondary_color
func set_secondary_color(color : Color, emit := true) -> void:
	SecondaryColor = color
	if emit: emit_signal('set_secondary_color', SecondaryColor)


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


var Cursor : MeshInstance setget set_cursor
func set_cursor(cursor : MeshInstance) -> void: return   #   Cursor shouldn't be settable externally

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


var Floor : MeshInstance setget set_floor
func set_floor(_floor : MeshInstance) -> void: return   #   Floor shouldn't be settable externally

signal set_floor_visible(visible)
export(bool) var FloorVisible := true setget set_floor_visible
func set_floor_visible(visible := !FloorVisible, emit := true) -> void:
	FloorVisible = visible
	if emit: emit_signal('set_floor_visible', FloorVisible)

signal set_floor_color(color)
export(Color) var FloorColor := Color.purple setget set_floor_color
func set_floor_color(color : Color, emit := true) -> void:
	FloorColor = color
	if emit: emit_signal('set_floor_color', FloorColor)

signal set_floor_type(floortype)
enum FloorTypes { SOLID, WIRED }
export(FloorTypes) var FloorType := FloorTypes.WIRED setget set_floor_type
func set_floor_type(floortype : int, emit := true) -> void:
	FloorType = floortype
	if emit: emit_signal('set_floor_type', FloorType)


func set_default_options(defaultoptions := {
		'Lock': true,
		'Tool': Tools.PAN,
		'ToolMode': ToolModes.INDIVIDUAL,
		'Primary': {},
		'PrimaryColor': Color.white,
		'Secondary': {},
		'SecondaryColor': Color.black,
		'MirrorX': false,
		'MirrorY': false,
		'MirrorZ': false
	}, reset := false) -> void:
	.set_default_options(defaultoptions, reset)



# Core
func _init() -> void: _load()
func _ready() -> void:
	set_default_options()
	set_options()
	_load()

func edit(voxelobject : VoxelObjectClass, options := {}, update := true, emit := true) -> void:
	.edit(voxelobject, options, true, false)
	
	starting_version = undo_redo.get_version()
	VoxelObjectData['voxels'] = voxelobject.get_voxels()
	
	if emit: emit_signal('editing')

func commit(update := true, emit := true) -> void:
	if VoxelObject and VoxelObject is VoxelObjectClass:
		.commit(update, false)
		
		if on_commit_clear_history: undo_redo.clear_history()
		
		if emit: emit_signal('committed')

signal canceled
func cancel(update := true, emit := true) -> void:
	if VoxelObject and VoxelObject is VoxelObjectClass:
		VoxelObject.set_voxels(VoxelObjectData['voxels'], false)
		VoxelObject.set_mesh_type(VoxelObjectData['MeshType'], false, false)
		VoxelObject.set_build_static_body(VoxelObjectData['BuildStaticBody'], false, false)
		
		if update: VoxelObject.update()
		
		VoxelObject = null
		VoxelObjectData = {}
		if on_cancel_clear_history: undo_redo.clear_history()
		
		if emit: emit_signal('canceled')


# Helper function for easy Raycasting
# event      :   InputEventMouse       -   MouseEvent to Raycast for
# camera     :   Camera                -   Camera from which to Raycast
# @returns   :   Raycast[Dictionary]   -   Dictionary containing all Raycast info
#
# Example:
#   raycast([InputEventMouse], [Camera]) -> [Raycast]
#
func raycast(event : InputEventMouse, camera : Camera = get_viewport().get_camera()) -> Dictionary:
	var from = camera.project_ray_origin(event.position)
	var to = from + camera.project_ray_normal(event.position) * 1000
	return camera.get_world().direct_space_state.intersect_ray(from, to)

# Helper function for easy Raycasting to a VoxelObject
# event         :   InputEventMouse       -   MouseEvent to Raycast for
# camera        :   Camera                -   Camera from which to Raycast
# exclude       :   Array                 -   Collision shapes to exclude from raycast
# @returns      :   Raycast[Dictionary]   -   Dictionary containing all Raycast info
#
# Example:
#   raycast_for_voxelobject([InputEventMouse], [Camera], [VoxelObject], [ ... ]) -> [Raycast]
#
func raycast_for_voxelobject(event : InputEventMouse, camera : Camera = get_viewport().get_camera(), exclude : Array = []) -> Dictionary:
	var hit : Dictionary
	var from = camera.project_ray_origin(event.position)
	var to = from + camera.project_ray_normal(event.position) * 1000
	while true:
		hit = camera.get_world().direct_space_state.intersect_ray(from, to, exclude)
		if hit:
			if VoxelObject.is_a_parent_of(hit.collider): break
			else: exclude.append(hit.collider)
		else: break
	
	return hit

# Helper function for getting mirrors
# grid       :   Vector3            -   Grid position to mirror according to Mirror options
# @returns   :   Array[Vector3]     -   Array containing original position and all mirrored position
#
# Example:
#   grid_to_mirrors(Vector(3, 1, -3)) -> [ Vector(3, 1, -3), ... ]
#
func grid_to_mirrors(grid : Vector3) -> Array:
	var mirrors = [grid]
	
	if MirrorX:
		mirrors.append(Vector3(grid.x, grid.y, (grid.z + 1) * -1))
		if MirrorZ:
			mirrors.append(Vector3((grid.x + 1) * -1, grid.y, (grid.z + 1) * -1))
	if MirrorY:
		mirrors.append(Vector3(grid.x, (grid.y + 1) * -1, grid.z))
		if MirrorX:
			mirrors.append(Vector3(grid.x, (grid.y + 1) * -1, (grid.z + 1) * -1))
		if MirrorZ:
			mirrors.append(Vector3((grid.x + 1) * -1, (grid.y + 1) * -1, grid.z))
		if MirrorX && MirrorZ:
			mirrors.append(Vector3((grid.x + 1) * -1, (grid.y + 1) * -1, (grid.z + 1) * -1))
	if MirrorZ:
		mirrors.append(Vector3((grid.x + 1) * -1, grid.y, grid.z))
		if MirrorX:
			mirrors.append(Vector3((grid.x + 1) * -1, grid.y, (grid.z + 1) * -1))
	
	return mirrors


func __input(event : InputEvent, camera := get_viewport().get_camera()) -> bool:
	if not Lock and VoxelObject and VoxelObject is VoxelObjectClass:
		print('event')
		return false
	else: return false
