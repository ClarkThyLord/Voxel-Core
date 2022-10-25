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
@export
var tiles : Texture = null :
	get = get_tiles,
	set = set_tiles

@export
var tile_dimensions : Vector2i = Vector2i(32, 32) :
	get = get_tile_dimensions,
	set = set_tile_dimensions

@export
var material : StandardMaterial3D = StandardMaterial3D.new() :
	get = get_material,
	set = set_material

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
func get_tiles() -> Texture:
	return tiles


func set_tiles(new_tiles) -> void:
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


func add_voxel(voxel : Voxel) -> int:
	_id += 1
	_voxels[_id] = voxel
	emit_changed()
	return _id


func update_voxel(id : int, voxel : Voxel) -> void:
	if not _voxels.has(id):
		printerr("Error: Can't get voxel with id `%s` in VoxelSet" % id)
		return
	_voxels[id] = voxel
	emit_changed()


func remove_voxel(id : int) -> void:
	_voxels.erase(id)
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
