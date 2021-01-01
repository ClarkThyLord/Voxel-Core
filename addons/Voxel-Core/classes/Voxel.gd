tool
class_name Voxel, "res://addons/Voxel-Core/assets/classes/Voxel.png"
extends Object
# Utility class containing various properties and methods to do with voxels.
#
# Voxel Schema:
# Every voxel is a Dictionary, not every Dictionary is a voxel, only by following
# the voxel scheme indicated below can wide varieties of voxels be produced. 
# Note that voxel dictionaries may have additions, but they must be done in such
# a way as to respect the original structure so as to avoid conflicts.
#
# {
#   vsn                  :   String,          ~   VoxelSetName, used by VoxelSet to associate name with voxel
#   color                :   Color,           ~   Default color used for all voxel faces
#   colors               :   Dictionary = {   ~   Color used on a per face bases, if not present uses voxel color
#      Vector3.UP        :   Color,
#      Vector3.DOWN      :   Color,
#      Vector3.RIGHT     :   Color,
#      Vector3.LEFT      :   Color,
#      Vector3.FORWARD   :   Color,
#      Vector3.BACK      :   Color
#   },
#   uv                   :   Vector2,         ~   Default uv position used for all voxel faces
#   uvs                  :   Dictionary = {   ~   uv position used on a per face bases, if not present uses voxel uv
#      Vector3.UP        :   Vector2,
#      Vector3.DOWN      :   Vector2,
#      Vector3.RIGHT     :   Vector2,
#      Vector3.LEFT      :   Vector2,
#      Vector3.FORWARD   :   Vector2,
#      Vector3.BACK      :   Vector2
#   },
#   metallic             :   float,           ~   Metallic material value used for all voxel faces
#   specular             :   float,           ~   Specular material value used for all voxel faces
#   roughness            :   float,           ~   Roughness material value used for all voxel faces
#   energy               :   float            ~   Emission energy material value used for all voxel faces
# }
#



## Constants
# Lists of all voxel faces, and their adjacent directions
const Faces := {
	Vector3.RIGHT: [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ],
	Vector3.UP: [ Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK ],
	Vector3.FORWARD: [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ],
	Vector3.LEFT: [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ],
	Vector3.DOWN: [ Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK ],
	Vector3.BACK: [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ],
}

# 0.5 means that voxels will have the dimensions of 0.5 x 0.5 x 0.5
const VoxelWorldSize := 0.5



## Public Methods
# Returns Dictionary representation of a colored voxel
# color    :   Color                        :   color to set
# colors   :   Dictionary<Vector3, Color>   :   face colors to set
# return   :   Dictionary<String, Variant>  :   Dictionary representing voxel
static func colored(color : Color, colors := {}) -> Dictionary:
	var voxel = {}
	voxel["color"] = color
	if colors.size() > 0:
		voxel["colors"] = colors.duplicate()
	return voxel


# Returns true if voxel has color defined
static func has_color(voxel : Dictionary) -> bool:
	return voxel.has("color")


# Returns the defined color within given voxel if present, otherwise returns transparent color
static func get_color(voxel : Dictionary) -> Color:
	return voxel.get("color", Color.transparent)


# Sets the given color to the given voxel
static func set_color(voxel : Dictionary, color : Color) -> void:
	voxel["color"] = color


# Returns true if voxel has specified color at given face
static func has_face_color(voxel : Dictionary, face : Vector3) -> bool:
	return voxel.has("colors") and voxel["colors"].has(face)


# Returns the defined color at given face if present, otherwise returns color
static func get_face_color(voxel : Dictionary, face : Vector3) -> Color:
	return voxel["colors"].get(face, get_color(voxel)) if voxel.has("colors") else get_color(voxel)


# Sets the given color at the given face to the given voxel
static func set_face_color(voxel : Dictionary, face : Vector3, color : Color) -> void:
	if not voxel.has("colors"): voxel["colors"] = {}
	voxel["colors"][face] = color


# Removes color at given face from given voxel
static func remove_face_color(voxel : Dictionary, face : Vector3) -> void:
	if voxel.has("colors"):
		voxel["colors"].erase(face)
		if voxel["colors"].empty():
			voxel.erase("colors")


# Returns Dictionary representation of a uvd voxel
# uv         :   Vector2                        :   uv to set
# uvs        :   Dictionary<Vector3, Vector2>   :   face uv to set
# color      :   Color                          :   color to set
# colors     :   Dictionary<Vector3, Color>     :   face colors to set
# return     :   Dictionary<String, Variant>    :   Dictionary representing voxel
static func uvd(uv : Vector2, uvs := {}, color := Color.white, colors := {}) -> Dictionary:
	var voxel = colored(color, colors)
	voxel["uv"] = uv
	if uvs.size() > 0:
		voxel["uvs"] = uvs
	return voxel


# Returns true if voxel has uv defined
static func has_uv(voxel : Dictionary) -> bool:
	return voxel.has("uv")


# Returns the defined uv within given voxel if present, otherwise returns a negative vector
static func get_uv(voxel : Dictionary) -> Vector2:
	return voxel.get("uv", -Vector2.ONE)


# Sets the given uv to the given voxel
static func set_uv(voxel : Dictionary, uv : Vector2) -> void:
	voxel["uv"] = uv


# Removes uv from given voxel
static func remove_uv(voxel : Dictionary) -> void:
	voxel.erase("uv")


# Returns true if voxel has specified uv at given face
static func has_face_uv(voxel : Dictionary, face : Vector3) -> bool:
	return voxel.has("uvs") and voxel["uvs"].has(face)


# Returns the defined uv at given face if present, otherwise returns uv
static func get_face_uv(voxel : Dictionary, face : Vector3) -> Vector2:
	return voxel["uvs"].get(face, get_uv(voxel)) if voxel.has("uvs") else get_uv(voxel)


# Sets the given uv at the given face to the given voxel
static func set_face_uv(voxel : Dictionary, face : Vector3, uv : Vector2) -> void:
	if not voxel.has("uvs"):
		voxel["uvs"] = {}
	voxel["uvs"][face] = uv


# Removes uv at given face from given voxel
static func remove_face_uv(voxel : Dictionary, face : Vector3) -> void:
	if voxel.has("uvs"):
		voxel["uvs"].erase(face)
		if voxel["uvs"].empty():
			voxel.erase("uvs")


# Returns the defined metallic within given voxel if present, otherwise returns 0
static func get_metallic(voxel : Dictionary) -> float:
	return voxel.get("metallic", 0)


# Sets the given metallic to the given voxel
static func set_metallic(voxel : Dictionary, metallic : float) -> void:
	voxel["metallic"] = metallic


# Removes metallic from given voxel
static func remove_metallic(voxel : Dictionary) -> void:
	voxel.erase("metallic")


# Returns the defined specular within given voxel if present, otherwise returns 0.5
static func get_specular(voxel : Dictionary) -> float:
	return voxel.get("specular", 0.5)


# Sets the given specular to the given voxel
static func set_specular(voxel : Dictionary, specular : float) -> void:
	voxel["specular"] = specular


# Removes specular from given voxel
static func remove_specular(voxel : Dictionary) -> void:
	voxel.erase("specular")


# Returns the defined roughness within given voxel if present, otherwise returns 1
static func get_roughness(voxel : Dictionary) -> float:
	return voxel.get("roughness", 1)


# Sets the given roughness to the given voxel
static func set_roughness(voxel : Dictionary, roughness : float) -> void:
	voxel["roughness"] = roughness


# Removes roughness from given voxel
static func remove_roughness(voxel : Dictionary) -> void:
	voxel.erase("roughness")


# Returns the defined energy within given voxel if present, otherwise returns 0
static func get_energy(voxel : Dictionary) -> float:
	return voxel.get("energy", 0)


# Sets the given energy to the given voxel
static func set_energy(voxel : Dictionary, energy : float) -> void:
	voxel["energy"] = energy


# Removes energy from given voxel
static func remove_energy(voxel : Dictionary) -> void:
	voxel.erase("energy")


# Returns the world position as snapped world position
static func world_to_snapped(world : Vector3) -> Vector3:
	return (world / VoxelWorldSize).floor() * VoxelWorldSize


# Returns the snapped world position as voxel grid position
static func snapped_to_grid(snapped : Vector3) -> Vector3:
	return snapped / VoxelWorldSize


# Returns world position as voxel grid position
static func world_to_grid(world : Vector3) -> Vector3:
	return snapped_to_grid(world_to_snapped(world))


# Returns voxel grid position as snapped world position
static func grid_to_snapped(grid : Vector3) -> Vector3:
	return grid * VoxelWorldSize
