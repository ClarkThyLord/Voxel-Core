tool
extends Node



# VoxelSet:
# A mayor problem when working with Voxels is memory and storage, afterall a VoxelObject of 16x16x16 dimensions contains, at its peak, 4096 Voxels!
# There are various ways to solve this issue, among them is having predefined Voxels and assigning them IDs.
# In this way a Voxels data won’t be repetiably copied, but instead be stored once and be referenced as many times as needed.
# VoxelSets job is to ease data consumption by having a curated fully customizable Voxel Dictionary of sorts to be used by VoxelObjects.



# Declarations
signal updated


var _ID := 0 setget set_id              #   Auto-increments on Voxel append
func set_id(id : int) -> void: return   #   _ID shouldn't be settable externally


# Sets Voxels of set, emits 'update'.
# voxels   :   Dictionary<int, Dictionary[Voxel]>   -   Voxels to duplicate
# update   :   bool   -   whether to call on 'update'
#
# Example:
#   set_voxels({ ... }, false)
#
var Voxels : Dictionary = {} setget set_voxels
func set_voxels(voxels : Dictionary, update := true) -> void:
	var ids = voxels.keys()
	ids.sort()
	_ID = ids[-1] + 1
	
	Voxels = voxels.duplicate(true)
	
	if update: self.update()



var UV_SCALE := 1.0 setget set_uv_scale               #   UV Scale per tile
func set_uv_scale(uv_scale : float) -> void: return   #   UV_SCALE shouldn't be settable externally
# Updates UV_SCALE according to TileSize and AlbedoTexture.
# update   :   bool   -   whether to call on 'update'
#
# Example:
#   update_uv_scale(false)
#
func update_uv_scale(update := true) -> void:
	if TileSize > 0 and not AlbedoTexture == null:
		UV_SCALE = 1.0 / (AlbedoTexture.get_width() / TileSize)
		if update: self.update()

# Setter for TileSize; emits 'update' and 'set_tile_size'
# tilesize   :   int    -   size of tile
# update     :   bool   -   whether to call on 'update'
# emit       :   bool   -   true, emit signal; false, don't emit signal   #   NOTE: Won't emit 'update' if AlbedoTexture isn't set
# 
# Example:
#   set_tile_size(32, false)
#
signal set_tile_size(tilesize)
export(int) var TileSize := 0 setget set_tile_size
func set_tile_size(tilesize : int, update := true, emit := true) -> void:
	TileSize = abs(tilesize)
	
	update_uv_scale(update)
	
	if emit: emit_signal('set_tile_size', TileSize)

# Setter for AlbedoTexture; emits 'update' and 'set_albedo_texture'
# albedotexture   :   Texture   -   Texture to set
# update          :   bool      -   whether to call on 'update'
# emit            :   bool      -   true, emit signal; false, don't emit signal   #   NOTE: Won't emit 'update' if TileSize isn't set
# 
# Example:
#   set_albedo_texture([String], false)
#
signal set_albedo_texture(albedotexture)
export(Texture) var AlbedoTexture : Texture setget set_albedo_texture
func set_albedo_texture(albedotexture : Texture = AlbedoTexture, update := true, emit : bool = true) -> void:
	AlbedoTexture = albedotexture
	
	update_uv_scale(update)
	
	if emit: emit_signal('set_albedo_texture', AlbedoTexture)




# Core
# Load necessary data
func _load() -> void:
	_ID = get_meta('_ID') if has_meta('_ID') else 0
	Voxels = get_meta('Voxels') if has_meta('Voxels') else {}

# Save necessary data
func _save() -> void:
	set_meta('_ID', _ID)
	set_meta('Voxels', Voxels)


# The following will initialize the object as needed
func _init(): _load()


# Returns the current value for the specified ID in the VoxelSet.
# id         :   int          -   ID related to Voxel being retrieved
# @returns   :   Dictionary   -   Dictionary representing Voxel; null, if ID isn't found
#
# Example:
#   get_voxel(3) -> { ... }
#
func get_voxel(id : int) -> Dictionary: return Voxels.get(id)


# Append a Voxel, or set Voxel by providing a ID to VoxelSet.
# voxel      :   Dictionary   -   Voxel data to store
# id         :   int          -   ID to set to Voxel
# update     :   bool         -   whether to call on 'update'
# @returns   :   int          -   ID given to Voxel
#
# Example:
#   set_voxel({ ... })       ->   3
#   set_voxel({ ... }, 45)   ->   45
#
func set_voxel(voxel : Dictionary, id := -1, update := true) -> int:
	if id < 0:
		id = _ID
		_ID += 1
	
	Voxels[id] = voxel
	
	if update: self.update()
	
	return id


# Erase a Voxel by ID.
# id         :   int    -   ID related to Voxel being retrieved
# update     :   bool   -   whether to call on 'update'
#
# Example:
#   erase_voxel(33)   ->   { ... }
#
func erase_voxel(id : int, update := true) -> void:
	Voxels.erase(id)
	if update: self.update()


# Saves VoxelSet data, and emits 'update'.
func update() -> void:
	_save()
	emit_signal('updated')
