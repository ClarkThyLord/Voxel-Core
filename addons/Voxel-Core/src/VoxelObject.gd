tool
extends MeshInstance



# References
const VoxelSetClass := preload('res://addons/Voxel-Core/src/VoxelSet.gd')



# Declarations
signal set_uv_mapping(uvmapping)
export(bool) var UVMapping := false setget set_uv_mapping
func set_uv_mapping(uvmapping : bool, update := true, emit := true) -> void:
	UVMapping = uvmapping
	
	if update: update()
	if emit: emit_signal('set_uv_mapping', uvmapping)

signal set_build_static_body(buildstaticbody)
export(bool) var BuildStaticBody := false setget set_build_static_body
func set_build_static_body(buildstaticbody : bool, update := true, emit := true) -> void:
	BuildStaticBody = buildstaticbody
	
	if update: update()
	if emit: emit_signal('set_build_static_body', buildstaticbody)

signal set_mesh_type(meshtype)
enum MeshTypes {
	NAIVE,
	GREEDY,
#	MARCHING_CUBES
}
export(MeshTypes) var MeshType := MeshTypes.NAIVE setget set_mesh_type
func set_mesh_type(meshtype : int, update := true, emit := true) -> void:
	MeshType = meshtype
	
	if update: update()
	if emit: emit_signal('set_mesh_type', meshtype)

signal set_voxel_set(voxelset)
var VoxelSet : VoxelSetClass setget set_voxel_set
func set_voxel_set(voxelset : VoxelSetClass, update := true, emit := true) -> void:
	VoxelSet = voxelset
	
	if update: update()
	if emit: emit_signal('set_voxel_set', voxelset)

export(NodePath) var VoxelSetPath := NodePath('/root/VoxelSet')  setget set_voxel_set_path
func set_voxel_set_path(voxelsetpath : NodePath, update := true, emit := true) -> void:
	if is_inside_tree() and has_node(voxelsetpath) and get_node(voxelsetpath) is VoxelSetClass:
		VoxelSetPath = voxelsetpath
		set_voxel_set(get_node(voxelsetpath), update, emit)



# Core
func _load() -> void:
	if has_meta('voxel_set_path'): set_voxel_set_path(get_meta('voxel_set_path'), false, false)

func _save() -> void:
	set_meta('voxel_set_path', VoxelSetPath)


func _setup() -> void: pass


func _init() -> void: _load()
func _ready() -> void:
	set_voxel_set_path(VoxelSetPath, false, false)
	_load()


func get_voxel(position : Vector3) -> Dictionary:
	return {}

func get_rvoxel(position : Vector3): pass

func get_voxels() -> Dictionary: return {}


func set_voxel(position : Vector3, voxel, update := true) -> void:
	pass

func set_rvoxel(position : Vector3, voxel, update := true) -> void:
	pass

func set_voxels(voxels : Dictionary) -> void:
	pass


func erase_voxel(position : Vector3) -> void:
	pass


func update() -> void:
	pass

func update_staticbody() -> void:
	pass
