tool
extends MeshInstance



# VoxelObject is a makeshift abstract class which needs to be inherited by all classes that will visualize Voxels
# What is meant by makeshift abstract class? It means that all of the methods declared here have not been implemented, and should be implemented by the inheriting class
# NOTE: This class isn't meant to be instanced



# Declarations
# NOTE: The following don't need to be implemented by inheritor
signal set_lock(lock)
# true, flagged locked therefore won't be editable; false, isn't flagged locked therefore is editable
# NOTE: While VoxelObject won't be editable it will still be manipulatable
export(bool) var Lock : bool = false setget set_lock
# Setter for Lock, emits 'set_lock'
# lock   :   bool   :   value to set
# emit   :   bool   :   true, emit signal; false, don't emit signal
#
# Example:
#   set_lock(true, false)
#
func set_lock(lock : bool = !Lock, emit : bool = true) ->  void:
	Lock = lock
	
	if emit: emit_signal('set_lock', Lock)


signal set_greedy(greedy)
# Greedy meshing joins similar vertex and faces so as to reduce vertex and face count
# NOTE: It's recommended to toggle on Greedy when updates won't be frequent
# true, enable greedy meshing when updating mesh; false, disable greedy meshing when updating mesh
export(bool) var Greedy : bool = false setget set_greedy
# Setter for Greedy, emits 'set_greedy'
# lock   :   bool   :   value to set
# emit   :   bool   :   true, emit signal; false, don't emit signal
#
# Example:
#   set_greedy(true, false)
#
func set_greedy(greedy : bool = !Greedy, emit : bool = true) -> void:
	Greedy = greedy
	
	if emit: emit_signal('set_greedy', Greedy)


signal set_static_body(staticbody)
# Create and maintain a trimesh static body
# NOTE: StaticBody updates with every update
export(bool) var StaticBody : bool = false setget set_static_body
# Setter for StaticBody, emits 'set_static_body'
# staticbody   :   bool   :   value to set
# emit         :   bool   :   true, emit signal; false, don't emit signal
#
# Example:
#   set_static_body(true, false)
#
func set_static_body(staticbody : bool = !StaticBody, emit : bool = true) -> void:
	StaticBody = staticbody
	
	if emit: emit_signal('set_static_body', StaticBody)


signal set_mirror_x(mirror)
# true, editing operations will be mirrored over x-axis; false, editing operations won't be mirrored over x-axis
export(bool) var MirrorX : bool = false setget set_mirror_x
# Setter for MirrorX, emits 'set_mirror_x'
# mirror   :   bool   :   value to set
# emit     :   bool   :   true, emit signal; false, don't emit signal
#
# Example:
#   set_mirror_x(true, false)
#
func set_mirror_x(mirror : bool = !MirrorX, emit : bool = true) -> void:
	MirrorX = mirror
	
	if emit: emit_signal('set_mirror_x', mirror)

signal set_mirror_y(mirror)
# true, editing operations will be mirrored over y-axis; false, editing operations won't be mirrored over y-axis
export(bool) var MirrorY : bool = false setget set_mirror_y
# Setter for MirrorX, emits 'set_mirror_y'
# mirror   :   bool   :   value to set
# emit     :   bool   :   true, emit signal; false, don't emit signal
#
# Example:
#   set_mirror_y(true, false)
#
func set_mirror_y(mirror : bool = !MirrorY, emit : bool = true) -> void:
	MirrorY = mirror
	
	if emit: emit_signal('set_mirror_y', mirror)

signal set_mirror_z(mirror)
# true, editing operations will be mirrored over z-axis; false, editing operations won't be mirrored over z-axis
export(bool) var MirrorZ : bool = false setget set_mirror_z
# Setter for MirrorX, emits 'set_mirror_z'
# mirror   :   bool   :   value to set
# emit     :   bool   :   true, emit signal; false, don't emit signal
#
# Example:
#   set_mirror_z(true, false)
#
func set_mirror_z(mirror : bool = !MirrorZ, emit : bool = true) -> void:
	MirrorZ = mirror
	
	if emit: emit_signal('set_mirror_z', mirror)


signal set_voxelset(voxelset)
# VoxelSet being used
var voxelset setget set_voxelset
# Setter for voxelset, emits 'set_voxelset'
# mirror   :   bool   :   value to set
# emit     :   bool   :   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxelset(true, false)
#
func set_voxelset(_voxelset = voxelset, emit : bool = true) -> void:
	voxelset = _voxelset
	
	if emit: emit_signal('set_voxelset', voxelset)

# NodePath to VoxelSet
# NOTE: When getting voxelset used call on voxelset, so as to avoid issues
export(NodePath) var VoxelSetPath : NodePath setget set_voxelset_path
# Setter for VoxelSetPath, emits 'set_voxelset'
# mirror   :   bool   :   value to set
# emit     :   bool   :   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxelset_path([NodePath], false)
#
func set_voxelset_path(voxelsetpath : NodePath, emit : bool = true) -> void:
	# TODO check if valid VoxelSet
	if true:
		VoxelSetPath = voxelsetpath
#		set_voxelset(get_node(voxelsetpath), emit)



# Abstract
# NOTE: The following needs to be implemented by inheritor
signal set_voxel(grid)
func set_voxel(grid : Vector3, voxel) -> void: return
func set_rvoxel(grid : Vector3, voxel) -> void: return

func get_voxel(grid : Vector3) -> Dictionary: return {}
func get_rvoxel(grid : Vector3): return

signal erased_voxel(grid)
func erase_voxel(grid : Vector3) -> void: return


signal set_voxels
func set_voxels(voxels : Dictionary) -> void: return

func get_voxels() -> Array: return []

signal erased_voxels
func erase_voxels() -> void: return


signal updated
func update() -> void: return

signal updated_staticbody
func update_staticbody() -> void: return
