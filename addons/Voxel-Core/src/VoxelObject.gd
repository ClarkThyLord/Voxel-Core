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
func update() -> void:
	pass
