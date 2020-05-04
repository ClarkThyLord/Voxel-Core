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

var Names := {}
func name_to_id(name : String) -> int:
	return Names.get(name.to_lower(), -1)


var Voxels := {} setget set_voxels
func set_voxels(voxels : Dictionary, emit := true) -> void:
	if Locked:
		printerr("VoxelSet Locked")
		return
	
	Voxels = voxels
	
	if emit: updated_voxels()


export(bool) var Locked := false


var UVScale := 0.0 setget set_uv_scale
func set_uv_scale(uv_scale : float) -> void: pass

export(float, 1, 1000000000, 1) var TileSize := 32.0 setget set_tile_size
func set_tile_size(tile_size : float, update := true) -> void:
	TileSize = floor(clamp(tile_size, 1, 1000000000))
	
	if update: updated_textures()

export(Texture) var Tiles : Texture = null setget set_tiles
func set_tiles(tiles : Texture, update := true) -> void:
	Tiles = tiles
	
	if update: updated_textures()



# Core
func _save() -> void:
	set_meta("Names", Names)
	set_meta("Voxels", Voxels)

func _load() -> void:
	if has_meta("Names"):
		Names = get_meta("Names")
	if has_meta("Voxels"):
		Voxels = get_meta("Voxels")
	updated_voxels()


func _init(): call_deferred("_load")


func set_voxel(voxel : Dictionary, id = get_id(), update := true) -> int:
	if Locked:
		printerr("VoxelSet Locked")
		return -1
	
	if typeof(id) == TYPE_STRING:
		id = id.to_lower()
		if not Names.has(id):
			Names[id] = get_id()
		id = Names[id]
	elif not typeof(id) == TYPE_INT:
		printerr("invalid id given when setting voxel, id: ", str(id))
		return -1
	id = int(abs(id))
	
	Voxels[id] = voxel
	
	if update: updated_voxels()
	
	return id

func get_voxel(id) -> Dictionary:
	return Voxels.get(name_to_id(id) if typeof(id) == TYPE_STRING else id, {})

func erase_voxel(id, update := true) -> void:
	if Locked:
		printerr("VoxelSet Locked")
		return
	
	if typeof(id) == TYPE_STRING:
		var name = id
		id = name_to_id(id)
		if id == -1:
			printerr("invalid name given when erasing voxel, name: ", name)
			return
		Names.erase(name)
	elif not typeof(id) == TYPE_INT:
		printerr("invalid id given when erasing voxel, id: ", id)
		return
	id = int(abs(id))
	
	Voxels.erase(id)
	
	if update: updated_voxels()

func erase_voxels(update := true, update := true) -> void:
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
