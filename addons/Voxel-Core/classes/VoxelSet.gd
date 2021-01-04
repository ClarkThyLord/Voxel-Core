tool
class_name VoxelSet, "res://addons/Voxel-Core/assets/classes/VoxelSet.png"
extends Resource
# Library of Voxels used by VoxelObjects.



## Signals
# Emitted on request_refresh
signal requested_refresh



## Exported Variables
# Size of each tile in tiles in pixels
export var tile_size := Vector2(32.0, 32.0) setget set_tile_size

# Texture used for tiles / uv mapping
export var tiles : Texture = null setget set_tiles



## Private Variables
# Voxels stored by their id
var _voxels := []

# Flag indicating whether _uv_scale, tile_size and tiles texture is set
var _uv_ready := false

# World UV Scale, calculated on request_refresh
var _uv_scale := Vector2.ONE



## Built-In Virtual Methods
func _get(property : String):
	if property == "VOXELS":
		return _voxels


func _set(property : String, value) -> bool:
	if property == "VOXELS":
		if typeof(value) == TYPE_DICTIONARY:
			for key in value:
				var voxel : Dictionary = value[key]
				if voxel.has("vsn"):
					Voxel.set_name(voxel, voxel["vsn"])
					voxel.erase("vsn")
				_voxels.append(value[key])
		else:
			_voxels = value
		return true
	return false


func _get_property_list():
	var properties = []
	
	properties.append({
		"name": "VOXELS",
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_STORAGE,
	})
	
	return properties



## Public Methods
# Sets tile_size, calls on request_refresh by default
func set_tile_size(value : Vector2, refresh := true) -> void:
	tile_size = Vector2(
			floor(clamp(value.x, 1, 256)),
			floor(clamp(value.y, 1, 256)))
	
	if refresh:
		request_refresh()


# Sets tiles, calls on request_refresh by default
func set_tiles(value : Texture, refresh := true) -> void:
	tiles = value
	
	if refresh:
		request_refresh()


# Returns number of voxels in VoxelSet
func size() -> int:
	return _voxels.size()


# Returns true if VoxelSet has no voxels
func empty() -> bool:
	return _voxels.empty()


# Returns true if VoxelSet has voxel with given id
func has_id(id : int) -> bool:
	return id > -1 and id < _voxels.size()


# Returns true if VoxelSet has everything necessary for uv mapping
func uv_ready() -> bool:
	return _uv_ready


# Returns the uv scale
func uv_scale() -> Vector2:
	return _uv_scale


# Returns true if given id is valid
static func is_valid_id(id : int) -> bool:
	return id > -1


# Returns a list of all the voxel ids
# returns   :   Array<int>   :   contained voxel ids
func get_ids() -> Array:
	return range(_voxels.size())


# Returns name associated with the given id, returns a empty string if id isn't found
func id_to_name(id : int) -> String:
	return Voxel.get_name(get_voxel(id))


# Returns the id of the voxel with the given name, returns -1 if not found
func name_to_id(name : String) -> int:
	name = name.to_lower()
	for id in get_ids():
		if id_to_name(id) == name:
			return id
	return -1


# Set the voxel at given id, next available id is assigned if non is provided
func set_voxel(voxel : Dictionary, id : int = size()) -> void:
	if id == size():
		_voxels.append(voxel)
		return
	elif not has_id(id):
		printerr("VoxelSet : given id `" + str(id) + "` is out of range")
		return
	
	_voxels[id] = voxel


# Replaces all _voxels
func set_voxels(voxels : Array) -> void:
	_voxels = voxels


# Gets voxel Dictionary by their id, returns an empty Dictionary if not found
func get_voxel(id : int) -> Dictionary:
	return _voxels[id] if has_id(id) else {}


# Erase voxel from VoxelSet
func erase_voxel(id : int) -> void:
	_voxels.remove(id)


# Erases all voxels in VoxelSet
func erase_voxels() -> void:
	_voxels.clear()


# Should be called when noticable changes have been committed to voxels.
# Emits requested_refresh, calculates _uv_scale and updates _uv_ready
func request_refresh() -> void:
	_uv_ready = is_instance_valid(tiles)
	if _uv_ready:
		_uv_scale = Vector2.ONE / (tiles.get_size() / tile_size)
	else:
		_uv_scale = Vector2.ONE
	emit_signal("requested_refresh")


# Loads file's content as voxels
# NOTE: Reference Reader.gd for valid file imports
# source_file   :   String   :   Path to file to be loaded
# return int    :   int      :   Error code
func load_file(source_file : String, append := false) -> int:
	var read := Reader.read_file(source_file)
	var error : int = read.get("error", FAILED)
	if error == OK:
		if append:
			for voxel in read["palette"]:
				set_voxel(voxel)
		else:
			set_voxels(read["palette"])
	return error
