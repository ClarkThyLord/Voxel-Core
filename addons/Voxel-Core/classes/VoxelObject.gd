tool
extends MeshInstance



#
# VoxelObject, makeshift abstract class for all voxel visualization objects.
#



# Declarations
var loaded_hint := false
var EditHint := false setget set_edit_hint
func set_edit_hint(edit_hint : bool, update := loaded_hint and is_inside_tree()) -> void:
	EditHint = edit_hint
	
	if update: update_mesh(false)


enum MeshModes {
	NAIVE,
	GREEDY
#	MARCHING_CUBES
#	TRANSVOXEL
}
export(MeshModes) var MeshMode := MeshModes.NAIVE setget set_voxel_mesh
func set_voxel_mesh(mesh_mode : int, update := loaded_hint and is_inside_tree()) -> void:
	MeshMode = mesh_mode
	
	if update and not EditHint: update_mesh(false)

export(bool) var UVMapping := false setget set_uv_mapping
func set_uv_mapping(uv_mapping : bool, update := loaded_hint and is_inside_tree()) -> void:
	UVMapping = uv_mapping
	
	if update: update_mesh(false)

export(bool) var EmbedStaticBody := false setget set_embed_static_body
func set_embed_static_body(embed_static_body : bool, update := loaded_hint and is_inside_tree()) -> void:
	EmbedStaticBody = embed_static_body
	
	if update: update_static_body()


export(Resource) var Voxel_Set = preload("res://addons/Voxel-Core/defaults/VoxelSet.tres") setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := loaded_hint and is_inside_tree()) -> void:
	if voxel_set is VoxelSet:
		Voxel_Set = voxel_set
		
		if update: update_mesh(false)
	elif typeof(voxel_set) == TYPE_NIL:
		set_voxel_set(preload("res://addons/Voxel-Core/defaults/VoxelSet.tres"), update)



# Core
func _save() -> void:
	pass

func _load() -> void:
	loaded_hint = true
	update_mesh(false)


#func _init() -> void: call_deferred("_load")
#func _ready() -> void: call_deferred("_load")


func set_voxel(grid : Vector3, voxel) -> void:
	match typeof(voxel):
		TYPE_INT, TYPE_DICTIONARY:
			pass
		_:
			printerr("invalid voxel set")

func set_rvoxel(grid : Vector3, voxel) -> void:
	match typeof(voxel):
		TYPE_INT, TYPE_STRING:
			voxel = Voxel_Set.get_voxel(voxel)
	set_voxel(grid, voxel)

func set_voxels(voxels : Dictionary) -> void:
	erase_voxels()
	for grid in voxels:
		set_voxel(grid, voxels[grid])

func get_voxel(grid : Vector3) -> Dictionary:
	var voxel = get_rvoxel(grid)
	match typeof(voxel):
		TYPE_INT, TYPE_STRING:
			voxel = Voxel_Set.get_voxel(voxel)
	return voxel

func get_rvoxel(grid : Vector3):
	return -1

func get_voxels() -> Array:
	return []

func erase_voxel(grid : Vector3) -> void:
	pass

func erase_voxels() -> void:
	for grid in get_voxels():
		erase_voxel(grid)


func update_mesh(save := true) -> void:
	if save: _save()
	update_static_body()

func update_static_body() -> void:
	pass
