tool
extends MeshInstance



#
# VoxelObject, 
#



# Declarations
enum VoxelMeshes {
	NAIVE,
	GREEDY
#	MARCHING_CUBES
#	TRANSVOXEL
}
export(VoxelMeshes) var VoxelMesh := VoxelMeshes.NAIVE setget set_voxel_mesh
func set_voxel_mesh(voxel_mesh : int, update := true) -> void:
	VoxelMesh = voxel_mesh
	
	if update: self.update()


var EditHint := false setget set_edit_hint
func set_edit_hint(edit_hint : bool) -> void:
	EditHint = edit_hint


export(bool) var UVMapping := false setget set_uv_mapping
func set_uv_mapping(uv_mapping : bool, update := true) -> void:
	UVMapping = uv_mapping
	
	if update: self.update()

export(bool) var EmbedStaticBody := false setget set_embed_static_body
func set_embed_static_body(embed_static_body : bool) -> void:
	EmbedStaticBody = embed_static_body


export(Resource) var Voxel_Set = preload("res://addons/Voxel-Core/defaults/VoxelSet.tres") setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if voxel_set is VoxelSet:
		Voxel_Set = voxel_set
		
		if update: self.update()
	elif typeof(voxel_set) == TYPE_NIL:
		set_voxel_set(preload("res://addons/Voxel-Core/defaults/VoxelSet.tres"), update)




# Core
func _save() -> void:
	pass

func _load() -> void:
	pass


func _init() -> void: _load()

func _notification(what : int) -> void:
	if what == NOTIFICATION_PREDELETE:
		pass


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
	pass

func get_voxel(grid : Vector3):
	return -1

func get_rvoxel(grid : Vector3) -> Dictionary:
	var voxel = get_voxel(grid)
	match typeof(voxel):
		TYPE_INT, TYPE_STRING:
			voxel = Voxel_Set.get_voxel(voxel)
	return voxel

func get_voxels() -> Array:
	return []

func erase_voxel(grid : Vector3) -> void:
	pass

func erase_voxels() -> void:
	pass


func update() -> void:
	pass

func update_mesh() -> void:
	pass

func update_static_body() -> void:
	pass
