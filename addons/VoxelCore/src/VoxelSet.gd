tool
extends Node
class_name VoxelSet, 'res://addons/VoxelCore/assets/VoxelSet.png'



# Util
# Save current state to meta data
#
# Example:
#   _save()
#
func _save() -> void:
	set_meta('_id', _id)
	set_meta('Voxels', Voxels)

# Load and set meta data in storage
#
# Example:
#   _load()
#
func _load() -> void:
	_id = get_meta('_id') if get_meta('_id') is int else 0
	Voxels = get_meta('Voxels') if get_meta('Voxels') is Dictionary else {}



# Declarations
# Auto-increments on Voxel append
var _id : int = 0 setget set_id
func set_id(id : int) -> void: return;

# Voxels for set
var Voxels : Dictionary = {} setget set_voxels

# Set Voxels of set and save
# voxels   :   Dictionary   -   Voxels to duplicate
#
# Example:
#   set_voxels([Voxels])
#
func set_voxels(voxels : Dictionary) -> void:
	Voxels = voxels.duplicate()
	
	_save()


# Gets a Voxel from set via its id
# id         :   int          -   id related to Voxel being retrieved
# @returns   :   Dictionary   -   Dictionary representing Voxel; null, if id isn't found
#
# Example:
#   get_voxel(3) -> [Dictionary]
#
func get_voxel(id : int) -> Dictionary:
	return Voxels.get(id, {})


# Append a Voxel, or set Voxel by providing a id
# voxel      :   Dictionary   -   Dictionary representation of a Voxel
# @returns   :   int          -   id given to voxel
#
# Example:
#   set_voxel([Dictionary]) -> 3
#   set_voxel([Dictionary], 45) -> 45
#
func set_voxel(voxel : Dictionary, id : int = -1) -> int:
	if id < 0:
		id = _id
		_id += 1
	
	Voxels[id] = voxel
	
	_save()
	
	return id


# Erases a Voxel from the set via its id; and returns it's Dictionary representation
# id         :   int                         -   id related to Voxel being retrieved
# @returns   :   Variant : Dictionary/null   -   Dictionary representing voxel; null, voxel with given id not found
#
# Example:
#   erase_voxel(33) -> [Dictionary]
#
func erase_voxel(id : int) -> Dictionary:
	var voxel = Voxels.get(id)
	
	if voxel is Dictionary: Voxels.erase(id)
	
	return voxel



# Core
func _init(): _load()
