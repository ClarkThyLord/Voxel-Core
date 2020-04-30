tool
extends Resource
class_name VoxelSet, "res://addons/Voxel-Core/assets/classes/VoxelSet.png"



#
# VoxelSet, 
#



# Declarations
signal updated_voxels
signal updated_texture


func get_id() -> int:
	var ids := Voxels.keys()
	ids.sort()
	return (ids.back() + 1) if ids.size() > 0 else 0

var Names:= {} setget set_names, get_names
func set_names(names : Dictionary) -> void: pass
func get_names() -> Dictionary: return Names.duplicate()
func name_to_id(name : String) -> int: return Names.get(name, -1)

var Voxels := {} setget set_voxels, get_voxels


export(bool) var Expandable := true


var UVScale := 0.0 setget set_uv_scale
func set_uv_scale(uv_scale : float) -> void: pass

export(float, 1, 1000000000, 1) var TileSize := 32.0 setget set_tile_size
func set_tile_size(tile_size : float, update := true) -> void:
	TileSize = floor(clamp(tile_size, 1, 1000000000))
	
	if update: update_uv()

export(Texture) var Tiles : Texture = null setget set_tiles
func set_tiles(tiles : Texture, update := true) -> void:
	Tiles = tiles
	
	if update: update_uv()



# Core
func set_voxel(voxel : Dictionary, id = get_id(), emit := true) -> int:
	if typeof(id) == TYPE_STRING:
		if not Names.has(id):
			Names[id] = get_id()
		id = Names[id]
	elif not typeof(id) == TYPE_INT:
		printerr("invalid id given when setting voxel, id: ", str(id))
		return -1
	
	Voxels[id] = voxel
	
	if emit: emit_signal("updated_voxels")
	
	return id

func set_voxels(voxels : Dictionary, emit := true) -> void:
	erase_voxels()
	for id in voxels:
		if typeof(id) == TYPE_STRING and typeof(voxels[id]) == TYPE_DICTIONARY:
			set_voxel(voxels[id], id)
	
	if emit: emit_signal("updated_voxels")

func get_voxel(id) -> Dictionary:
	return Voxels.get(name_to_id(id) if typeof(id) == TYPE_STRING else id, {}).duplicate(true)

func get_voxels():
	return Voxels.keys()

func erase_voxel(id, emit := true) -> void:
	if typeof(id) == TYPE_STRING:
		var name = id
		id = name_to_id(id)
		Names.erase(id)
	elif not typeof(id) == TYPE_INT:
		printerr("invalid id given when erasing voxel, id: ", str(id))
	
	Voxels.erase(id)
	
	if emit: emit_signal("updated_voxels")

func erase_voxels(update := true, emit := true) -> void:
	Names.clear()
	Voxels.clear()
	
	if emit: emit_signal("updated_voxels")


func update_uv() -> void:
	if TileSize > 0 and Tiles:
		UVScale = 1.0 / (Tiles.get_width() / TileSize)
	else: UVScale = 0.0
	
	emit_signal("updated_texture")
