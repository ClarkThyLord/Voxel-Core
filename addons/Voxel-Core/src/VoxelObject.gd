tool
extends MeshInstance



# VoxelObject:
# This is a makeshift abstract class intended to be inherited by all classes that will visualize Voxels.
# NOTE: This class is intended to be inherited, and isn't meant to be instanced itself!



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
	
	if update: self.update()
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
	
	if update: self.update()
	if emit: emit_signal('set_mesh_type', meshtype)


# VoxelSet being used, emits 'set_voxel_set'.
# voxelset   :   bool   -   value to set
# update     :   bool   -   call on update
# emit       :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel_set(true, false, false)
#
signal set_voxel_set(voxelset)
var VoxelSet : VoxelSetClass setget set_voxel_set
func set_voxel_set(voxelset : VoxelSetClass, update := true, emit := true) -> void:
	if voxelset == VoxelSet: return
	elif typeof(voxelset) == TYPE_NIL:
		if has_node('/root/VoxelSet'): voxelset = get_node('/root/CoreVoxelSet')
		else: return
	
	if VoxelSet is VoxelSetClass and VoxelSet.is_connected('updated', self, 'update'): VoxelSet.disconnect('update', self, 'update')
	VoxelSet = voxelset
	if not VoxelSet.is_connected('updated', self, 'update'): VoxelSet.connect('updated', self, 'update')
	
	if update: self.update()
	if emit: emit_signal('set_voxel_set', VoxelSet)


# NodePath to VoxelSet being used, emits 'set_voxel_set'.
# voxelsetpath   :   bool   -   value to set
# update         :   bool   -   call on update
# emit           :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel_set_path([NodePath], false, false)
#
export(NodePath) var VoxelSetPath := NodePath('/root/VoxelSet')  setget set_voxel_set_path
func set_voxel_set_path(voxelsetpath : NodePath, update := true, emit := true) -> void:
	if voxelsetpath.is_empty(): VoxelSetPath = voxelsetpath
	elif is_inside_tree() and has_node(voxelsetpath) and get_node(voxelsetpath) is VoxelSetClass:
		VoxelSetPath = voxelsetpath
		set_voxel_set(get_node(voxelsetpath), update, emit)



# Core
# Load necessary data from meta.
func _load() -> void:
	if has_meta('voxel_set_path'): set_voxel_set_path(get_meta('voxel_set_path'), false, false)

# Save necessary data in meta.
func _save() -> void:
	set_meta('voxel_set_path', VoxelSetPath)


# The following will initialize the object as needed
# NOTE: Should be copied pasted to inheriting class
#func _init() -> void: _load()
#func _ready() -> void:
#	set_voxel_set_path(VoxelSetPath, false)
#	_load()

func _exit_tree():
	if VoxelSet is VoxelSetClass and VoxelSet.is_connected('updated', self, 'update'): VoxelSet.disconnect('updated', self, 'update')


# Get Voxel data at given grid position.
# grid       :   Vector3      -   grid position to get Voxel data from
# @returns   :   Dictionary   -   Voxel data
#
# Example:
#   get_voxel(Vector(11, -34, 2))   ->   { ... }
#
func get_voxel(position : Vector3) -> Dictionary:
	var voxel = get_rvoxel(position)
	if typeof(voxel) == TYPE_INT: voxel = VoxelSet.get_voxel(voxel)
	return voxel

# Get raw Voxel data at given grid position.
# grid       :   Vector3          -   grid position to get Voxel from
# @returns   :   int/Dictionary   -   raw Voxel
#
# Example:
#   get_rvoxel(Vector(11, -34, 2))   ->   3         #   NOTE: Returned ID representing Voxel data
#   get_rvoxel(Vector(-7, 0, 96))    ->   { ... }   #   NOTE: Returned Voxel data
#
func get_rvoxel(position : Vector3): pass

# Returns a copy of all current Voxel data.
# @returns   :   Dictionary<Vector3, Voxel>   -   Dictionary containing grid positions, as keys, and Voxels, as values
#
# Example:
#   get_voxels()   ->   { ... }
#
func get_voxels() -> Dictionary: return {}


# Set Voxel at given grid position.
# grid     :   Vector3          -   grid position to set Voxel to 
# voxel    :   int/Dictionary   -   Voxel to be set
# update   :   bool             -   call on update
#
# Example:
#   set_voxel(Vector(11, -34, 2), 3)         #   NOTE: This would store the Voxel's ID associated with it within VoxelSet
#   set_voxel(Vector(11, -34, 2), { ... })
#
func set_voxel(position : Vector3, voxel, update := true) -> void:
	if update: self.update()

# Set raw Voxel's data at given grid position.
# grid     :   Vector3          -   grid position to set Voxel to 
# voxel    :   int/Dictionary   -   Voxel to be set
# update   :   bool             -   call on update
#
# Example:
#   set_rvoxel(Vector(11, -34, 2), 3)         #   NOTE: This would store a copy of the Voxels present date(Dictionary) within the VoxelSet, not the ID associated with it within VoxelSet
#   set_rvoxel(Vector(11, -34, 2), { ... })
#
func set_rvoxel(position : Vector3, voxel, update := true) -> void:
	if typeof(voxel) == TYPE_INT: voxel = VoxelSet.get_voxel(voxel)
	set_voxel(voxel, update)

# Erases current Voxel data, then sets given Voxel data.
# voxels   :   Dictionary<Vector3, Voxel>   -   Voxels to set
# update   :   bool                         -   call on update
#
# Example:
#   set_voxels({ ... }, false)
#
func set_voxels(voxels : Dictionary, update := true) -> void:
	erase_voxels(false)
	for voxel_position in voxels.keys():
		set_voxel(voxel_position, voxels[voxel_position], false)
	if update: self.update()


# Erase Voxel at given grid position.
# grid     :   Vector3   -   grid position to erase Voxel from
# update   :   bool      -   call on update
#
# Example:
#   erase_voxel(Vector(11, -34, 2), false)
#
func erase_voxel(position : Vector3, update := true) -> void:
	if update: self.update()

# Erases all current Voxels.
# update   :   bool   -   call on update
#
# Example:
#   erase_voxels(false)
#
func erase_voxels(update := true) -> void:
	for voxel_position in get_voxels().keys():
		erase_voxel(voxel_position, false)
	if update: self.update()


# Updates Mesh with current Voxel data, and StaticBody.
#
# Example:
#   update()
#
func update() -> void:
	if BuildStaticBody: update_static_body()

# Sets and updates trimesh StaticBody.
#
# Example:
#   update_staticbody()
#
func update_static_body() -> void:
	pass
