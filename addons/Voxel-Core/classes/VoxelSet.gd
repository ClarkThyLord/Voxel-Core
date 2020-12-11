tool
extends Resource
class_name VoxelSet, "res://addons/Voxel-Core/assets/classes/VoxelSet.png"
# Library of voxels for a VoxelObject



# Declarations
# Emitted when VoxelSet has had a voxel added / set / removed
signal refresh_voxels
# Emitted when tiles data is changed
signal refresh_tiles


# Voxels stored by their ID
var Voxels := {} setget set_voxels

# Calculated once per TileSize or Tiles change
var UVScale := 0.0 setget set_uv_scale
# Prevent external modificaciones to UV Scale
func set_uv_scale(uv_scale : float) -> void: pass

# Uniform size of tiles in pixels
export(float, 1, 1000000000, 1) var TileSize := 32.0 setget set_tile_size
# Sets TileSize and calls on request_refresh_tiles by default
func set_tile_size(tile_size : float, update := true) -> void:
	TileSize = floor(clamp(tile_size, 1, 1000000000))
	
	if update: request_refresh_tiles()

# Texture for tiles
export(Texture) var Tiles : Texture = null setget set_tiles
# Sets Tiles and calls on request_refresh_tiles by default
func set_tiles(tiles : Texture, update := true) -> void:
	Tiles = tiles
	
	if update: request_refresh_tiles()



# Core
# Saves necessary data to meta
func _save() -> void:
	set_meta("Voxels", Voxels)

# Loads necessary data from meta
func _load() -> void:
	if has_meta("Voxels"):
		Voxels = get_meta("Voxels")
	request_refresh_voxels()


# Calls on _load as soon as feasible
func _init():
	call_deferred("_load")


# Returns true if given id is valid
# id      : ing  : id to validate
# returns : bool : true if id is valid
static func is_valid_id(id : int) -> bool:
	return id > 0

# Returns true if given name is valid
# name    : String : name to validate
# returns : bool   : true if name is valid
static func is_valid_name(name : String) -> bool:
	return not name.empty()


# Returns list of all the registered voxel ids
# returns : Array<int> : list of registered voxel ids
func get_ids() -> Array:
	return Voxels.keys()

# Returns the next available ID
# returns : int : next available ID
func get_next_id() -> int:
	var ids := Voxels.keys()
	ids.sort()
	return (ids.back() + 1) if ids.size() > 0 else 0


# Sets given name to voxel with given ID, calls on refresh_voxels by default
# @param	id		:	int		:	
# @param	name	:	String	:	
# @param	update	:	bool	:	
func name_voxel(id : int, name : String) -> void:
	if is_valid_id(id):
		printerr("given id is out of VoxelSet range")
		return
	elif is_valid_name(name):
		printerr("given voxel name is invalid")
		return
	
	get_voxel(id)["vsn"] = name

func unname_voxel(id : int) -> void:
	if is_valid_id(id):
		printerr("given id is out of VoxelSet range")
		return
	
	get_voxel(id).erase("vsn")

# Returns name set to given ID
# @param	id	:	int	:	
func id_to_name(id : int) -> String:
	return get_voxel(id).get("vsn", "")

func name_to_id(name : String) -> int:
	for id in Voxels:
		if id_to_name(id) == name:
			return id
	return -1


func set_voxel(voxel : Dictionary, name := "", id := get_next_id()) -> int:
	if is_valid_id(id):
		printerr("given id is out of VoxelSet range")
		return -1
	
	Voxels[id] = voxel
	name_voxel(id, name)
	
	return id

# Sets voxels and calls on refresh_voxels by default
# voxels : Dictionary : 
func set_voxels(voxels : Dictionary) -> void:
	Voxels = voxels

func get_voxel(id : int) -> Dictionary:
	return Voxels.get(id, {})

func erase_voxel(id : int) -> void:
	if id < 0:
		printerr("given id out of VoxelSet range")
		return

func erase_voxels() -> void:
	Voxels.clear()


func request_refresh_voxels() -> void:
	_save()
	emit_signal("refresh_voxels")

func request_refresh_tiles() -> void:
	if is_instance_valid(Tiles):
		UVScale = 1.0 / (Tiles.get_width() / TileSize)
	else: UVScale = 0.0
	
	emit_signal("refresh_tiles")
