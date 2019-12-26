tool
extends Reference
class_name Voxel, 'res://addons/Voxel-Core/assets/Voxel.png'



#
# Voxel:
# Every Voxel is a Dictionary, not every Dictionary is a Voxel
# Voxels are represented with Dictionaries, and by following a strict schema, defined below, we can create a wide variety of Voxels
# When getting and setting data of a Voxel it's best to make use of the helper function provided in this class, so as to avoid issues
# NOTE: Modifications to the Voxel schema can be done, but should be done in such a way that the original schema is unmodified, so as to avoid issues
#
# Schema:
# {
#    color      :   Color        =   Color(0, 0, 0),       #   Main albedo color, typically used when individual albedo colors aren't present
#    colors     :   Dictionary   =   {}, ::                #   Individual albedo colors, used to define an individual albedo color for any and all Voxel faces
#       {
#          Vector3.UP        :   Color     =   null || color,
#          Vector3.DOWN      :   Color     =   null || color,
#          Vector3.RIGHT     :   Color     =   null || color,
#          Vector3.LEFT      :   Color     =   null || color,
#          Vector3.BACK      :   Color     =   null || color,
#          Vector3.FORWARD   :   Color     =   null || color
#       }
#    texture    :   Vector2      =   null,                 #   Main texture position, typically used when individual texture positions and individual albedo colros aren't present
#    textures   :   Dictionary   =   {}, ::                #   Individual texture positions, used to define an individual texture position for any and all Voxel faces
#       {
#          Vector3.UP        :   Vector2   =   null || texture,
#          Vector3.DOWN      :   Vector2   =   null || texture,
#          Vector3.RIGHT     :   Vector2   =   null || texture,
#          Vector3.LEFT      :   Vector2   =   null || texture,
#          Vector3.BACK      :   Vector2   =   null || texture,
#          Vector3.FORWARD   :   Vector2   =   null || texture
#       }
#    data       :   Dictionary   =   {}                    #   Custom data, any and all user defined data should be placed here so as to avoid issues
# }
#
# Example:
# {
#    color      :   Color(0.6, 0.12, 1),
#    colors     :   {
#       Vector3.FORWARD   :   Color(0, 0.33, 0.11),
#       Vector3.DOWN      :   Color(1, 0.6, 0),
#       Vector3.BACK      :   Color(0.13, 0.75, 0.45)
#    },
#    texture    : Vector2(2, 3),
#    textures   :   {
#       Vector.DOWN       :   Vector2(0, 1),
#       Vector.RIGHT      :   Vector2(3, 3)
#    },
#    data       :   {
#       custom            :   3,
#       data              :   'wow'
#    }
# }
#



# Static Declarations
const VoxelScale : float = 1.0                             # Global Voxel scale
const VoxelSize : float = VoxelScale  * 0.25               # Global actual Voxel size
const GridStep : float = 0.25 * (VoxelSize / 0.125)        # Global distance between Voxels
const GridCorrection : float = 0.25 * (VoxelSize / 0.25)   # Global correction between Voxels; for when and if the grid breaks



# Core
# Transforms world space position to snapped position
# abs_pos    :   Vector3   -   world position to be transformed
# @returns   :   Vector3   -   given world position to snapped position
#
# Example:
#   abs_to_pos(Vector3(20, 0.312, -4.6543))   ->   Vector3(10, 0.25, -2.25)
#
static func abs_to_pos(abs_pos : Vector3) -> Vector3: return (abs_pos / GridStep).floor() * GridStep

# Transforms world space position to grid position
# grid       :   Vector3   -   world position to be transformed
# @returns   :   Vector3   -   given world position transformed to grid position
#
# Example:
#   abs_to_grid(Vector3(20, 0.312, -4.6543))   ->   Vector3(20, 1, -4.5)
#
static func abs_to_grid(abs_pos : Vector3) -> Vector3: return pos_to_grid(abs_to_pos(abs_pos))

# Transforms snapped position to grid position
# pos        :   Vector3   -   snapped position to be transformed
# @returns   :   Vector3   -   given snapped position transformed to grid position
#
# Example:
#   pos_to_grid(Vector3(1, 0, -0.75))   ->   Vector3(2, 0, -0.5)
#
static func pos_to_grid(pos : Vector3) -> Vector3: return pos / GridStep

# Corrects snapped position
# grid       :   Vector3   -   snapped position to be corrected
# @returns   :   Vector3   -   given snapped position corrected
#
# Example:
#   pos_correct(Vector3(3, 0, -3))   ->   Vector3(3.5, 0, -3.5)
#
static func pos_correct(pos : Vector3) -> Vector3: return pos + Vector3(GridCorrection, GridCorrection, GridCorrection)

# Transforms grid position to snapped position
# grid       :   Vector3   -   grid position to be transformed
# @returns   :   Vector3   -   given grid position transformed to snapped position
#
# Example:
#   grid_to_pos(Vector3(3, 0, -3))   ->   Vector3(1, 0, -0.75)
#
static func grid_to_pos(grid : Vector3) -> Vector3: return grid * GridStep


# Returns Vector3 clamped the given range
# grid       :   Vector3   -   Vector3 to be clamped
# _min       :   Vector3   -   minimum values
# _max       :   Vector3   -   maximum values
# @returns   :   Vector3   -   Vector3 clamped to given range
#
# Example:
#   vec3_clamp(Vector3(12, -3, -21), Vector3(-6, -3, 5), Vector3(23, -1, 32))   ->   Vector3(12, -3, 5)
#
static func vec3_clamp(vec3 : Vector3, _min : Vector3 = Vector3(), _max : Vector3 = Vector3()) -> Vector3:
	return Vector3(clamp(vec3.x, -_min.x, _max.x - 1), clamp(vec3.y, -_min.y, _max.y - 1), clamp(vec3.z, -_min.z, _max.z - 1))


# Helper function for quick 'basic Voxel' creation
# data       :   Dictionary   -   user defined data
# @returns   :   Dictionary   -   basic Voxel; NOTE: contains only necessary information
#
# Example:
#   basic()          ->   {}
#   basic({})        ->   {}
#   basic({ ... })   ->   { data: { ... } }
#
static func basic(data : Dictionary = {}) -> Dictionary:
	var basic = {}
	
	if not data.empty(): basic['data'] = data
	
	return basic


# Helper function for getting 'data' of given Voxel
# voxel      :   Dictionary   -   Voxel to get value from
# @returns   :   Dictionary   -   requested value, if found and valid; else, default value
#
# Example:
#   get_data({ ... })   ->   { ... }
#
static func get_data(voxel : Dictionary) -> Dictionary:
	return voxel['data'] if typeof(voxel.get('data')) == TYPE_DICTIONARY else {}

# Helper function for setting 'data' of given Voxel
# voxel   :   Dictionary   -   Voxel to modify
# data    :   Dictionary   -   value to set to given Voxel
#
# Example:
#   set_data({ ... }, { ... })
#
static func set_data(voxel : Dictionary, data : Dictionary) -> void:
	voxel['data'] = data


# Helper function for quick 'colored Voxel' creation
# color      :   Color                        -   main albedo color used by Voxel
# colors     :   Dictioanry<Vector3, Color>   -   albedo colors to specific sides
# data       :   Dictionary                   -   user defined data
# @returns   :   Dictionary                   -   colored Voxel; NOTE: contains only necessary information
#
# Example:
#   colored([Color])                                                 ->   { 'color': [Color] }
#   colored([Color], { Vector.UP : Color(0.3, 0, 0.66) })            ->   { data: { ... }, 'colors': { Vector.UP : Color(0.3, 0, 0.66) } }
#   colored([Color], { Vector.UP : Color(0.3, 0, 0.66) }, { ... })   ->   { data: { ... }, 'colors': { Vector.UP : Color(0.3, 0, 0.66) }, 'color': [Color] }
#
static func colored(color : Color, colors : Dictionary = {}, data : Dictionary = {}) -> Dictionary:
	var colored = basic(data)
	
	if not color == Color(): set_color(colored, color)
	for side in colors: if typeof(side) == TYPE_VECTOR3 and typeof(colors[side]) == TYPE_COLOR: set_color_side(colored, side, colors[side])
	
	return colored


# Helper function for retrieving 'color' of given Voxel
# voxel      :   Dictionary   -   Voxel to get value from
# @returns   :   Color        -   requested value, if found and valid; else, default value
#
# Example:
#   get_color({ ... })   ->   [Color]
#
static func get_color(voxel : Dictionary) -> Color:
	return voxel['color'] if typeof(voxel.get('color')) == TYPE_COLOR else Color()

# Helper function for setting 'color', all-around, of given Voxel
# voxel   :   Dictionary   -   Voxel to modify
# color   :   Color        -   value to set to given Voxel
#
# Example:
#   set_color({ ... }, [Color])
#
static func set_color(voxel : Dictionary, color : Color) -> void:
	voxel['color'] = color

# Helper function for retrieving Color of given side from given Voxel
# voxel      :   Dictionary   -   Voxel to get value from
# side       :   Vector3      -   normal of face to get from
# @returns   :   Color        -   requested value, if found and valid; else, default value
#
# Example:
#   get_color_side({ ... }, Vector.UP)   ->   [Color]
#
static func get_color_side(voxel : Dictionary, side : Vector3) -> Color:
	return voxel['colors'][side] if typeof(voxel.get('colors')) == TYPE_DICTIONARY and typeof(voxel['colors'].get(side)) == TYPE_COLOR else get_color(voxel)

# The following are helper functions for quick retrieving of the albedo color for specific sides
# voxel      :   Dictionary   -   Voxel to get value from
# @returns   :   Color        -   requested value, if found and valid; else, default value
#
# Example:
#   get_color_right({ ... })   ->   [Color]
#
static func get_color_right(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.RIGHT)
static func get_color_left(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.LEFT)
static func get_color_up(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.UP)
static func get_color_down(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.DOWN)
static func get_color_back(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.BACK)
static func get_color_forward(voxel : Dictionary) -> Color: return get_color_side(voxel, Vector3.FORWARD)

# Helper function for setting Color for given side from given Voxel
# voxel   :   Dictionary   -   Voxel to modify
# side    :   Vector3      -   normal of face to set
# color   :   Color        -   value to set to given Voxel side
#
# Example:
#   set_color_side({ ... }, Vector.RIGHT, [Color])
#
static func set_color_side(voxel : Dictionary, side : Vector3, color : Color) -> void:
	if not typeof(voxel.get('colors')) == TYPE_DICTIONARY: voxel['colors'] = {}
	voxel['colors'][side] = color

# The following are helper functions for quick setting of the albedo color to specific sides
# voxel   :   Dictionary   -   Voxel to modify
# color   :   Color        -   value to set to Voxel side
#
# Example:
#   set_color_down({ ... }, [Color])
#
static func set_color_right(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.RIGHT, color)
static func set_color_left(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.LEFT, color)
static func set_color_up(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.UP, color)
static func set_color_down(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.DOWN, color)
static func set_color_back(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.BACK, color)
static func set_color_forward(voxel : Dictionary, color : Color) -> void: set_color_side(voxel, Vector3.FORWARD, color)


# Helper function for quick 'textured Voxel' creation
# texture_position   :   Vector2                        -   position of main texture
# textures           :   Dictioanry<Vector3, Vector2>   -   texture positions for specific sides
# color              :   Color                          -   main albedo color used by Voxel
# colors             :   Dictioanry<Vector3, Color>     -   albedo colors to specific sides
# data               :   Dictionary                     -   user defined data
# @returns           :   Dictionary                     -   textured Voxel; NOTE: contains only necessary information
#
# Example:
#   textured([Vector2])                                                    ->   { 'color': Color(0, 0, 0), 'texture': [Vector2] }
#   textured([Vector2], { Vector.UP : Vector2(0, 3) }, [Color], { ... })   ->   { 'data': { ... }, 'color': [Color], 'texture': [Vector2], 'textures': { Vector.UP : Vector2(0, 3) } }
#
static func textured(texture_position : Vector2, textures : Dictionary, color : Color = Color(), colors : Dictionary = {}, data : Dictionary = {}) -> Dictionary:
	var textured = colored(color, colors, data)
	
	set_texture(textured, texture_position)
	for side in textures: if typeof(side) == TYPE_VECTOR3 and typeof(textures[side]) == TYPE_VECTOR2: set_texture_side(textured, side, textures[side])
	
	return textured


# Helper function for retrieving 'main texture position' of given Voxel
# voxel      :   Dictionary   -   Voxel to get value from
# @returns   :   Vector2      -   requested value, if found and is valid; else, default value
#
# Example:
#   get_texture({ ... })   ->   [Vector2]
#
static func get_texture(voxel : Dictionary) -> Vector2:
	return voxel['texture'] if typeof(voxel.get('texture')) == TYPE_VECTOR2 else null

# Helper function for setting 'main texture position' of given Voxel
# voxel              :   Dictionary   -   Voxel to modify
# texture_position   :   Vector2      -   value to set
#
# Example:
#   set_texture({ ... }, [Vector2])
#
static func set_texture(voxel : Dictionary, texture_position : Vector2) -> void:
	voxel['texture'] = texture_position

# Helper function for retrieving 'texture', of given side, for given Voxel
# voxel      :   Dictionary   -   Voxel to get value from
# side       :   Vector3      -   normal of face to get from
# @returns   :   Vector2      -   requested value, if found and is valid; else, default value
#
# Example:
#   get_texture_side({ ... }, Vector.UP)   ->   [Vector2]
#
static func get_texture_side(voxel : Dictionary, side : Vector3) -> Vector2:
	return voxel['textures'][side] if typeof(voxel.get('textures')) == TYPE_DICTIONARY and typeof(voxel['textures'].get(side)) == TYPE_VECTOR2 else get_texture(voxel)

# The following are helper functions for quick retrieving of the texture position for specific sides
# voxel      :   Dictionary   -   Voxel to retrieve value from
# @returns   :   Vector2      -   requested value, if found and is valid; else, default value
#
# Example:
#   get_texture_right({ ... })   ->   [Vector2]
#
static func get_texture_right(voxel : Dictionary) -> Vector2: return get_texture_side(voxel, Vector3.RIGHT)
static func get_texture_left(voxel : Dictionary) -> Vector2: return get_texture_side(voxel, Vector3.LEFT)
static func get_texture_up(voxel : Dictionary) -> Vector2: return get_texture_side(voxel, Vector3.UP)
static func get_texture_down(voxel : Dictionary) -> Vector2: return get_texture_side(voxel, Vector3.DOWN)
static func get_texture_back(voxel : Dictionary) -> Vector2: return get_texture_side(voxel, Vector3.BACK)
static func get_texture_forward(voxel : Dictionary) -> Vector2: return get_texture_side(voxel, Vector3.FORWARD)

# Helper function for setting 'texture position', to given side, for given Voxel
# voxel              :   Dictionary   -   Voxel to modify
# side               :   Vector3      -   normal of face to set
# texture_position   :   Vector2      -   value to set
#
# Example:
#   set_texture_side({ ... }, Vector.RIGHT, [Vector2])
#
static func set_texture_side(voxel : Dictionary, side : Vector3, texture_position : Vector2) -> void:
	if not typeof(voxel.get('textures')) == TYPE_DICTIONARY: voxel['textures'] = {}
	voxel['textures'][side] = texture_position

# The following are helper functions for quick setting of texture position to specific sides
# voxel              :   Dictionary     -   Voxel to modify
# texture_position   :   Vector2        -   value to set
#
# Example:
#   set_texture_left({ ... }, [Vector2])
#
static func set_texture_right(voxel : Dictionary, texture_position : Vector2) -> void: set_texture_side(voxel, Vector3.RIGHT, texture_position)
static func set_texture_left(voxel : Dictionary, texture_position : Vector2) -> void: set_texture_side(voxel, Vector3.LEFT, texture_position)
static func set_texture_up(voxel : Dictionary, texture_position : Vector2) -> void: set_texture_side(voxel, Vector3.UP, texture_position)
static func set_texture_down(voxel : Dictionary, texture_position : Vector2) -> void: set_texture_side(voxel, Vector3.DOWN, texture_position)
static func set_texture_back(voxel : Dictionary, texture_position : Vector2) -> void: set_texture_side(voxel, Vector3.BACK, texture_position)
static func set_texture_forward(voxel : Dictionary, texture_position : Vector2) -> void: set_texture_side(voxel, Vector3.FORWARD, texture_position)


# The following are helper functions used to generate Voxel faces
# st        :   SurfaceTool   -   SurfaceTool to work with
# voxel     :   Dictionary    -   Voxel data
# g1        :   Vector3       -   Voxels starting vertex position, as a grid position
# g2        :   Vector3       -   Voxels second vertex position, as a grid position; uses Voxels starting position if not given
# g3        :   Vector3       -   Voxels third vertes position, as a grid position; uses Voxels starting position if not given
# g4        :   Vector3       -   Voxels last vertex position, as a grid position; uses Voxels starting position if not given
#
# Example:
#   generate_up([SurfaceTool], [Voxel], Vector(1, 2))
#   generate_right([SurfaceTool], [Voxel], Vector(1,2), Vector(3,2), null, Vector(4, -3))
#
static func generate_right(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null) -> void:
	st.add_normal(Vector3.RIGHT)
	st.add_color(get_color_right(voxel))
	
	st.add_vertex(grid_to_pos(g1 + Vector3.RIGHT))
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))
	
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))

static func generate_left(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null) -> void:
	st.add_normal(Vector3.LEFT)
	st.add_color(get_color_left(voxel))
	
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.UP + Vector3.BACK))
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))
	
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_vertex(grid_to_pos(g1))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))

static func generate_up(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null) -> void:
	st.add_normal(Vector3.UP)
	st.add_color(get_color_up(voxel))
	
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.UP + Vector3.BACK))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))
	
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.UP + Vector3.BACK))
	
	st.add_vertex(grid_to_pos(g1 + Vector3.UP))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))

static func generate_down(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null) -> void:
	st.add_normal(Vector3.DOWN)
	st.add_color(get_color_down(voxel))
	
	st.add_vertex(grid_to_pos(g1))
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT))
	
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT))

static func generate_back(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null) -> void:
	st.add_normal(Vector3.BACK)
	st.add_color(get_color_back(voxel))
	
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP + Vector3.BACK))
	
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_vertex(grid_to_pos(g1 + Vector3.BACK))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP + Vector3.BACK))

static func generate_forward(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null) -> void:
	st.add_normal(Vector3.FORWARD)
	st.add_color(get_color_forward(voxel))
	
	st.add_vertex(grid_to_pos(g1))
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))
	
	
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT))
	
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.RIGHT + Vector3.UP))
	
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))

# The following is a helper functions used to generate Voxel
# direction   :   Vector3       -   Normal of face to generate
# st          :   SurfaceTool   -   SurfaceTool to work with
# voxel       :   Dictionary    -   Voxel data
# g1          :   Vector3       -   Voxels starting vertex position, as a grid position
# g2          :   Vector3       -   Voxels second vertex position, as a grid position; uses Voxels starting position if not given
# g3          :   Vector3       -   Voxels third vertes position, as a grid position; uses Voxels starting position if not given
# g4          :   Vector3       -   Voxels last vertex position, as a grid position; uses Voxels starting position if not given
#
# Example:
#   generate_side(Vector3.LEFT, [SurfaceTool], [Voxel], Vector(1, 2))
#   generate_side(Vector3.RIGHT, [SurfaceTool], [Voxel], Vector(1,2), Vector(3,2), null, Vector(4, -3))
#
static func generate_side(direction : Vector3, st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null) -> void:
	match direction:
		Vector3.RIGHT: generate_right(st, voxel, g1, g2, g3, g4)
		Vector3.LEFT: generate_left(st, voxel, g1, g2, g3, g4)
		Vector3.UP: generate_up(st, voxel, g1, g2, g3, g4)
		Vector3.DOWN: generate_down(st, voxel, g1, g2, g3, g4)
		Vector3.BACK: generate_back(st, voxel, g1, g2, g3, g4)
		Vector3.FORWARD: generate_forward(st, voxel, g1, g2, g3, g4)


# The following are helper functions used to generate a Voxel's face with UV mapping
# st        :   SurfaceTool   -   SurfaceTool to work with
# voxel     :   Dictionary    -   Voxel data
# g1        :   Vector3       -   Voxels starting vertex position, as a grid position
# g2        :   Vector3       -   Voxels second vertex position, as a grid position; uses Voxels starting position if not given
# g3        :   Vector3       -   Voxels third vertes position, as a grid position; uses Voxels starting position if not given
# g4        :   Vector3       -   Voxels last vertex position, as a grid position; uses Voxels starting position if not given
# uvscale   :   float         -   UV scale
#
# Example:
#   generate_up([SurfaceTool], [Voxel], Vector(1, 2))
#   generate_right([SurfaceTool], [Voxel], Vector(1,2), Vector(3,2), null, Vector(4, -3))
#   generate_right([SurfaceTool], [Voxel], Vector(1,2), Vector(3,2), null, Vector(4, -3), 0.13215)
#
static func generate_right_with_uv(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.RIGHT)
	st.add_color(get_color_right(voxel))
	var uv_position : Vector2 = get_texture_right(voxel)
	if uv_position == null: uv_position = Vector2(-1, -1)
	
	st.add_uv((uv_position + Vector2.ONE) * uvscale)
	st.add_vertex(grid_to_pos(g1 + Vector3.RIGHT))
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))
	
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_uv((uv_position) * uvscale)
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))

static func generate_left_with_uv(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.LEFT)
	st.add_color(get_color_left(voxel))
	var uv_position : Vector2 = get_texture_left(voxel)
	if uv_position == null: uv_position = Vector2(-1, -1)
	
	st.add_uv((uv_position) * uvscale)
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.UP + Vector3.BACK))
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))
	
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_uv((uv_position + Vector2.ONE) * uvscale)
	st.add_vertex(grid_to_pos(g1))
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))

static func generate_up_with_uv(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.UP)
	st.add_color(get_color_up(voxel))
	var uv_position : Vector2 = get_texture_up(voxel)
	if uv_position == null: uv_position = Vector2(-1, -1)
	
	st.add_uv((uv_position + Vector2.ONE) * uvscale)
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.UP + Vector3.BACK))
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))
	
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.UP + Vector3.BACK))
	
	st.add_uv((uv_position) * uvscale)
	st.add_vertex(grid_to_pos(g1 + Vector3.UP))
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))

static func generate_down_with_uv(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.DOWN)
	st.add_color(get_color_down(voxel))
	var uv_position : Vector2 = get_texture_down(voxel)
	if uv_position == null: uv_position = Vector2(-1, -1)
	
	st.add_uv((uv_position) * uvscale)
	st.add_vertex(grid_to_pos(g1))
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT))
	
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_uv((uv_position + Vector2.ONE) * uvscale)
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT))

static func generate_back_with_uv(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.BACK)
	st.add_color(get_color_back(voxel))
	var uv_position : Vector2 = get_texture_back(voxel)
	if uv_position == null: uv_position = Vector2(-1, -1)
	
	st.add_uv((uv_position) * uvscale)
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP + Vector3.BACK))
	
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_uv((uv_position + Vector2.ONE) * uvscale)
	st.add_vertex(grid_to_pos(g1 + Vector3.BACK))
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP + Vector3.BACK))

static func generate_forward_with_uv(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.FORWARD)
	st.add_color(get_color_forward(voxel))
	var uv_position : Vector2 = get_texture_forward(voxel)
	if uv_position == null: uv_position = Vector2(-1, -1)
	
	st.add_uv((uv_position + Vector2.ONE) * uvscale)
	st.add_vertex(grid_to_pos(g1))
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT))
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))
	
	
	st.add_uv((uv_position + Vector2.DOWN) * uvscale)
	st.add_vertex(grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT))
	
	st.add_uv((uv_position) * uvscale)
	st.add_vertex(grid_to_pos((g4 if g4 != null else g1) + Vector3.RIGHT + Vector3.UP))
	
	st.add_uv((uv_position + Vector2.RIGHT) * uvscale)
	st.add_vertex(grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))

# The following is a helper functions used to generate a Voxel's face with UV mapping
# direction   :   Vector3       -   Normal of face to generate
# st          :   SurfaceTool   -   SurfaceTool to work with
# voxel       :   Dictionary    -   Voxel data
# g1          :   Vector3       -   Voxels starting vertex position, as a grid position
# g2          :   Vector3       -   Voxels second vertex position, as a grid position; uses Voxels starting position if not given
# g3          :   Vector3       -   Voxels third vertes position, as a grid position; uses Voxels starting position if not given
# g4          :   Vector3       -   Voxels last vertex position, as a grid position; uses Voxels starting position if not given
# uvscale     :   float         -   UV scale
#
# Example:
#   generate_side_with_uv(Vector3.LEFT, [SurfaceTool], { ... }, Vector(1, 2))
#   generate_side_with_uv(Vector3.UP, [SurfaceTool], { ... }, Vector(1,2), Vector(3,2), null, Vector(4, -3))
#   generate_side_with_uv(Vector3.DOWN, [SurfaceTool], { ... }, Vector(1,2), Vector(3,2), null, Vector(4, -3), 0.23)
#
static func generate_side_with_uv(direction : Vector3, st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	match direction:
		Vector3.RIGHT: generate_right_with_uv(st, voxel, g1, g2, g3, g4, uvscale)
		Vector3.LEFT: generate_left_with_uv(st, voxel, g1, g2, g3, g4, uvscale)
		Vector3.UP: generate_up_with_uv(st, voxel, g1, g2, g3, g4, uvscale)
		Vector3.DOWN: generate_down_with_uv(st, voxel, g1, g2, g3, g4, uvscale)
		Vector3.BACK: generate_back_with_uv(st, voxel, g1, g2, g3, g4, uvscale)
		Vector3.FORWARD: generate_forward_with_uv(st, voxel, g1, g2, g3, g4, uvscale)


# Returns an Array of all position matching target relative to starting position.
# position   :   Vector3                                      -   Starting position
# target     :   int/String/Color                             -   Target searching for
# voxels     :   Dictionary<Vector3, int/String/Dictionary>   -   Voxels to search within NOTE: Voxels will be modified!
# @returns   :   Array<Vector3>                               -   Array containing all grid positions of matching Voxels
#
# Example:
#   flood_select(Vector3(-1, 2, 2), 33, { ... }) -> [ ... ]
#   flood_select(Vector3(-1, 2, 2), "black", { ... }) -> [ ... ]
#   flood_select(Vector3(-1, 2, 2), Color(1, 0, 0), { ... }) -> [ ... ]
#
static func flood_select(position : Vector3, target, voxels : Dictionary) -> Array:
	var selected := []
	var voxel = voxels.get(position)
	if (typeof(voxel) == TYPE_DICTIONARY and get_color(voxel) == target) if (not typeof(voxel) == TYPE_NIL and typeof(target) == TYPE_COLOR) else (str(voxel) == str(target)):
		selected.append(position)
		voxels.erase(position)
		
		selected += flood_select(position + Vector3.RIGHT, target, voxels)
		selected += flood_select(position + Vector3.LEFT, target, voxels)
		selected += flood_select(position + Vector3.UP, target, voxels)
		selected += flood_select(position + Vector3.DOWN, target, voxels)
		selected += flood_select(position + Vector3.BACK, target, voxels)
		selected += flood_select(position + Vector3.FORWARD, target, voxels)
	return selected
