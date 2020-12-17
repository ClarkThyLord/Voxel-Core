tool
extends Object
class_name Voxel, "res://addons/Voxel-Core/assets/classes/Voxel.png"
# Utility class containing a collection of values and functions that 
# will help with the creation, manipulation and retrieval of voxel data.
#
# Voxel Schema:
# Every voxel is defined by its Dictionary that follows the schema defined below.
# Following the schema below you can create a wide variety of voxels to fit all 
# your needs. And while alterations can be performed to the schema, they should 
# be done in such a way that retains the original structure so as to avoid conflicts.
#
# {
#   vsn                  :   null || String,          ~   Stands for VoxelSetName, and is present when name is assigned to voxel in VoxelSet
#   color                :   Color,                   ~   Main and default color, Color, used by voxel for all faces
#   colors               :   null || Dictionary = {   ~   Colors used by voxel on a per face bases
#      Vector3.UP        :   null || Color,           ~   If present color will be used for voxel's UP face, otherwise fallbacks to color
#      Vector3.DOWN      :   null || Color,           ~   If present color will be used for voxel's DOWN face, otherwise fallbacks to color
#      Vector3.RIGHT     :   null || Color,           ~   If present color will be used for voxel's RIGHT face, otherwise fallbacks to color
#      Vector3.LEFT      :   null || Color,           ~   If present color will be used for voxel's LEFT face, otherwise fallbacks to color
#      Vector3.FORWARD   :   null || Color,           ~   If present color will be used for voxel's FORWARD face, otherwise fallbacks to color
#      Vector3.BACK      :   null || Color            ~   If present color will be used for voxel's BACK face, otherwise fallbacks to color
#   },
#   texture              :   null || Vector2,         ~   Main and default texture, Vector3, defining UV used by voxel for all faces
#   textures             :   null || Dictionary = {   ~   UVs used by voxel on a per face bases
#      Vector3.UP        :   null || Vector2,         ~   If present texture will be used for voxel's UP face, otherwise fallbacks to texture
#      Vector3.DOWN      :   null || Vector2,         ~   If present texture will be used for voxel's DOWN face, otherwise fallbacks to texture
#      Vector3.RIGHT     :   null || Vector2,         ~   If present texture will be used for voxel's RIGHT face, otherwise fallbacks to texture
#      Vector3.LEFT      :   null || Vector2,         ~   If present texture will be used for voxel's LEFT face, otherwise fallbacks to texture
#      Vector3.FORWARD   :   null || Vector2,         ~   If present texture will be used for voxel's FORWARD face, otherwise fallbacks to texture
#      Vector3.BACK      :   null || Vector2          ~   If present texture will be used for voxel's BACK face, otherwise fallbacks to texture
# 	}
# }
#



## Declarations
# Lists all possible 3D directions, and all adjacent directions to those
const Directions := {
	Vector3.RIGHT: [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ],
	Vector3.UP: [ Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK ],
	Vector3.FORWARD: [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ],
	Vector3.LEFT: [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ],
	Vector3.DOWN: [ Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK ],
	Vector3.BACK: [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ]
}

# Default voxel size, e.g. Vector(0.5, 0.5, 0.5)
const VoxelSize := 0.5



## Core
# Returns Dictionary representation of a colored voxel
# color    :   Color                        :   color to set
# colors   :   Dictionary<Vector3, Color>   :   face colors to set
# return   :   Dictionary<String, Variant>  :   Dictionary representing voxel
static func colored(color : Color, colors := {}) -> Dictionary:
	var voxel = {}
	voxel["color"] = color
	if colors.size() > 0: voxel["colors"] = colors.duplicate()
	return voxel

# Returns true if voxel has color defined
static func has_color(voxel : Dictionary) -> bool:
	return voxel.has("color")

# Returns the defined color within given voxel if present, otherwise returns transparent color
static func get_color(voxel : Dictionary) -> Color:
	return voxel.get("color", Color.transparent)

# Sets the given color in the given voxel
static func set_color(voxel : Dictionary, color : Color) -> void:
	voxel["color"] = color

# Returns true if voxel has specified color at given face
static func has_face_color(voxel : Dictionary, face : Vector3) -> bool:
	return voxel.has("colors") and voxel["colors"].has(face)

# Returns the defined color at given face if present, otherwise returns color
static func get_face_color(voxel : Dictionary, face : Vector3) -> Color:
	return voxel["colors"].get(face, get_color(voxel)) if voxel.has("colors") else get_color(voxel)

# Sets the given color to given face in the given voxel
static func set_face_color(voxel : Dictionary, face : Vector3, color : Color) -> void:
	if not voxel.has("colors"): voxel["colors"] = {}
	voxel["colors"][face] = color

# Removes color at given face from given voxel
static func remove_face_color(voxel : Dictionary, face : Vector3) -> void:
	if voxel.has("colors"):
		voxel["colors"].erase(face)
		if voxel["colors"].empty(): voxel.erase("colors")


# Returns Dictionary representation of a textured voxel
# texture    :   Vector2                        :   texture to set
# textures   :   Dictionary<Vector3, Vector2>   :   face texture to set
# color      :   Color                          :   color to set
# colors     :   Dictionary<Vector3, Color>     :   face colors to set
# return     :   Dictionary<String, Variant>    :   Dictionary representing voxel
static func textured(texture : Vector2, textures := {}, color := Color.white, colors := {}) -> Dictionary:
	var voxel = colored(color, colors)
	voxel["texture"] = texture
	if textures.size() > 0: voxel["textures"] = textures
	return voxel

# Returns true if voxel has texture defined
static func has_texture(voxel : Dictionary) -> bool:
	return voxel.has("texture")

# Returns the defined texture within given voxel if present, otherwise returns a negative vector
static func get_texture(voxel : Dictionary) -> Vector2:
	return voxel.get("texture", -Vector2.ONE)

# Sets the given texture in the given voxel
static func set_texture(voxel : Dictionary, texture : Vector2) -> void:
	voxel["texture"] = texture

# Removes texture from given voxel
static func remove_texture(voxel : Dictionary) -> void:
	voxel.erase("texture")

# Returns true if voxel has specified texture at given face
static func has_face_texture(voxel : Dictionary, face : Vector3) -> bool:
	return voxel.has("textures") and voxel["textures"].has(face)

# Returns the defined texture at given face if present, otherwise returns texture
static func get_face_texture(voxel : Dictionary, face : Vector3) -> Vector2:
	return voxel["textures"].get(face, get_texture(voxel)) if voxel.has("textures") else get_texture(voxel)

# Sets the given texture to given face in the given voxel
static func set_face_texture(voxel : Dictionary, face : Vector3, texture : Vector2) -> void:
	if not voxel.has("textures"): voxel["textures"] = {}
	voxel["textures"][face] = texture

# Removes texture at given face from given voxel
static func remove_face_texture(voxel : Dictionary, face : Vector3) -> void:
	if voxel.has("textures"):
		voxel["textures"].erase(face)
		if voxel["textures"].empty(): voxel.erase("textures")


# Returns a world position snapped to voxel grid
static func world_to_snapped(world : Vector3) -> Vector3:
	return (world / VoxelSize).floor() * VoxelSize

# Returns a snapped position rounded to voxel grid
static func snapped_to_grid(snapped : Vector3) -> Vector3:
	return snapped / VoxelSize

# Returns a world position rounded to voxel grid
static func world_to_grid(world : Vector3) -> Vector3:
	return snapped_to_grid(world_to_snapped(world))

# Returns a voxel grid position snapped to voxel grid
static func grid_to_snapped(grid : Vector3) -> Vector3:
	return grid * VoxelSize
