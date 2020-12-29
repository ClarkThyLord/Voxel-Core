tool
class_name VoxelSet, "res://addons/Voxel-Core/assets/classes/VoxelSet.png"
extends Resource
# Library of Voxels used by VoxelObjects.



## Signals
# Emitted on request_refresh
signal requested_refresh



## Exported Variables
# Size of each tile in tiles in pixels
export(Vector2) var TileSize := Vector2(32.0, 32.0) setget set_tile_size

# Texture used for tiles
export(Texture) var Tiles : Texture = null setget set_tiles



## Private Variables
# Voxels stored by their id
var _voxels := {}

# Flag indicating whether _uv_scale, TileSize and Tiles texture is set
var _uv_ready := false

# World UV Scale, calculated on request_refresh
var _uv_scale := Vector2.ONE



## Built-In Virtual Methods
func _get(property : String):
	if property == "VOXELS":
		return _voxels

func _set(property : String, value) -> bool:
	if property == "VOXELS":
		_voxels = value
		return true
	return false

func _get_property_list():
	var properties = []
	
	properties.append({
		"name": "VOXELS",
		"type": TYPE_DICTIONARY,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	return properties



## Public Methods
# Sets TileSize, calls on request_refresh by default
func set_tile_size(tile_size : Vector2, refresh := true) -> void:
	TileSize = Vector2(
		floor(clamp(tile_size.x, 1, 256)),
		floor(clamp(tile_size.y, 1, 256))
	)
	
	if refresh:
		request_refresh()


# Sets Tiles, calls on request_refresh by default
func set_tiles(tiles : Texture, refresh := true) -> void:
	Tiles = tiles
	
	if refresh:
		request_refresh()


# Returns true if VoxelSet has everything necessary for uv mapping
func is_uv_ready() -> bool:
	return _uv_ready


# Returns the uv scale
func get_uv_scale() -> Vector2:
	return _uv_scale


# Returns true if given id is valid
static func is_valid_id(id : int) -> bool:
	return id >= 0


# Returns true if given name is valid
static func is_valid_name(name : String) -> bool:
	return not name.empty()


# Return true if no _voxels are present
func empty() -> bool:
	return _voxels.empty()


# Returns list of all the registered voxel ids
# returns   :   Array<int>   :   list of registered voxel ids
func get_ids() -> Array:
	return _voxels.keys()


# Returns the next available id
func get_next_id() -> int:
	var ids := _voxels.keys()
	ids.sort()
	return (ids.back() + 1) if ids.size() > 0 else 0


# Sets given name to voxel with given id
func name_voxel(id : int, name : String) -> void:
	if not is_valid_id(id):
		printerr("_voxelset : given id `" + str(id) + "` is out of range")
		return
	elif not is_valid_name(name):
		printerr("_voxelset : given voxel name `" + name + "` is invalid")
		return
	
	get_voxel(id)["vsn"] = name


# Removes name from voxel with given id
func unname_voxel(id : int) -> void:
	if not is_valid_id(id):
		printerr("_voxelset : given id `" + str(id) + "` is out of range")
		return
	
	get_voxel(id).erase("vsn")


# Returns name associated with the given id, return a empty string if id isn't found
func id_to_name(id : int) -> String:
	return get_voxel(id).get("vsn", "")


# Returns id associated with the given name, returns -1 if name isn't found
func name_to_id(name : String) -> int:
	for id in _voxels:
		if id_to_name(id) == name:
			return id
	return -1


# Set a voxel with give name and id
func set_voxel(voxel : Dictionary, name := "", id := get_next_id()) -> int:
	if not is_valid_id(id):
		printerr("_voxelset : given id `" + str(id) + "` is out of range")
		return -1
	
	_voxels[id] = voxel
	if not name.empty():
		name_voxel(id, name)
	
	return id

# Replaces all _voxels
func set_voxels(_voxels : Dictionary) -> void:
	_voxels = _voxels


# Gets voxel Dictionary by their id, returns an empty Dictionary if not found
func get_voxel(id : int) -> Dictionary:
	return _voxels.get(id, {})


# Erase voxel with given id
func erase_voxel(id : int) -> void:
	_voxels.erase(id)


# Erases all _voxels
func erase_voxels() -> void:
	_voxels.clear()


# Emits requested_refresh, calculates _uv_scale and updates _uv_ready
func request_refresh() -> void:
	_uv_ready = is_instance_valid(Tiles)
	if _uv_ready:
		_uv_scale = Vector2.ONE / (Tiles.get_size() / TileSize)
	else:
		_uv_scale = Vector2.ONE
	emit_signal("requested_refresh")


# Loads file's content as voxels
# NOTE: Reference Reader.gd for valid file imports
# source_file   :   String   :   Path to file to be loaded
# return int    :   int      :   Error code
func load_file(source_file : String) -> int:
	var read := Reader.read_file(source_file)
	var error : int = read.get("error", FAILED)
	if error == OK:
		var palette := {}
		for index in range(read["palette"].size()):
			palette[index] = read["palette"][index]
		set_voxels(palette)
	return error
