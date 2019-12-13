tool
extends MeshInstance



# VoxelObject:
# This is a makeshift abstract class intended to be inherited by all classes that will visualize Voxels.
# NOTE: This class isn't meant to be instanced!



# References
const VoxelSetClass := preload('res://addons/Voxel-Core/src/VoxelSet.gd')



# Declarations
# Adds UV mapping to mesh of VoxelObject, emits 'set_uv_mapping'.
# NOTE: If active, UV mapping is added even if texture isn't present in region.
# uvmapping   :   bool   -   value to set
# update      :   bool   -   whether to call on 'update'
# emit        :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_uv_mapping(true, false, false)
#
signal set_uv_mapping(uvmapping)
export(bool) var UVMapping := false setget set_uv_mapping
func set_uv_mapping(uvmapping : bool, update := true, emit := true) -> void:
	UVMapping = uvmapping
	
	if update: update()
	if emit: emit_signal('set_uv_mapping', uvmapping)


# Create and maintain a trimesh static body, emits 'set_build_static_body'.
# NOTE: If active, the trimesh StaticBody will be updated with every Mesh update.
# buildstaticbody   :   bool   -   value to set
# update            :   bool   -   whether to call on 'update_static_body'
# emit              :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_build_static_body(true, false, false)
#
signal set_build_static_body(buildstaticbody)
export(bool) var BuildStaticBody := false setget set_build_static_body
func set_build_static_body(buildstaticbody : bool, update := true, emit := true) -> void:
	BuildStaticBody = buildstaticbody
	
	if update: update_static_body()
	if emit: emit_signal('set_build_static_body', buildstaticbody)


# Type of meshing to do when building Mesh, emits 'set_mesh_type'.
# meshtype   :   int(MeshTypes)   -   value to set
# update     :   bool             -   whether to call on 'update'
# emit       :   bool             -   true, emit signal; false, don't emit signal
#
# Example:
#   set_mesh_type(MeshTypes.GREEDY, false, false)
#
signal set_mesh_type(meshtype)
enum MeshTypes {
	# Naive meshing does simple 'culling', constructing only visible faces.
	# NOTE: Use for frequently updated VoxelObjects.
	NAIVE,
	# Greedy meshing joins similar faces so as to reduce face count.
	# NOTE: Use for non-frequently updated VoxelObjects.
	GREEDY,
#	TODO: MARCHING_CUBES
}
export(MeshTypes) var MeshType := MeshTypes.NAIVE setget set_mesh_type
func set_mesh_type(meshtype : int, update := true, emit := true) -> void:
	MeshType = meshtype
	
	if update: update()
	if emit: emit_signal('set_mesh_type', meshtype)


# VoxelSet being used, emits 'set_voxel_set'
# _voxelset   :   bool   -   value to set
# update      :   bool   -   call on update
# emit        :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel_set(true, false, false)
#
signal set_voxel_set(voxelset)
var VoxelSet : VoxelSetClass setget set_voxel_set
func set_voxel_set(voxelset : VoxelSetClass, update := true, emit := true) -> void:
	VoxelSet = voxelset
	
	if update: update()
	if emit: emit_signal('set_voxel_set', voxelset)

# NodePath to VoxelSet being used
# Setter for VoxelSetPath, emits 'set_voxel_set'
# voxelsetpath   :   bool   -   value to set
# update         :   bool   -   call on update
# emit           :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel_set_path([NodePath], false, false)
#
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


func get_voxel(position : Vector3) -> Dictionary:
	var voxel = get_rvoxel(position)
	if typeof(voxel) == TYPE_INT: voxel = VoxelSet.get_voxel(voxel)
	return voxel

func get_rvoxel(position : Vector3): pass

func get_voxels() -> Dictionary: return {}


func set_voxel(position : Vector3, voxel, update := true) -> void:
	pass

func set_rvoxel(position : Vector3, voxel, update := true) -> void:
	if typeof(voxel) == TYPE_INT: voxel = VoxelSet.get_voxel(voxel)
	set_voxel(voxel, update)

func set_voxels(voxels : Dictionary) -> void:
	pass


func erase_voxel(position : Vector3) -> void:
	pass

func erase_voxels() -> void:
	for voxel_position in get_voxels().keys():
		erase_voxel(voxel_position)


func update() -> void:
	if BuildStaticBody: update_static_body()

func update_static_body() -> void:
	pass
