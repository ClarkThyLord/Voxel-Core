tool
extends Node
class_name VoxelSet, 'res://addons/VoxelCore/assets/VoxelSet.png'



# A mayor problem when working with Voxels is memory and storage, afterall a VoxelObject of 16x16x16 dimensions contains, at its peak, 4096 Voxels!
# There are various ways to solve this issue, among them is having predefined Voxels and assigning them IDs
# In this way a Voxels data won’t be repetiably copied, but instead be stored once and be referenced as many times as needed
# VoxelSets job is to ease data consumption by having a curated fully customizable Voxel Dictionary of sorts to be used by VoxelObjects



# Declarations
var _id : int = 0 setget set_id # Auto-increments on Voxel append
func set_id(id : int) -> void: return;


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
func set_voxels(voxels : Dictionary, emit : bool = true) -> void:
	voxels = voxels.duplicate(true)
	
	_save()
	
	if emit: emit_signal('set_voxels')



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
	
	if emit: emit_signal('set_voxel', id)
	
	return id

signal erased_voxel(id)
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
	
	if emit: emit_signal('erased_voxel', id)
	
	return voxel
