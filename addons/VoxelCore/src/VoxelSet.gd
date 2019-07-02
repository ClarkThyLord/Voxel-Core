tool
extends Node
class_name VoxelSet, 'res://addons/VoxelCore/assets/VoxelSet.png'



# A mayor problem when working with Voxels is memory and storage, afterall a VoxelObject of 16x16x16 dimensions contains, at its peak, 4096 Voxels!
# There are various ways to solve this issue, among them is having predefined Voxels and assigning them IDs
# In this way a Voxels data won’t be repetiably copied, but instead be stored once and be referenced as many times as needed
# VoxelSets job is to ease data consumption by having a curated fully customizable Voxel Dictionary of sorts to be used by VoxelObjects



# Declarations
signal update   # Emitted when VoxelSet is modified in such a way that it's dependents need to update

var _id : int = 0 setget set_id          #   Auto-increments on Voxel append
func set_id(id : int) -> void: return;   #   _id shouldn't be settable externally


signal set_voxels
# Voxels of set
var voxels : Dictionary = {} setget set_voxels
# Set Voxels of set and save, emit 'set_voxels'
# voxels   :   Dictionary   -   Voxels to duplicate
# emit     :   bool         -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxels({ ... })
#
func set_voxels(_voxels : Dictionary, emit : bool = true) -> void:
	var ids = _voxels.keys()
	ids.sort()
	_id = ids[-1] + 1
	
	voxels = _voxels.duplicate(true)
	
	_save()
	
	if emit:
		emit_signal('update')
		emit_signal('set_voxels')


# UV Scale per tile
var UVScale : float = 1.0
func update_uv_scale() -> void:
	if TileSize > 0 and AlbedoTexture != '':
		UVScale = 1.0 / ((load(AlbedoTexture) as Texture).get_width() / TileSize)
		
		emit_signal('update')

signal set_tile_size(tilesize)
# Size of tiles within AlbedoTexture
export(int) var TileSize : int = 0 setget set_tile_size
# Setter for TileSize; emits 'update' and 'set_tile_size'
# tilesize   :   int    -   size of tile
# emit       :   bool   -   true, emit signal; false, don't emit signal   #   NOTE: Won't emit 'update' if AlbedoTexture isn't set
# 
# Example:
#   set_tile_size(32, false)
#
func set_tile_size(tilesize : int, emit : bool = true) -> void:
	TileSize = abs(tilesize)
	
	update_uv_scale()
	
	if emit: emit_signal('set_tile_size', TileSize)

signal set_albedo_texture(albedotexture)
# Path to albedo texture used
export(String, FILE, "*.png,*.jpg") var AlbedoTexture : String = '' setget set_albedo_texture
# Setter for AlbedoTexture path; emits 'update' and 'set_albedo_texture'
# albedotexture   :   String   -   path to set
# emit            :   bool     -   true, emit signal; false, don't emit signal   #   NOTE: Won't emit 'update' if TileSize isn't set
# 
# Example:
#   set_albedo_texture([String], false)
#
func set_albedo_texture(albedotexture : String = AlbedoTexture, emit : bool = true) -> void:
	AlbedoTexture = albedotexture
	
	update_uv_scale()
	
	if emit: emit_signal('set_albedo_texture', AlbedoTexture)




# Core
# Load necessary data
func _load() -> void:
	_id = get_meta('_id') if has_meta('_id') else 0
	voxels = get_meta('voxels') if has_meta('voxels') else {}

# Save necessary data
func _save() -> void:
	set_meta('_id', _id)
	set_meta('voxels', voxels)


# The following will initialize the object as needed
func _init(): _load()


# Gets a Voxel from set via its id
# id         :   int          -   id related to Voxel being retrieved
# @returns   :   Dictionary   -   Dictionary representing Voxel; null, if id isn't found
#
# Example:
#   get_voxel(3) -> { ... }
#
func get_voxel(id : int) -> Dictionary: return voxels.get(id, {})

signal set_voxel(id)
# Append a Voxel, or set Voxel by providing a ID; emits 'set_voxel'
# voxel      :   Dictionary   -   Voxel data to store
# id         :   int          -   ID to set to Voxel
# emit       :   bool         -   true, emit signal; false, don't emit signal
# @returns   :   int          -   ID given to voxel
#
# Example:
#   set_voxel({ ... })       ->   3
#   set_voxel({ ... }, 45)   ->   45
#
func set_voxel(voxel : Dictionary, id : int = -1, emit : bool = true) -> int:
	if id < 0:
		id = _id
		_id += 1
	
	voxels[id] = voxel
	
	_save()
	
	if emit:
		emit_signal('update')
		emit_signal('set_voxel', id)
	
	return id

signal erased_voxel(id, voxel)
# Erases a Voxel by its id, and return its data; emits 'erased_voxel'
# id         :   int               -   id related to Voxel being retrieved
# emit       :   bool              -   true, emit signal; false, don't emit signal
# @returns   :   null/Dictionary   -   Dictionary representing voxel; null, voxel with given id not found
#
# Example:
#   erase_voxel(33)   ->   { ... }
#
func erase_voxel(id : int, emit : bool = true) -> Dictionary:
	var voxel = voxels.get(id)
	
	if typeof(voxel) == TYPE_DICTIONARY: voxels.erase(id)
	
	if emit:
		emit_signal('update')
		emit_signal('erased_voxel', id, voxel)
	
	return voxel
