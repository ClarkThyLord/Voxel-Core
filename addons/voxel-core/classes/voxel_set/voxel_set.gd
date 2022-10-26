@tool
class_name VoxelSet
extends Resource
@icon("res://addons/voxel-core/classes/voxel_set/voxel_set.svg")
## Used to store a collection of voxels, textures, materials and etc.;
## used by Voxel-Core.
##
## A VoxelSet is a collection of [Voxel](s), alongside textures and materials
## which voxels may reference.
##
## [codeblock]
## var voxel_set = VoxelSet.new()
## voxel_set.tiles = preload("res://texture.png")
## 
## var voxel = Voxel.new()
## voxel.name = "dirt grass"
## voxel.color = Color.BROWN
## voxel.color_up = Color.GREEN
## voxel.tile = Vector2(0, 0)
## voxel.tile_up = Vector2(1, 0)
##
## var voxel_id = voxel_set.add_voxel(voxel)
## [/codeblock]



# Exported Variables
## Texture used for [member BaseMaterial3D.albedo_texture] in [member material]
## and all applicable [member materials].
## Think of the texture as a grid with which its cells or "tiles" can be
## referenced by their position. Using this "tile position" voxels can specify
## what texture is applied to their faces via [member Voxel.tile],
## [member Voxel.tile_right], [member Voxel.tile_left], [member Voxel.tile_up],
## [member Voxel.tile_down], [member Voxel.tile_forward] and [member Voxel.tile_back].
## Usage:
## [codeblock]
## var voxel_set = VoxelSet.new()
## voxel_set.tiles = preload("res://texture.png")
## var voxel = Voxel.new()
## voxel.name = "dirt grass"
## voxel.tile = Vector2(0, 0)
## voxel.tile_up = Vector2(1, 0)
## var voxel_id = voxel_set.add_voxel(voxel)
## [/codeblock]
@export
var tiles : Texture2D = null :
	get = get_tiles,
	set = set_tiles

## Defines the pixel width and height for a "tile" within [member tiles].
@export
var tile_dimensions : Vector2i = Vector2i(32, 32) :
	get = get_tile_dimensions,
	set = set_tile_dimensions

## Material applied to all voxels by default.
@export
var material : StandardMaterial3D = StandardMaterial3D.new() :
	get = get_material,
	set = set_material

## Collection of materials that can be referenced by and applied to voxels via
## [member Voxel.material_index].
@export
var materials : Array[BaseMaterial3D] = [] :
	get = get_materials,
	set = set_materials



# Private Variables
var _id : int = -1

var _voxels : Dictionary = {}



# Built-In Virtual Methods
func _get(property : StringName):
	match str(property):
		"id":
			return _id
		"voxels":
			return _voxels
	return null


func _set(property : StringName, value):
	match str(property):
		"id":
			_id = value
			return true
		"voxels":
			_voxels = value
			return true
	return false


func _get_property_list():
	return [
		{
			"name": "id",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_STORAGE,
		},
		{
			"name": "voxels",
			"type": TYPE_DICTIONARY,
			"usage": PROPERTY_USAGE_STORAGE,
		},
	]



# Public Methods
func get_tiles() -> Texture2D:
	return tiles


func set_tiles(new_tiles : Texture2D) -> void:
	tiles = new_tiles
	emit_changed()


func get_tile_dimensions() -> Vector2i:
	return tile_dimensions


func set_tile_dimensions(new_tile_dimensions : Vector2i) -> void:
	tile_dimensions = new_tile_dimensions.abs()
	emit_changed()


func get_material() -> StandardMaterial3D:
	return material


func set_material(new_material) -> void:
	if not is_instance_valid(new_material):
		return
	material = new_material
	emit_changed()


func get_materials() -> Array[BaseMaterial3D]:
	return materials


func set_materials(new_materials : Array[BaseMaterial3D]) -> void:
	materials = new_materials
	emit_changed()


func get_voxel_ids() -> Array[int]:
	return _voxels.keys()


func get_voxel_names() -> Array[String]:
	var names : Array[String] = []
	for voxel_id in _voxels:
		if not _voxels[voxel_id].name.is_empty():
			names.append(_voxels[voxel_id].name)
	return names


func get_voxel_ids_and_names() -> Dictionary:
	var ids_and_names : Dictionary = {}
	for voxel_id in _voxels:
		ids_and_names[voxel_id] = _voxels[voxel_id].name
	return ids_and_names


func get_voxel(id : int) -> Voxel:
	return _voxels.get(id, null)


func get_voxels() -> Dictionary:
	return _voxels.duplicate(true)


func add_voxel(voxel : Voxel) -> int:
	_id += 1
	if _voxels.has(_id):
		return add_voxel(voxel)
	_voxels[_id] = voxel
	emit_changed()
	return _id


func set_voxel(id : int, voxel : Voxel) -> void:
	if _voxels.has(id):
		printerr("Error: Voxel with id `%s` in VoxelSet already exist" % id)
		return
	_voxels[_id] = voxel
	emit_changed()


func set_voxels(voxels : Dictionary) -> void:
	_voxels = voxels
	emit_changed()


func update_voxel(id : int, voxel : Voxel) -> void:
	if not _voxels.has(id):
		printerr("Error: No voxel with id `%s` in VoxelSet" % id)
		return
	_voxels[id] = voxel
	emit_changed()


func remove_voxel(id : int) -> void:
	_voxels.erase(id)
	emit_changed()


func remove_voxels() -> void:
	_voxels.clear()
	emit_changed()


func get_voxel_id_by_name(name : String) -> int:
	for voxel_id in _voxels:
		if _voxels[voxel_id].name == name:
			return voxel_id
	printerr("Error: Can't get voxel with name `%s` in VoxelSet" % name)
	return -1


func get_voxel_by_name(name : String) -> Voxel:
	for voxel_id in _voxels:
		if _voxels[voxel_id].name == name:
			return _voxels[voxel_id]
	printerr("Error: Can't get voxel with name `%s` in VoxelSet" % name)
	return null


func update_voxel_by_name(name : String, voxel : Voxel) -> void:
	for voxel_id in _voxels:
		if _voxels[voxel_id].name == name:
			_voxels[voxel_id] = voxel
			emit_changed()
			return
	printerr("Error: Can't get voxel with name `%s` in VoxelSet" % name)


func remove_voxel_by_name(name : String) -> void:
	for voxel_id in _voxels.keys():
		if _voxels[voxel_id].name == name:
			_voxels.erase(voxel_id)
			emit_changed()
			return
	printerr("Error: Can't get voxel with name `%s` in VoxelSet" % name)
