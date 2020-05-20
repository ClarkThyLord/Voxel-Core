tool
extends MeshInstance



#
# VoxelObject, 
#



# Declarations
var EditHint := false setget set_edit_hint
func set_edit_hint(edit_hint : bool, update := is_inside_tree()) -> void:
	EditHint = edit_hint
	
	if update: update_mesh(false)


enum VoxelMeshes {
	NAIVE,
	GREEDY
#	MARCHING_CUBES
#	TRANSVOXEL
}
export(VoxelMeshes) var VoxelMesh := VoxelMeshes.NAIVE setget set_voxel_mesh
func set_voxel_mesh(voxel_mesh : int, update := is_inside_tree()) -> void:
	VoxelMesh = voxel_mesh
	
	if update and not EditHint: update_mesh(false)

export(bool) var UVMapping := false setget set_uv_mapping
func set_uv_mapping(uv_mapping : bool, update := is_inside_tree()) -> void:
	UVMapping = uv_mapping
	
	if update: update_mesh(false)

export(bool) var EmbedStaticBody := false setget set_embed_static_body
func set_embed_static_body(embed_static_body : bool, update := is_inside_tree()) -> void:
	EmbedStaticBody = embed_static_body
	
	if update: update_static_body()


export(Resource) var Voxel_Set = preload("res://addons/Voxel-Core/defaults/VoxelSet.tres") setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := is_inside_tree()) -> void:
	if voxel_set is VoxelSet:
		Voxel_Set = voxel_set
		
		if update: update_mesh(false)
	elif typeof(voxel_set) == TYPE_NIL:
		set_voxel_set(preload("res://addons/Voxel-Core/defaults/VoxelSet.tres"), update)



# Core
func _save() -> void:
	pass

func _load() -> void:
	update_mesh(false)


func _init() -> void: _load()
func _ready() -> void: _load()


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
	for voxel_position in voxels:
		set_voxel(voxel_position, voxels[voxel_position])

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
	for voxel_position in get_voxels():
		erase_voxel(voxel_position)


func update_mesh(save := true) -> void:
	if save: _save()

func update_static_body() -> void:
	pass
