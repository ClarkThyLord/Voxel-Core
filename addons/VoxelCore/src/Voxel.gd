extends Reference
class_name Voxel, 'res://addons/VoxelCore/assets/Voxel.png'



# Static Declarations
const VoxelUnit : int = 1 # Scale units of voxels
const VoxelSize : float = VoxelUnit  * 0.25 # Scales voxel's size for all voxelobjects
const GridStep : float = 0.25 * (VoxelSize / 0.125) # The diffrence between voxels
const GridCorrection : float = 0.25 * (VoxelSize / 0.25) # Correction between voxels; for when and if the grid breaks



# Core
#
# Voxel Schema
# {
#    cost : float = 0.0,
#    editor : bool = Engine.editor_hint,
#    color : Color = Color,
#    colors : Dictionary = {}, ::
#       {
#          'up' : Color,
#          'down' : Color,
#          'up' : Color,
#          'left' : Color,
#          'forward' : Color,
#          'back' : Color,
#       }
#  * texture : Texture,
#  * textures : Dictionary = {}, ::
#  *    {
#  *       'up' : Texture,
#  *       'down' : Texture,
#  *       'down' : Texture,
#  *       'left' : Texture,
#  *       'forward' : Texture,
#  *       'back' : Texture,
#  *    }
#    data : Dictionary = {}
# }
#

# Helper function for quick basic Voxel(Dictionary) creation
# data       :   Dictionary   -   user defined data
# cost       :   float        -   cost of Voxel
# editor     :   bool         -   whether Voxel is created by editor
# @returns   :   Dictionary   -   basic Voxel; NOTE: contains only necessary information
#
# Example:
#   basic({ ... }, 10.3, false) -> { 'editor': false, 'cost': 10.3, data: { ... } }
#
static func basic(data : Dictionary = {}, cost : float = 0.0, editor : bool = Engine.editor_hint) -> Dictionary:
	var basic = {
		'editor' : editor
	}
	
	if cost != 0: basic['cost'] = cost
	if not data.empty(): basic['data'] = data
	
	return basic

# Helper function for retrieving 'cost' of given Voxel
# voxel      :   Dictionary   -   Voxel to handle
# @returns   :   float        -   cost of Voxel, if found and is valid; else default value
#
# Example:
#   get_cost([Voxel]) -> 36.33
#
static func get_cost(voxel : Dictionary) -> float:
	return voxel['cost'] if voxel.get('cost') is int else 0.0

# Helper function for setting 'cost' of given Voxel
# voxel   :   Dictionary   -   Voxel to modify
# cost    :   float        -   cost to set to given Voxel
#
# Example:
#   set_cost([Voxel], -0.1)
#
static func set_cost(voxel : Dictionary, cost : float = 0) -> void:
	voxel['cost'] = cost

# Helper function for retrieving 'editor' of given Voxel
# voxel      :   Dictionary   -   Voxel to handle
# @returns   :   bool         -   editor of Voxel, if found and is valid; else default value
#
# Example:
#   get_editor([Voxel]) -> false
#
static func get_editor(voxel : Dictionary) -> bool:
	return voxel['editor'] if voxel.get('editor') is bool else Engine.editor_hint

# Helper function for setting 'editor' of given Voxel
# voxel    :   Dictionary   -   Voxel to modify
# editor   :   bool         -   editor to set to given Voxel
#
# Example:
#   set_editor([Voxel], true)
#
static func set_editor(voxel : Dictionary, editor : bool = Engine.editor_hint) -> void:
	voxel['editor'] = editor

# Helper function for retrieving 'data' of given Voxel
# voxel      :   Dictionary   -   Voxel to handle
# @returns   :   Dictionary   -   data of Voxel, if found and is valid; else default value
#
# Example:
#   get_data([Voxel]) -> { ... }
#
static func get_data(voxel : Dictionary) -> Dictionary:
	return voxel['data'] if voxel.get('data') is Dictionary else {}

# Helper function for setting 'data' of given Voxel
# voxel   :   Dictionary   -   Voxel to modify
# data    :   Dictionary   -   data to set to given Voxel
#
# Example:
#   set_data([Voxel], { ... })
#
static func set_data(voxel : Dictionary, data : Dictionary) -> void:
	voxel['data'] = data


# Helper function for quick colored Voxel(Dictionary) creation
# color      :   Color        -   color used by Voxel on render; all-around
# data       :   Dictionary   -   user defined data
# cost       :   float        -   cost of Voxel
# editor     :   bool         -   whether Voxel is created by editor
# @returns   :   Dictionary   -   colored Voxel; NOTE: contains only necessary information
#
# Example:
#   colored([Color], { ... }, -1.0, false) -> { 'editor': false, 'cost': -1.0, data: { ... }, 'color': [Color] }
#
static func colored(color : Color, data : Dictionary = {}, cost : float = 0.0, editor : bool = Engine.editor_hint) -> Dictionary:
	var colored = basic(data, cost, editor)
	
	colored['color'] = color
	
	return colored


# Helper function for retrieving 'color', all-around, of given Voxel
# voxel      :   Dictionary   -   Voxel to handle
# @returns   :   Color        -   color of Voxel, if found and is valid; else default value
#
# Example:
#   get_color([Voxel]) -> [Color]
#
static func get_color(voxel : Dictionary) -> Color:
	return voxel['color'] if voxel.get('color') is Color else Color()

# Helper function for setting 'color', all-around, of given Voxel
# voxel   :   Dictionary   -   Voxel to modify
# color   :   Color        -   color to set to given Voxel
#
# Example:
#   set_color([Voxel], [Color])
#
static func set_color(voxel : Dictionary, color : Color = Color()) -> void:
	voxel['color'] = color

# Helper function for retrieving 'color', of given side, for given Voxel
# voxel      :   Dictionary   -   Voxel to handle
# side       :   Vector3       -   side to get color from
# @returns   :   Color        -   color of Voxel for given side, if found and is valid; else default value
#
# Example:
#   get_color_side([Voxel], 'down') -> [Color]
#
static func get_color_side(voxel : Dictionary, side : Vector3) -> Color:
	return voxel['colors'][side] if voxel.get('colors') is Dictionary and voxel['colors'].get(side) is Color else get_color(voxel)

# The following are helper functions for quick color get to specific sides
static func get_color_right(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.RIGHT)
static func get_color_left(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.LEFT)
static func get_color_up(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.UP)
static func get_color_down(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.DOWN)
static func get_color_back(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.BACK)
static func get_color_forward(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.FORWARD)

# Helper function for setting 'color', of given side, for given Voxel
# voxel   :   Dictionary   -   Voxel to modify
# side    :   Vector3       -   side to set color to
# color   :   Color        -   color to set to given Voxel
#
# Example:
#   set_color_side([Voxel], 'right', [Color])
#
static func set_color_side(voxel : Dictionary, side : Vector3, color : Color) -> void:
	if not voxel.has('colors'): voxel['colors'] = {}
	voxel['colors'][side] = color

# The following are helper functions for quick color set to specific sides
static func set_color_right(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.RIGHT, color)
static func set_color_left(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.LEFT, color)
static func set_color_up(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.UP, color)
static func set_color_down(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.DOWN, color)
static func set_color_back(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.BACK, color)
static func set_color_forward(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.FORWARD, color)


# Helper function for quick textured Voxel(Dictionary) creation
# texture    :   Texture      -   texture used by Voxel on render; all-around
# color      :   Color        -   color used by Voxel on render, used when texture fails to load; all-around
# data       :   Dictionary   -   user defined data
# cost       :   float        -   cost of Voxel
# editor     :   bool         -   whether Voxel is created by editor
# @returns   :   Dictionary   -   textured Voxel; NOTE: contains only necessary information
#
# Example:
#   textured([Texture], [Color], { ... }, -100.34, true) -> { 'editor': true, 'cost': -100.34, data: { ... }, 'color': [Color], 'texture': [Texture] }
#
#static func textured(texture : Texture, color : Color = Color(), data : Dictionary = {}, cost : float = 0.0, editor : bool = Engine.editor_hint) -> Dictionary:
#	var textured = colored(color, data, cost, editor)
#
#	texture['texture'] = texture
#
#	return textured


# PosType   :   ABS_POS, 0   -   world space position
# PosType   :   POS, 1       -   snapped position
# PosType   :   GRID, 2      -   grid position
enum PosType {ABS_POS, POS, GRID}
# Transforms world space position(Vector3) to snapped position(Vector3)
# grid       :   Vector3   -   world position to be transformed
# @returns   :   Vector3   -   given world position to snapped position
#
# Example:
#   abs_to_pos(Vector3(20, 0.312, -4.6543)) -> Vector3(10, 0.25, -2.25)
#
static func abs_to_pos(abs_pos : Vector3) -> Vector3:
	return (abs_pos / GridStep).floor() * GridStep

# Transforms world space position(Vector3) to grid position(Vector3)
# grid       :   Vector3   -   world position to be transformed
# @returns   :   Vector3   -   given world position transformed to grid position
#
# Example:
#   abs_to_grid(Vector3(20, 0.312, -4.6543)) -> Vector3(20, 1, -4.5)
#
static func abs_to_grid(abs_pos : Vector3) -> Vector3:
	return pos_to_grid(abs_to_pos(abs_pos))

# Transforms snapped position(Vector3) to grid position(Vector3)
# pos        :   Vector3   -   snapped position to be transformed
# @returns   :   Vector3   -   given snapped position transformed to grid position
#
# Example:
#   pos_to_grid(Vector3(1, 0, -0.75)) -> Vector3(2, 0, -0.5)
#
static func pos_to_grid(pos : Vector3) -> Vector3:
	return pos / GridStep

# Corrects snapped position(Vector3)
# grid       :   Vector3   -   snapped position to be corrected
# @returns   :   Vector3   -   given snapped position corrected
#
# Example:
#   pos_correct(Vector3(3, 0, -3)) -> Vector3(3.5, 0, -3.5)
#
static func pos_correct(pos : Vector3) -> Vector3:
	return pos + Vector3(GridCorrection, GridCorrection, GridCorrection)

# Transforms grid position(Vector3) to snapped position(Vector3)
# grid       :   Vector3   -   grid position to be transformed
# @returns   :   Vector3   -   given grid position transformed to snapped position
#
# Example:
#   grid_to_pos(Vector3(3, 0, -3)) -> Vector3(1, 0, -0.75)
#
static func grid_to_pos(grid : Vector3) -> Vector3:
	return grid * GridStep


# Returns whether that given grid(Vector3) is whithin given dimensions(Vector3)
# grid         :   Vector3   -   grid position to validate with
# dimensions   :   Vector3   -   dimensions to validate grid within
# @returns     :   bool      -   true, given grid position is within given dimensions; false, given grid position isn't within given dimensions
#
# Example:
#   grid_within_dimensions(Vector3(2, -6, 21), Vector3(6, 6, 6)) -> false
#
static func grid_within_dimensions(grid : Vector3, dimensions : Vector3) -> bool:
	return abs(grid.x) <= dimensions.x and abs(grid.y) <= dimensions.y and abs(grid.z) <= dimensions.z

# Returns given grid position(Vector3) within the given dimensions(Vector3)
# grid         :   Vector3   -   grid position to be clamped
# dimensions   :   Vector3   -   dimensions to clamp given grid position within
# @returns     :   Vector3   -   given grid position clamped within given dimensions
#
# Example:
#   clamp_grid(Vector3(12, -3, -21), Vector3(6, 2, -3)) -> Vector3(6, -2, -3)
#
static func clamp_grid(grid : Vector3, dimensions : Vector3) -> Vector3:
	return Vector3(clamp(grid.x, -dimensions.x, dimensions.x - 1), clamp(grid.y, -dimensions.y, dimensions.y - 1), clamp(grid.z, -dimensions.z, dimensions.z - 1))
