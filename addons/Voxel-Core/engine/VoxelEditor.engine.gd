tool
extends "res://addons/Voxel-Core/src/VoxelEditor.gd"



# Refrences
const VoxelCursor := preload('res://addons/Voxel-Core/engine/VoxelCursor.gd')



# Declarations
var StartingVersion : int
signal modified(Modified)
var Modified : bool = false setget set_modified   #   Whether the currently editing VoxelObject has been modified
# Set modified, emits 'modified'.
# modified   :   bool   -   value to set
# emit       :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_modified(false, false)
#
func set_modified(modified := !Modified, emit := true) -> void:
	Modified = modified
	if emit: emit_signal('modified', modified)
var undo_redo := UndoRedo.new()
export(bool) var on_commit_clear_history := false   #   Weather history should be cleared on 'commit'
export(bool) var on_cancel_clear_history := false   #   Weather history should be cleared on 'cancel'


signal set_lock(lock)
export(bool) var Lock := true setget set_lock   #   Whether the currently editing VoxelObject is modifiable
# Set Lock, emits 'set_lock'.
# lock   :   bool   -   value to set
# emit   :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_lock(false, false)
#
func set_lock(lock := !Lock, emit := true) -> void:
	Lock = lock
	
	if Lock: set_cursors_visible(false)
	
	if emit: emit_signal('set_lock', Lock)


signal set_rawdata(rawdata)
export(bool) var RawData := false setget set_rawdata   #   Active, raw data will be handled; inactive, VoxelSet IDs will be handled when possible
# Set RawData, emits 'set_rawdata'.
# rawdata   :   bool   -   value to set
# emit      :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_rawdata(false, false)
#
func set_rawdata(rawdata := !RawData, emit := true) -> void:
	RawData = rawdata
	if emit: emit_signal('set_rawdata', RawData)


signal set_tool(_tool)
enum Tools {
	PAN,    #   Move around
	# TODO SELECT,
	ADD,    #   Set Voxels with current Palette
	SUB,    #   Erase Voxels
	PICK,   #   Get Voxels and set them as current Palette
	FILL    #   Replace all matching Voxels with current Palette
}
export(Tools) var Tool := Tools.PAN setget set_tool   #   Tool being used
# Set Tool, emits 'set_tool'.
# _tool   :   int(Tools)    -   value to set
# emit    :   bool          -   true, emit signal; false, don't emit signal
#
# Example:
#   set_tool(Tools.ADD, false)
#
func set_tool(_tool : int, emit := true) -> void:
	Tool = _tool
	
	update_cursors()
	
	if emit: emit_signal('set_tool', Tool)

signal set_tool_palette(tool_palette)
enum ToolPalettes { PRIMARY, SECONDARY }
export(ToolPalettes) var ToolPalette := ToolPalettes.PRIMARY setget set_tool_palette   #   Palette being used
# Get the currently used Palette.
func get_palette():
	var palette
	match ToolPalette:
		ToolPalettes.PRIMARY:
			palette = get_primary()
		ToolPalettes.SECONDARY:
			palette = get_secondary()
	return palette

# Get the currently used raw Palette.
func get_rpalette():
	var palette
	match ToolPalette:
		ToolPalettes.PRIMARY:
			palette = get_rprimary()
		ToolPalettes.SECONDARY:
			palette = get_rsecondary()
	return palette

# Set the current Palette, emits 'set_tool_palette'.
# toolpalette   :   int(ToolPalettes)   -   value to set
# emit          :   bool                -   true, emit signal; false, don't emit signal
#
# Example:
#   set_tool_palette(ToolPalettes.SECONDARY, false)
#
func set_tool_palette(toolpalette : int, emit := true) -> void:
	ToolPalette = toolpalette
	if emit: emit_signal('set_tool_palette', ToolPalette)

signal set_tool_mode(tool_mode)
enum ToolModes {
	INDIVIDUAL,   #   Individual operations
	AREA          #   Wide area operations
}
export(ToolModes) var ToolMode := ToolModes.INDIVIDUAL setget set_tool_mode   #   How operations will be committed
# Set ToolMode, emits 'set_tool_mode'.
# toolmode   :   int    -   value to set
# emit       :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_tool_mode(ToolModes.AREA, false)
#
func set_tool_mode(toolmode : int, emit := true) -> void:
	ToolMode = toolmode
	if emit: emit_signal('set_tool_mode', ToolMode)


signal set_primary(voxel)
var Primary = null setget set_primary   #   Primary palette Voxel
# Get Primary palette Voxel.
func get_primary() -> Dictionary:
	var primary = get_rprimary()
	if not typeof(primary) == TYPE_DICTIONARY:
		primary = VoxelObject.VoxelSet.get_voxel(primary)
		if typeof(primary) == TYPE_NIL: primary = Voxel.colored(PrimaryColor)
	return primary

# Get raw Primary palette Voxel.
func get_rprimary():
	return Voxel.colored(PrimaryColor) if typeof(Primary) == TYPE_NIL else Primary

# Set Primary palette, emits 'set_primary'.
# voxel   :   int/String/Dictionary(Voxel)   -   value to set
# emit    :   bool                           -   true, emit signal; false, don't emit signal
#
# Example:
#   set_primary(2)
#   set_primary('black', true)
#   set_primary({ ... }, false)
#
func set_primary(voxel = null, emit := true) -> void:
	Primary = voxel
	if emit: emit_signal('set_primary', Primary)

signal set_primary_color(color)
export(Color) var PrimaryColor := Color.white setget set_primary_color   #   Primary palette Color
# Set Primary palette color, emits 'set_primary_color'.
# color   :   Color   -   value to set
# emit    :   bool    -   true, emit signal; false, don't emit signal
#
# Example:
#   set_primary_color(Color.black, false)
#
func set_primary_color(color : Color, emit := true) -> void:
	PrimaryColor = color
	if emit: emit_signal('set_primary_color', PrimaryColor)

signal set_secondary(voxel)
var Secondary = null setget set_secondary   #   Secondary palette Voxel
# Get Secondary palette Voxel.
func get_secondary() -> Dictionary:
	var secondary = get_rsecondary()
	if not typeof(secondary) == TYPE_DICTIONARY:
		secondary = VoxelObject.VoxelSet.get_voxel(secondary)
		if typeof(secondary) == TYPE_NIL: secondary = Voxel.colored(SecondaryColor)
	return secondary
	
# Get raw Secondary palette Voxel.
func get_rsecondary():
	return Voxel.colored(SecondaryColor) if typeof(Secondary) == TYPE_NIL else Secondary

# Set Secondary palette, emits 'set_secondary'.
# voxel   :   int/String/Dictionary(Voxel)   -   value to set
# emit    :   bool                           -   true, emit signal; false, don't emit signal
#
# Example:
#   set_secondary(2)
#   set_secondary('black', true)
#   set_secondary({ ... }, false)
#
func set_secondary(voxel = null, emit := true) -> void:
	Secondary = voxel
	if emit: emit_signal('set_secondary', Secondary)

signal set_secondary_color(color)
export(Color) var SecondaryColor := Color.black setget set_secondary_color   #   Secondary palette Color
# Set Secondary palette color, emits 'set_secondary_color'.
# color   :   Color   -   value to set
# emit    :   bool    -   true, emit signal; false, don't emit signal
#
# Example:
#   set_secondary_color(Color.black, false)
#
func set_secondary_color(color : Color, emit := true) -> void:
	SecondaryColor = color
	if emit: emit_signal('set_secondary_color', SecondaryColor)


signal set_mirror_x(mirror_x)
export(bool) var MirrorX := false setget set_mirror_x   #   Whether to mirror operations over the X-axis
# Set MirrorX, emit 'set_mirror_x'.
# mirrorx   :   bool   -   value to set
# emit      :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_mirrorx(false, false)
#
func set_mirror_x(mirrorx := !MirrorX, emit := true) -> void:
	MirrorX = mirrorx
	
	update_cursors()
	
	if emit: emit_signal('set_mirror_x', MirrorX)

signal set_mirror_y(mirror_y)
export(bool) var MirrorY := false setget set_mirror_y   #   Whether to mirror operations over the Y-axis
# Set MirrorY, emit 'set_mirror_y'.
# mirrory   :   bool   -   value to set
# emit      :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_mirrory(false, false)
#
func set_mirror_y(mirrory := !MirrorY, emit := true) -> void:
	MirrorY = mirrory
	
	update_cursors()
	
	if emit: emit_signal('set_mirror_y', MirrorY)

signal set_mirror_z(mirror_z)
export(bool) var MirrorZ := false setget set_mirror_z   #   Whether to mirror operations over the Z-axis
# Set MirrorZ, emit 'set_mirror_z'.
# mirrorz   :   bool   -   value to set
# emit      :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_mirrorz(false, false)
#
func set_mirror_z(mirrorz := !MirrorZ, emit := true) -> void:
	MirrorZ = mirrorz
	
	update_cursors()
	
	if emit: emit_signal('set_mirror_z', MirrorZ)


# Contains a refrence to each Cursor
var Cursors := {
	Vector3(0, 0, 0): VoxelCursor.new(),
	Vector3(1, 0, 0): VoxelCursor.new(),
	Vector3(1, 1, 0): VoxelCursor.new(),
	Vector3(1, 1, 1): VoxelCursor.new(),
	Vector3(0, 1, 1): VoxelCursor.new(),
	Vector3(0, 1, 0): VoxelCursor.new(),
	Vector3(0, 0, 1): VoxelCursor.new(),
	Vector3(1, 0, 1): VoxelCursor.new()
} setget set_cursors
func set_cursors(cursor : Dictionary) -> void: return   #   Cursors shouldn't be settable externally

# Set up each Cursor accordingly.
func setup_cursors() -> void:
	for cursor in Cursors.values():
		cursor.set_cursor_color(CursorColor)

# Parent all the Cursors to given parent.
# parent   :   Node   -   Node to parent Cursors to
#
# Example:
#   set_cursors_parent([Node])
#
func set_cursors_parent(parent : Node) -> void:
	unset_cursors_parent()
	for cursor in Cursors.values():
		if cursor:
			parent.add_child(cursor)

# Unparents all the Cursors from their parent.
func unset_cursors_parent() -> void:
	for cursor in Cursors.values():
		if cursor and cursor.get_parent():
			cursor.get_parent().remove_child(cursor)

# Sets the visibility for all Cursors
# visible   :   bool   -   value to set
#
# Example:
#   set_cursors_visible(false)
#
func set_cursors_visible(visible : bool) -> void:
	for cursor in Cursors.values():
		cursor.visible = visible

var cursors_started_area := false         #   Whether selection has started
var cursors_are_selecting_area := false   #   Whether selection is happening
# Update cursors visiblity, position and selection area.
func update_cursors() -> void:
	if pointer_visible:
		var position = get_pointer()
		var visible_cursors = grid_to_mirrors(position)
		var all_mirrors = grid_to_mirrors(position, true, true, true)
		for cursor_key in Cursors:
			if not pointer_visible or Lock or Tool == Tools.PAN:
				Cursors[cursor_key].visible = false
			else:
				Cursors[cursor_key].visible = CursorVisible and visible_cursors.has(cursor_key)
			
			if ToolMode == ToolModes.AREA:
				if cursors_are_selecting_area:
					Cursors[cursor_key].set_target_position(all_mirrors[cursor_key])
					continue
			
			Cursors[cursor_key].set_cursor_position(all_mirrors[cursor_key])
			Cursors[cursor_key].set_target_position(all_mirrors[cursor_key])
		if cursors_started_area:
			cursors_are_selecting_area = true

signal set_cursor_visible(visible)
export(bool) var CursorVisible := true setget set_cursor_visible   #   Whether cursors are visible
# Setter for CursorVisible, emits 'set_cursor_visible'.
# visible   -   bool   -   value to set
# emit      -   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_cursor_visible(false, false)
#
func set_cursor_visible(visible := !CursorVisible, emit := true) -> void:
	CursorVisible = visible
	
	if not CursorVisible: set_cursors_visible(false)
	
	if emit: emit_signal('set_cursor_visible', CursorVisible)

signal set_cursor_color(color)
export(Color) var CursorColor := Color(1, 0, 0, 0.3) setget set_cursor_color   #   Cursor color
# Setter for CursorColor, emits 'set_cursor_color'.
# color   -   bool   -   value to set
# emit    -   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_cursor_color(Color(0.33, 0.66, 0.33, 0.6), false)
#
func set_cursor_color(color : Color, emit := true) -> void:
	CursorColor = color
	
	for cursor in Cursors.values():
		cursor.set_cursor_color(CursorColor)
	
	if emit: emit_signal('set_cursor_color', CursorColor)

signal set_cursor_type(cursortype)
export(VoxelCursor.CursorTypes) var CursorType := VoxelCursor.CursorTypes.SOLID setget set_cursor_type   #   Cursor type
# Setter for CursorType, emits 'set_cursor_type'.
# cursortype   :   int(VoxelCursor.CursorType)    -   value to set
# emit         :   bool                           -   true, emit signal; false, don't emit signal
#
# Example:
#   set_cursor_type(VoxelCursor.CursorTypes.WIRED, false)
#
func set_cursor_type(cursortype : int, emit := true) -> void:
	CursorType = cursortype
	
	for cursor in Cursors.values():
		cursor.set_cursor_type(CursorType)
	
	if emit: emit_signal('set_cursor_type', CursorType)


var Floor : MeshInstance = MeshInstance.new() setget set_floor   #   Refrence to Floor
func set_floor(_floor : MeshInstance) -> void: return            #   Floor shouldn't be settable externally

func setup_floor() -> void: update_floor()   #   Setup floor accordingly

# Update floor visuals
func update_floor() -> void:
	if Floor:
		for child in Floor.get_children():
			Floor.remove_child(child)
			child.queue_free()
		
		Floor.set_name('VEFloor')
		Floor.visible = FloorVisible
		
		match FloorType:
			FloorTypes.SOLID:
				Floor.mesh = PlaneMesh.new()
				Floor.scale = Vector3.ONE * 16 * Voxel.GridStep
				Floor.create_trimesh_collision()
				Floor.material_override = SpatialMaterial.new()
				Floor.material_override.set_cull_mode(2)
				Floor.material_override.albedo_color = FloorColor
			FloorTypes.WIRED:
				Floor.scale = Vector3.ONE
				var dimensions = Vector3.ONE * 16
				
				var ST = SurfaceTool.new()
				ST.begin(Mesh.PRIMITIVE_LINES)
				ST.add_color(FloorColor)
				
				var material = SpatialMaterial.new()
				material.roughness = 1
				material.vertex_color_is_srgb = true
				material.vertex_color_use_as_albedo = true
				material.set_cull_mode(2)
				ST.set_material(material)
				
				var x : int = -dimensions.x
				while x <= dimensions.x:
					ST.add_normal(Vector3.UP)
					ST.add_vertex(Voxel.grid_to_pos(Vector3(x, 0, -abs(dimensions.z))))
					ST.add_vertex(Voxel.grid_to_pos(Vector3(x, 0, abs(dimensions.z))))
					
					x += 1
				
				var z : int = -dimensions.z
				while z <= dimensions.z:
					ST.add_normal(Vector3.UP)
					ST.add_vertex(Voxel.grid_to_pos(Vector3(-abs(dimensions.x), 0, z)))
					ST.add_vertex(Voxel.grid_to_pos(Vector3(abs(dimensions.x), 0, z)))
					
					z += 1
				
				ST.index()
				
				Floor.mesh = ST.commit()
				Floor.create_convex_collision()
		
		if Floor.has_node('VEFloor_col'):
			Floor.get_node('VEFloor_col').get_children()[0].disabled = !FloorVisible

# Parent Floor to given parent.
# parent   :   Node   -   Node to parent Floor to
#
# Example:
#   set_floor_parent([Node])
#
func set_floor_parent(parent : Node) -> void:
	unset_floor_parent()
	if Floor:
		parent.add_child(Floor)

# Unparents the Floor from its parent.
func unset_floor_parent() -> void:
	if Floor and Floor.get_parent():
		Floor.get_parent().remove_child(Floor)

signal set_floor_visible(visible)
export(bool) var FloorVisible := true setget set_floor_visible

# Sets the visibility for the Floor
# visible   :   bool   -   value to set
#
# Example:
#   set_floor_visible(false)
#
func set_floor_visible(visible := !FloorVisible, emit := true) -> void:
	FloorVisible = FloorConstant or visible
	if Floor:
		Floor.visible = FloorVisible
		if Floor.has_node('VEFloor_col'):
			Floor.get_node('VEFloor_col').get_children()[0].disabled = !visible
	if emit: emit_signal('set_floor_visible', FloorVisible)

signal set_floor_constant(constant)
export(bool) var FloorConstant := false setget set_floor_constant   #   Whether Floor shall be visible when voxels are present
# Setter FloorConstant, emits 'set_floor_constant'.
# constant   :   bool   -   value to set
# emit       :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_floor_constant(true, false)
#
func set_floor_constant(constant := !FloorConstant, emit := true) -> void:
	FloorConstant = constant
	
	set_floor_visible(FloorConstant or (VoxelObject and not VoxelObject.mesh))
	
	if emit: emit_signal('set_floor_constant', FloorConstant)

signal set_floor_color(color)
export(Color) var FloorColor := Color.purple setget set_floor_color   #   Floor Color
# Setter for FloorColor, emits 'set_floor_color'.
# color   :   Color   -   value to set
# emit    :   bool    -   true, emit signal; false, don't emit signal
#
# Example:
#   set_floor_color(Color(1, 0, 0), false)
#
func set_floor_color(color : Color, emit := true) -> void:
	FloorColor = color
	if Floor and Floor.material_override and Floor.material_override.albedo_color: 
		Floor.material_override.albedo_color = FloorColor
	if emit: emit_signal('set_floor_color', FloorColor)

signal set_floor_type(floortype)
enum FloorTypes { SOLID, WIRED }
export(FloorTypes) var FloorType := FloorTypes.WIRED setget set_floor_type   #   Set floor type
# Setter for FloorType, emits 'set_floor_type'.
# floortype   :   int(FloorTypes)    -   value to set
# emit        :   bool               -   true, emit signal; false, don't emit signal
#
# Example:
#   set_floor_type(FloorTypes.SOLID, false)
#
func set_floor_type(floortype : int, emit := true) -> void:
	FloorType = floortype
	update_floor()
	if emit: emit_signal('set_floor_type', FloorType)


func set_default_options(defaultoptions := {
		'Lock': true,
		'RawData': false,
		'Tool': Tools.PAN,
		'ToolPalette': ToolPalettes.PRIMARY,
		'ToolMode': ToolModes.INDIVIDUAL,
		'Primary': null,
		'PrimaryColor': Color.white,
		'Secondary': null,
		'SecondaryColor': Color.black,
		'MirrorX': false,
		'MirrorY': false,
		'MirrorZ': false,
		'CursorVisible': true,
		'CursorColor': Color(1, 0, 0, 0.3),
		'CursorType': VoxelCursor.CursorTypes.SOLID,
		'FloorVisible': true,
		'FloorConstant': false,
		'FloorColor': Color.purple,
		'FloorType': FloorTypes.WIRED
	}, reset := false) -> void:
	.set_default_options(defaultoptions, reset)



# Core
func _init() -> void:
	setup_cursors()
	setup_floor()
	set_cursors_visible(false)
	set_default_options()
	_load()
func _ready() -> void:
	set_default_options()
	set_options()
	_load()

func _exit_tree():
	detach_editor_components()
	for cursor in Cursors.values():
		cursor.queue_free()
	Floor.queue_free()


# Attaches editor components to current VoxelObject
func attach_editor_components() -> void:
	set_cursors_parent(VoxelObject)
	set_floor_parent(VoxelObject)

# Dettaches editor components to current VoxelObject
func detach_editor_components() -> void:
	unset_cursors_parent()
	unset_floor_parent()


func edit(voxelobject : VoxelObjectClass, options := {}, update := true, emit := true) -> void:
	.edit(voxelobject, options, true, false)
	
	set_lock(true)
	Modified = false
	StartingVersion = undo_redo.get_version()
	VoxelObjectData['voxels'] = voxelobject.get_voxels()
	
	set_cursors_visible(false)
	set_floor_visible(FloorConstant or (VoxelObject and not VoxelObject.mesh))
	attach_editor_components()
	
	if emit: emit_signal('editing')

func commit(update := true, emit := true) -> void:
	if VoxelObject and VoxelObject is VoxelObjectClass:
		.commit(update, false)
		
		
		Modified = false
		StartingVersion = -1
		if on_commit_clear_history: undo_redo.clear_history()
		
		detach_editor_components()
		
		if emit: emit_signal('committed')

signal canceled
# Cancels changes done to VoxelObject currently being edited, emits 'canceled'
# update   :   bool   -   whether to update VoxelObject
# emit     :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   cancel(false, false)
#
func cancel(update := true, emit := true) -> void:
	if VoxelObject and VoxelObject is VoxelObjectClass:
		VoxelObject.set_voxels(VoxelObjectData['voxels'], false)
		
		VoxelObject.set_editing(false, false)
		if update: VoxelObject.update()
		
		
		VoxelObject = null
		VoxelObjectData = {}
		
		Modified = false
		StartingVersion = -1
		if on_cancel_clear_history: undo_redo.clear_history()
		
		detach_editor_components()
		
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
# grid       :   Vector3                        -   Grid position to mirror according to Mirror options
# mirrorx    :   Vector3                        -   Whether to mirror over x axis
# mirrory    :   Vector3                        -   Whether to mirror over y axis
# mirrorz    :   Vector3                        -   Whether to mirror over z axis
# @returns   :   Dictionary<Vector3, Vector3>   -   Array containing original position and all mirrored position
#
# Example:
#   grid_to_mirrors(Vector(3, 1, -3)) -> [ Vector(3, 1, -3), ... ]
#
func grid_to_mirrors(grid : Vector3, mirrorx := MirrorX, mirrory := MirrorY, mirrorz := MirrorZ) -> Dictionary:
	var mirrors = { Vector3(0,0,0): grid }
	
	if mirrorx:
		mirrors[Vector3(1, 0, 0)] = Vector3(grid.x, grid.y, (grid.z + 1) * -1)
		if mirrorz:
			mirrors[Vector3(1, 0, 1)] = Vector3((grid.x + 1) * -1, grid.y, (grid.z + 1) * -1)
	if mirrory:
		mirrors[Vector3(0, 1, 0)] = Vector3(grid.x, (grid.y + 1) * -1, grid.z)
		if mirrorx:
			mirrors[Vector3(1, 1, 0)] = Vector3(grid.x, (grid.y + 1) * -1, (grid.z + 1) * -1)
		if mirrorz:
			mirrors[Vector3(0, 1, 1)] = Vector3((grid.x + 1) * -1, (grid.y + 1) * -1, grid.z)
		if mirrorx && mirrorz:
			mirrors[Vector3(1, 1, 1)] = Vector3((grid.x + 1) * -1, (grid.y + 1) * -1, (grid.z + 1) * -1)
	if mirrorz:
		mirrors[Vector3(0, 0, 1)] = Vector3((grid.x + 1) * -1, grid.y, grid.z)
	
	return mirrors


# Helper function that does the current tool operations, and registers it to undo redo.
# grids   :   Array<Vector3>   -   Grid position to which do operations
#
# Example:
#   use_tool([ Vector(2, -1, 0) ])
#
func use_tool(grids : Array) -> void:
	undo_redo.create_action('VoxelEditor ' + str(Tools.keys()[Tool]))
	match Tool:
		Tools.ADD:
			for grid in grids:
				tool_add(grid, get_palette() if RawData else get_rpalette())
			
			undo_redo.add_do_method(VoxelObject, 'update')
			undo_redo.add_undo_method(VoxelObject, 'update')
		Tools.SUB:
			for grid in grids:
				tool_sub(grid)
			
			undo_redo.add_do_method(VoxelObject, 'update')
			undo_redo.add_undo_method(VoxelObject, 'update')
		Tools.PICK:
			var voxel = VoxelObject.get_rvoxel(Cursors[Vector3(0, 0, 0)].CursorPosition)
			if typeof(voxel) == TYPE_NIL: pass
			elif typeof(voxel) == TYPE_DICTIONARY:
				match ToolPalette:
					ToolPalettes.PRIMARY:
						undo_redo.add_do_method(self, 'set_primary_color', Voxel.get_color(voxel))
						undo_redo.add_undo_method(self, 'set_primary_color', PrimaryColor)
					ToolPalettes.SECONDARY:
						undo_redo.add_do_method(self, 'set_secondary_color', Voxel.get_color(voxel))
						undo_redo.add_undo_method(self, 'set_secondary_color', SecondaryColor)
			else:
				match ToolPalette:
					ToolPalettes.PRIMARY:
						undo_redo.add_do_method(self, 'set_primary', voxel)
						undo_redo.add_undo_method(self, 'set_primary', Primary)
					ToolPalettes.SECONDARY:
						undo_redo.add_do_method(self, 'set_secondary', voxel)
						undo_redo.add_undo_method(self, 'set_secondary', Primary)
		Tools.FILL:
			var voxel = VoxelObject.get_rvoxel(Cursors[Vector3(0, 0, 0)].CursorPosition)
			if typeof(voxel) == TYPE_NIL: pass
			else:
				set_modified(true)
				for cursor_index in grid_to_mirrors(Cursors[Vector3(0, 0, 0)].CursorPosition):
					voxel = VoxelObject.get_rvoxel(Cursors[cursor_index].CursorPosition)
					grids = Voxel.flood_select(Cursors[cursor_index].CursorPosition, Voxel.get_color(voxel) if typeof(voxel) == TYPE_DICTIONARY else voxel, VoxelObject.get_voxels())
					for grid in grids:
						tool_add(grid, get_palette() if RawData else get_rpalette())
			
			undo_redo.add_do_method(VoxelObject, 'update')
			undo_redo.add_undo_method(VoxelObject, 'update')
	undo_redo.commit_action()

func tool_add(grid : Vector3, voxel) -> void:
	set_modified(true)
	undo_redo.add_do_method(VoxelObject, 'set_voxel', grid, voxel, false)
	voxel = VoxelObject.get_rvoxel(grid)
	if typeof(voxel) == TYPE_NIL:
		undo_redo.add_undo_method(VoxelObject, 'erase_voxel', grid, false)
	else:
		undo_redo.add_undo_method(VoxelObject, 'set_voxel', grid, voxel, false)

func tool_sub(grid) -> void:
	var voxel = VoxelObject.get_voxel(grid)
	if not typeof(voxel) == TYPE_NIL:
		set_modified(true)
		undo_redo.add_do_method(VoxelObject, 'erase_voxel', grid, false)
		undo_redo.add_undo_method(VoxelObject, 'set_voxel', grid, voxel, false)


var pointer_normal
var pointer_position
var pointer_visible := false
func get_pointer():
	var _pointer_normal = pointer_normal
	var _pointer_position = pointer_position
	
	if not Tool == Tools.ADD: _pointer_normal *= -1
	return Voxel.abs_to_grid(VoxelObject.to_local(_pointer_position + (_pointer_normal  * (Voxel.VoxelSize / 2))))


func __input(event : InputEvent, camera := get_viewport().get_camera()) -> bool:
	if event is InputEventMouse:
		var hit = raycast_for_voxelobject(event, camera)
		if hit:
			pointer_visible = true
			pointer_normal = hit.normal
			pointer_position = hit.position
			update_cursors()
		else:
			pointer_visible = false
	
	
	
	return false
	
	
#	if not Lock and VoxelObject and VoxelObject is VoxelObjectClass:
#		if event is InputEventMouse and Tool > Tools.PAN:
#			var hit = raycast_for_voxelobject(event, camera)
#			if hit:
#				if not Tool == Tools.ADD or Input.is_key_pressed(KEY_SHIFT): hit.normal *= -1
#				hit.position += hit.normal  * (Voxel.VoxelSize / 2)
#				var grid_pos = Voxel.abs_to_grid(VoxelObject.to_local(hit.position))
#				var mirrors = grid_to_mirrors(grid_pos)
#				update_cursors(grid_pos)
#				if event.button_mask == BUTTON_MASK_RIGHT: pass
#				elif event is InputEventMouseMotion and not event.is_pressed(): return true
#				elif event is InputEventMouseButton:
#					if event.button_index == BUTTON_LEFT:
#						if event.is_pressed():
#							if ToolMode == ToolModes.INDIVIDUAL:
#								use_tool(mirrors.values())
#							elif ToolMode == ToolModes.AREA:
#								cursors_started_area = true
#							else: return false
#						else:
#							if ToolMode == ToolModes.AREA:
#								cursors_started_area = false
#								cursors_are_selecting_area = false
#
#								var grids := []
#								for mirror_index in mirrors:
#									grids += Cursors[mirror_index].selected_grids()
#								use_tool(grids)
#							else: return false
#
#						set_floor_visible(FloorConstant or (VoxelObject and not VoxelObject.mesh))
#						return true
#	if not event is InputEventKey: update_cursors(null)
#	set_floor_visible(FloorConstant or (VoxelObject and not VoxelObject.mesh))
#	return false
