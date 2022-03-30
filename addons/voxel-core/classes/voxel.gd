tool
class_name Voxel, "res://addons/voxel-core/assets/classes/voxel.png"
extends Object
# Utility class containing various helpful static values and methods that have 
# to do with voxels.
#
# NOTE: As this is a utility class, it is not designed to be instantiated. 
# Instead, access all of its values and methods from anywhere like so:
#	for face in Voxel.FACES:
#		Voxel.get_face_color(..., face)
#
# Voxel-Core represents all voxels with dictionaries, however that doesn't mean
# that every dictionary is a voxel. Only when a dictionary follows the schema
# defined below is it a valid voxel. The voxel schema is intended to allow the
# creation of a wide variety of voxels, each with its own color,
# texture, material, and more.
#
# In addition, being as voxels are represented as dictionaries it allows you
# to easily extend their data structure. However, any extension must be done in
# such a way that it respects the original structure so as to avoid conflicts
# with the existing Voxel-Core logic.
#
# Voxel Schema:
# {
#   name                 :   String           ~   Lowercase string, used as identifier by VoxelSet
#   color                :   Color            ~   RGB color, default color used for all voxel faces
#   colors               :   Dictionary = {   ~   Dictionary, contains RGB Color values paired with their respective Vector2 voxel face key
#      Vector3.UP        :   Color
#      Vector3.DOWN      :   Color
#      Vector3.RIGHT     :   Color
#      Vector3.LEFT      :   Color
#      Vector3.FORWARD   :   Color
#      Vector3.BACK      :   Color
#   }
#   tile                 :   Vector2          ~   Vector2, default tile used for all the voxel faces
#   tiles                :   Dictionary = {   ~   tile position used on a per face bases, if not present fallback to voxel tile
#      Vector3.UP        :   Vector2
#      Vector3.DOWN      :   Vector2
#      Vector3.RIGHT     :   Vector2
#      Vector3.LEFT      :   Vector2
#      Vector3.FORWARD   :   Vector2
#      Vector3.BACK      :   Vector2
#   }
#   metallic             :   float            ~   Metallic value used for all voxel face's material, must be between 0.0 and 1.0 and if not present fallback is 0.0
#   specular             :   float            ~   Specular value used for all voxel faces, must be between 0.0 and 1.0 and if not present fallback is 0.5
#   roughness            :   float            ~   Roughness value used for all voxel faces, must be between 0.0 and 1.0 and if not present fallback is 1.0
#   energy               :   float            ~   Emission energy value used for all voxel faces, must be between 0.0 and 16.0 and if not present fallback is 0.0
#   energy_color         :   Color            ~   Emission color used for all voxel faces, if not present fallback is white
#   material             :   int              ~   ID of the VoxelSet material used for this voxel, if not present fallback is -1
# }



## Constants
# Lists of all voxel faces, and their adjacent directions
const FACES := {
	Vector3.RIGHT: [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ],
	Vector3.UP: [ Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK ],
	Vector3.FORWARD: [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ],
	Vector3.LEFT: [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ],
	Vector3.DOWN: [ Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK ],
	Vector3.BACK: [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ],
}



## Public Methods
# Returns dictionary representation of a colored voxel.
# color    :   Color                        :   color to set
# colors   :   Dictionary<Vector3, Color>   :   face colors to set
# return   :   Dictionary<String, Variant>  :   Dictionary representing voxel
static func colored(color : Color, colors := {}) -> Dictionary:
	var voxel = {}
	voxel["color"] = color
	if not colors.empty():
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


# Returns Dictionary representation of a tiled voxel
# tile         :   Vector2                        :   tile to set
# tiles        :   Dictionary<Vector3, Vector2>   :   face tile to set
# color      :   Color                          :   color to set
# colors     :   Dictionary<Vector3, Color>     :   face colors to set
# return     :   Dictionary<String, Variant>    :   Dictionary representing voxel
static func tiled(tile : Vector2, tiles := {}, color := Color.white, colors := {}) -> Dictionary:
	var voxel = colored(color, colors)
	voxel["tile"] = tile
	if not tiles.empty():
		voxel["tiles"] = tiles
	return voxel


# Returns true if voxel has tile defined
static func has_tile(voxel : Dictionary) -> bool:
	return voxel.has("tile")


# Returns the defined tile within given voxel if present, otherwise returns a negative vector
static func get_tile(voxel : Dictionary) -> Vector2:
	return voxel.get("tile", -Vector2.ONE)


# Sets the given tile to the given voxel
static func set_tile(voxel : Dictionary, tile : Vector2) -> void:
	voxel["tile"] = tile


# Removes tile from given voxel
static func remove_tile(voxel : Dictionary) -> void:
	voxel.erase("tile")


# Returns true if voxel has specified tile at given face
static func has_face_tile(voxel : Dictionary, face : Vector3) -> bool:
	return voxel.has("tiles") and voxel["tiles"].has(face)


# Returns the defined tile at given face if present, otherwise returns tile
static func get_face_tile(voxel : Dictionary, face : Vector3) -> Vector2:
	return voxel["tiles"].get(face, get_tile(voxel)) if voxel.has("tiles") else get_tile(voxel)


# Sets the given tile at the given face to the given voxel
static func set_face_tile(voxel : Dictionary, face : Vector3, tile : Vector2) -> void:
	if not voxel.has("tiles"):
		voxel["tiles"] = {}
	voxel["tiles"][face] = tile


# Removes tile at given face from given voxel
static func remove_face_tile(voxel : Dictionary, face : Vector3) -> void:
	if voxel.has("tiles"):
		voxel["tiles"].erase(face)
		if voxel["tiles"].empty():
			voxel.erase("tiles")


# Returns true if given name is valid
static func is_valid_name(name : String) -> bool:
	return not name.empty()


# Returns the defined name within given voxel if present, otherwise returns an empty string
static func get_name(voxel : Dictionary) -> String:
	return voxel.get("name", "")


# Sets the given name to the given voxel
static func set_name(voxel : Dictionary, name : String) -> void:
	voxel["name"] = name.to_lower()


# Removes name from given voxel
static func remove_name(voxel : Dictionary) -> void:
	voxel.erase("name")


# Returns the defined metallic within given voxel if present, otherwise returns 0
static func get_metallic(voxel : Dictionary) -> float:
	return voxel.get("metallic", 0.0)


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
	return voxel.get("roughness", 1.0)


# Sets the given roughness to the given voxel
static func set_roughness(voxel : Dictionary, roughness : float) -> void:
	voxel["roughness"] = roughness


# Removes roughness from given voxel
static func remove_roughness(voxel : Dictionary) -> void:
	voxel.erase("roughness")


# Returns the defined energy within given voxel if present, otherwise returns 0
static func get_energy(voxel : Dictionary) -> float:
	return voxel.get("energy", 0.0)


# Sets the given energy to the given voxel
static func set_energy(voxel : Dictionary, energy : float) -> void:
	voxel["energy"] = energy


# Removes energy from given voxel
static func remove_energy(voxel : Dictionary) -> void:
	voxel.erase("energy")


# Returns the defined energy_color within given voxel if present, otherwise returns Color.white
static func get_energy_color(voxel : Dictionary) -> Color:
	return voxel.get("energy_color", Color.white)


# Sets the given energy_color to the given voxel
static func set_energy_color(voxel : Dictionary, energy_color : Color) -> void:
	voxel["energy_color"] = energy_color


# Removes energy_color from given voxel
static func remove_energy_color(voxel : Dictionary) -> void:
	voxel.erase("energy_color")


# Returns the defined material within given voxel if present, otherwise returns -1
static func get_material(voxel : Dictionary) -> int:
	return voxel.get("material", -1)


# Sets the given material to the given voxel
static func set_material(voxel : Dictionary, material : int) -> void:
	voxel["material"] = material


# Removes material from given voxel
static func remove_material(voxel : Dictionary) -> void:
	voxel.erase("material")


# Removes unnecessary properties of given voxel in accordance to Voxel schema
static func clean(voxel : Dictionary) -> void:
	if not is_valid_name(get_name(voxel)):
		remove_name(voxel)
	
	if get_tile(voxel) == get_tile({}):
		remove_tile(voxel)
	
	for face in FACES:
		if get_face_color(voxel, face) == get_color({}):
			remove_face_color(voxel, face)
		if get_face_tile(voxel, face) == get_tile({}):
			remove_face_tile(voxel, face)
	
	if get_material(voxel) == get_material({}):
		remove_material(voxel)
	
	if get_metallic(voxel) == get_metallic({}):
		remove_metallic(voxel)
	
	if get_specular(voxel) == get_specular({}):
		remove_specular(voxel)
	
	if get_roughness(voxel) == get_roughness({}):
		remove_roughness(voxel)
	
	if get_energy(voxel) == get_energy({}):
		remove_energy(voxel)
	
	if get_energy_color(voxel) == get_energy_color({}):
		remove_energy_color(voxel)


# Returns the world position as snapped world position
static func world_to_snapped(world : Vector3, voxel_size : float = 0.5) -> Vector3:
	return (world / voxel_size).floor() * voxel_size


# Returns the snapped world position as voxel grid position
static func snapped_to_grid(snapped : Vector3, voxel_size : float = 0.5) -> Vector3:
	return snapped / voxel_size


# Returns world position as voxel grid position
static func world_to_grid(world : Vector3, voxel_size : float = 0.5) -> Vector3:
	return snapped_to_grid(
				world_to_snapped(world, voxel_size), voxel_size)


# Returns voxel grid position as snapped world position
static func grid_to_snapped(grid : Vector3, voxel_size : float = 0.5) -> Vector3:
	return grid * voxel_size
