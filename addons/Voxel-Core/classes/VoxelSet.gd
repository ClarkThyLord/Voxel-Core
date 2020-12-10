tool
extends Resource
class_name VoxelSet, "res://addons/Voxel-Core/assets/classes/VoxelSet.png"
# Library of voxels for a VoxelObject



# Declarations
# Emitted when VoxelSet has had a voxel added / set / removed
signal updated_voxels
# Emitted when tiles data is changes
signal updated_tiles


# Voxels stored by their ID
var Voxels := {} setget set_voxels
# Sets voxels contained and calls on updated_voxels by default
func set_voxels(voxels : Dictionary, update := true) -> void:
	if Locked:
		printerr("VoxelSet is locked")
		return
	
	Voxels = voxels
	
	if update: updated_voxels()


# Flag indicating whether VoxelSet cannot be modified
export(bool) var Locked := false

# Calculated once per TileSize or Tiles change
var UVScale := 0.0 setget set_uv_scale
# Prevent external modificaciones to UV Scale
func set_uv_scale(uv_scale : float) -> void: pass

# Uniform size of tile
export(float, 1, 1000000000, 1) var TileSize := 32.0 setget set_tile_size
# Sets TileSize and calls on updated_textures by default
func set_tile_size(tile_size : float, update := true) -> void:
	TileSize = floor(clamp(tile_size, 1, 1000000000))
	
	if update: updated_textures()


# Texture for VoxelSet
export(Texture) var Tiles : Texture = null setget set_tiles
# Sets Tiles and calls on updated_textures by default
func set_tiles(tiles : Texture, update := true) -> void:
	Tiles = tiles
	
	if update: updated_textures()



# Core
# Saves necessary data to meta
func _save() -> void:
	set_meta("Voxels", Voxels)

# Loads necessary data from meta
func _load() -> void:
	if has_meta("Voxels"):
		Voxels = get_meta("Voxels")
	updated_voxels()


# Calls on _load as soon as feasible
func _init():
	call_deferred("_load")


# Returns the next available ID
# @return	int	:	Next available ID
func get_next_id() -> int:
	var ids := Voxels.keys()
	ids.sort()
	return (ids.back() + 1) if ids.size() > 0 else 0

# Returns name set to given ID
func id_to_name(id : int) -> String:
	return get_voxel(id).get("vsn", "")



# Sets given name to voxel with given ID, calls on updated_voxels by default
# @param	id		:	int		:	
# @param	name	:	String	:	
# @param	update	:	bool	:	
func name_voxel(id : int, name : String, update := true) -> void:
	if Locked:
		printerr("VoxelSet is locked")
		return
	elif id < 0:
		printerr("given id is out of VoxelSet range")
		return
	elif name.empty():
		printerr("given voxel name is invalid")
		return
	
	get_voxel(id)["vsn"] = name
	
	if update: updated_voxels()

func unname_voxel(id : int) -> void:
	pass


func set_voxel(voxel : Dictionary, id := get_next_id(), name := "", update := true) -> int:
	if Locked:
		printerr("VoxelSet Locked")
		return -1
	elif id < 0:
		printerr("given id out of VoxelSet range")
		return -1
	
	if not name.empty():
		Names[name.to_lower()] = id
	
	Voxels[id] = voxel
	
	if update: updated_voxels()
	
	return id

func get_voxel(id) -> Dictionary:
	return Voxels.get(name_to_id(id) if typeof(id) == TYPE_STRING else id, {})

func erase_voxel(id : int, update := true) -> void:
	if Locked:
		printerr("VoxelSet Locked")
		return
	elif id < 0:
		printerr("given id out of VoxelSet range")
		return
	
	var name := id_to_name(id)
	if not name.empty():
		Names.erase(name)
	
	Voxels.erase(id)
	
	if update: updated_voxels()

func erase_voxels(update := true) -> void:
	if Locked:
		printerr("VoxelSet Locked")
		return
	
	Names.clear()
	Voxels.clear()
	
	if update: updated_voxels()


func updated_voxels() -> void:
	_save()
	emit_signal("updated_voxels")

func updated_textures() -> void:
	if is_instance_valid(Tiles):
		UVScale = 1.0 / (Tiles.get_width() / TileSize)
	else: UVScale = 0.0
	
	emit_signal("updated_texture")
