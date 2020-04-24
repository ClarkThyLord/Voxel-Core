tool
extends Object
class_name Voxel, "res://addons/Voxel-Core/assets/classes/Voxel.png"



#
# Voxel, a static “helper” class, composed of everything relevant to voxels: 
# - quick voxel creation
# - quick voxel data retrieval
# - world, snapped and grid position conversion
#
# The Voxel Schema, every voxel is defined by a dictionary that follows the 
# schema defined below, following the schema you could create a wide variety 
# of voxels to fit your needs. Alterations can be done to the schema, but 
# should be done in such a way that retain the original structure so as 
# to avoid conflicts.
#
# {
# 	color		:	Color,
# 	colors		:	null || Dictionary = {
# 		Vector3.UP		:	null || Color,
# 		Vector3.DOWN	:	null || Color,
# 		Vector3.RIGHT	:	null || Color,
# 		Vector3.LEFT	:	null || Color,
# 		Vector3.FORWARD	:	null || Color,
# 		Vector3.BACK	:	null || Color
# 	},
# 	texture		:	null || Vector2,
# 	textures	:	null || Dictionary = {
# 		Vector3.UP		:	null || Vector2,
# 		Vector3.DOWN	:	null || Vector2,
# 		Vector3.RIGHT	:	null || Vector2,
# 		Vector3.LEFT	:	null || Vector2,
# 		Vector3.FORWARD	:	null || Vector2,
# 		Vector3.BACK	:	null || Vector2
# 	}
# }
#



# Declarations
# Voxel size used by default
const VoxelSize := 0.5



# Core
# Creates a colored voxel with the colors provided.
# color		:		Color					-		voxel's main color
# colors	:		Array<Vector3, Color>	-		voxel's individual side color
static func colored(color : Color, colors := {}) -> Dictionary:
	var voxel = {}
	voxel["color"] = color
	if colors.size() > 0: voxel["colors"] = colors.duplicate()
	return voxel

# Gets main color of given voxel if present, if not returns default transparent color
# voxel		:		Dictionary		-		dictionary representation of voxel
static func get_color(voxel : Dictionary) -> Color:
	return voxel.get("color", Color.transparent)

# Sets main color of given voxel
# voxel		:		Dictionary		-		dictionary representation of voxel
# color		:		Color			-		main color to set be set
static func set_color(voxel : Dictionary, color : Color) -> void:
	voxel["color"] = color

# Gets voxel's given side color if present, if not returns voxel's main color
# voxel		:		Dictionary		-		dictionary representation of voxel
# side		:		Vector3			-		side's normal
static func get_color_side(voxel : Dictionary, side : Vector3) -> Color:
	return voxel["colors"].get(side, get_color(voxel)) if voxel.has("colors") else get_color(voxel)

# Sets voxel's given side color
# voxel		:		Dictionary		-		dictionary representation of voxel
# side		:		Vector3			-		side's normal
# color		:		Color			-		color to set to given side
static func set_color_side(voxel : Dictionary, side : Vector3, color : Color) -> void:
	if not voxel.has("colors"): voxel["colors"] = {}
	voxel["colors"][side] = color


# Creates a textured voxel with the uvs provided.
# texture		:		Color					-		voxel's main texture uv
# textures	:		Array<Vector3, Vector2>		-		voxel's individual side texture uv
# color		:		Color						-		voxel's main color
# colors	:		Array<Vector3, Color>		-		voxel's individual side color
static func textured(texture : Vector2, textures := {}, color := Color.white, colors := {}) -> Dictionary:
	var voxel = colored(color, colors)
	voxel["texture"] = texture
	if textures.size() > 0: voxel["textures"] = textures
	return voxel

# Gets the main texture's uv of given voxel if present, if not returns a default negative uv
# voxel		:		Dictionary		-		dictionary representation of voxel
static func get_texture(voxel : Dictionary) -> Vector2:
	return voxel.get("texture", -Vector2.ONE)

# Sets main texture uv of given voxel
# voxel		:		Dictionary		-		dictionary representation of voxel
# texture	:		Vector2			-		main texture uv to set be set
static func set_texture(voxel : Dictionary, texture : Vector2) -> void:
	voxel["texture"] = texture

# Gets voxel's given side texture uv if present, if not returns voxel's texture uv
# voxel		:		Dictionary		-		dictionary representation of voxel
# side		:		Vector3			-		side's normal
static func get_texture_side(voxel : Dictionary, side : Vector3) -> Vector2:
	return voxel["textures"].get(side, get_texture(voxel)) if voxel.has("textures") else get_texture(voxel)

# Sets voxel's given side texture uv
# voxel		:		Dictionary		-		dictionary representation of voxel
# side		:		Vector3			-		side's normal
# texture	:		Vector2			-		texture uv to set to given side
static func set_texture_side(voxel : Dictionary, side : Vector3, texture : Vector2) -> void:
	if not voxel.has("textures"): voxel["textures"] = {}
	voxel["textures"][side] = texture


# Returns the given world position snapped to voxel grid.
# world		: Vector3		-		world position
static func world_to_snapped(world : Vector3) -> Vector3:
	return (world / VoxelSize).floor() * VoxelSize

# Returns the given snapped position as grid coordinates.
# snapped		: Vector3		-		snapped position
static func snapped_to_grid(snapped : Vector3) -> Vector3:
	return snapped / VoxelSize

# Returns the given world position as grid coordinates.
# world		: Vector3		-		snapped position
static func world_to_grid(world : Vector3) -> Vector3:
	return snapped_to_grid(world_to_snapped(world))

# Returns the given grid coordinates as snapped position.
# grid		: Vector3		-		snapped position
static func grid_to_snapped(grid : Vector3) -> Vector3:
	return grid * VoxelSize
