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



# Public Methods
func get_tiles() -> Texture:
	return tiles


func set_tiles(new_tiles) -> void:
	tiles = new_tiles


func get_tile_dimensions() -> Vector2i:
	return tile_dimensions


func set_tile_dimensions(new_tile_dimensions : Vector2i) -> void:
	tile_dimensions = new_tile_dimensions.abs()


func get_material() -> StandardMaterial3D:
	return material


func set_material(new_material) -> void:
	if not is_instance_valid(new_material):
		return
	material = new_material


func get_materials() -> Array[BaseMaterial3D]:
	return materials


func set_materials(new_materials : Array[BaseMaterial3D]) -> void:
	materials = new_materials


func get_voxel_ids() -> Array[int]:
	return []


func get_voxel_names() -> Array[String]:
	return []


func get_voxel_ids_and_names() -> Dictionary:
	return {}


func get_voxel(id : int) -> Voxel:
	return null


func add_voxel(voxel : Voxel) -> int:
	return -1


func update_voxel(id : int, voxel : Voxel) -> void:
	return


func remove_voxel(id : int) -> void:
	return


func get_voxel_id_by_name(name : String) -> int:
	return -1


func get_voxel_by_name(name : String) -> Voxel:
	return null


func update_voxel_by_name(name : String, voxel : Voxel) -> void:
	return


func remove_voxel_by_name(name : String) -> void:
	return
