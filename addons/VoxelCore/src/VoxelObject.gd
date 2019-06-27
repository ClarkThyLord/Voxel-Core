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
# lock   :   bool   -   value to set
# emit   :   bool   -   true, emit signal; false, don't emit signal
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
# greedy   :   bool   -   value to set
# emit     :   bool   -   true, emit signal; false, don't emit signal
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
# staticbody   :   bool   -   value to set
# emit         :   bool   -   true, emit signal; false, don't emit signal
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
# mirror   :   bool   -   value to set
# emit     :   bool   -   true, emit signal; false, don't emit signal
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
# Setter for MirrorY, emits 'set_mirror_y'
# mirror   :   bool   -   value to set
# emit     :   bool   -   true, emit signal; false, don't emit signal
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
# Setter for MirrorZ, emits 'set_mirror_z'
# mirror   :   bool   -   value to set
# emit     :   bool   -   true, emit signal; false, don't emit signal
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
# _voxelset   :   bool   -   value to set
# emit        :   bool   -   true, emit signal; false, don't emit signal
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
# voxelsetpath   :   bool   -   value to set
# emit           :   bool   -   true, emit signal; false, don't emit signal
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
# Set Voxel as given to grid position, emits 'set_voxel'
# grid    :   Vector3          -   grid position to set Voxel to 
# voxel   :   int/Dictionary   -   Voxel to be set
# emit    :   bool   :   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel(Vector(11, -34, 2), 3)         #   NOTE: This would store the Voxels ID
#   set_voxel(Vector(11, -34, 2), { ... })
#
func set_voxel(grid : Vector3, voxel, emit : bool = true) -> void: if emit: emit_signal('set_voxel', grid)

# Set raw Voxel data to given grid position, emits 'set_voxel'
# grid    :   Vector3          -   grid position to set Voxel to 
# voxel   :   int/Dictionary   -   Voxel to be set
# emit    :   bool             -   true, emit signal; false, don't emit signal
#
# Example:
#   set_rvoxel(Vector(11, -34, 2), 3)         #   NOTE: This would store a copy of the Voxels present Dictionary within the VoxelSet, not the ID itself
#   set_rvoxel(Vector(11, -34, 2), { ... })
#
func set_rvoxel(grid : Vector3, voxel, emit : bool = true) -> void:
	# TODO convert Voxel ID to Voxel data and set
#	if typeof(voxel) == TYPE_INT: pass
	
	set_voxel(grid, voxel, emit)

# Get Voxel data from grid position
# grid       :   Vector3      -   grid position to get Voxel from
# @returns   :   Dictionary   -   Voxel data
#
# Example:
#   get_voxel(Vector(11, -34, 2))   ->   { ... }
#
func get_voxel(grid : Vector3) -> Dictionary:
	var voxel = get_rvoxel(grid)
	
	# TODO retrieve Voxel data from ID
#	if typeof(voxel) == TYPE_INT: pass
	
	return voxel

# Get raw Voxel from grid position
# grid       :   Vector3          -   grid position to get Voxel from
# @returns   :   int/Dictionary   -   raw Voxel
#
# Example:
#   get_rvoxel(Vector(11, -34, 2))   ->   3         #   NOTE: Returned ID representing  Voxel data
#   get_rvoxel(Vector(-7, 0, 96))    ->   { ... }   #   NOTE: Returned Voxel data
#
func get_rvoxel(grid : Vector3): return

signal erased_voxel(grid)
# Erase Voxel from grid position, emits 'erased_voxel'
# grid       :   Vector3   -   grid position to erase Voxel from
# emit       :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   erase_voxel(Vector(11, -34, 2), false)
#
func erase_voxel(grid : Vector3, emit : bool = true) -> void: if emit: emit_signal('erased_voxel', grid)


signal set_voxels
# Clears and replaces all Voxels with given Voxels, emits 'set_voxels'
# voxels   :   Dictionary<Vector3, Voxel>   -   Voxels to set
# emit     :   bool                         -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel({ ... })
#
func set_voxels(voxels : Dictionary, emit : bool = true) -> void: if emit: emit_signal('set_voxels')

# Gets all present Voxel positions
# @returns   :   Array<Vector3>   -   Array containing positions for all Voxels present
#
# Example:
#   get_voxels() -> [ ... ]
#
func get_voxels() -> Array: return []

signal erased_voxels
# Erases all present Voxels, emits 'erased_voxels'
# emit       :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   erase_voxels(false)
#
func erase_voxels(emit : bool = true) -> void: if emit: emit_signal('erased_voxels')


signal updated
# Updates mesh and StaticBody, emits 'updated'
# emit       :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   update(false)
#
func update(emit : bool = true) -> void:
	if StaticBody: update_staticbody(emit)
	if emit: emit_signal('updated')

signal updated_staticbody
# Sets and updates static trimesh body, emits 'updated_staticbody'
# emit       :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   update_staticbody(false)
#
func update_staticbody(emit : bool = true) -> void: if emit: emit_signal('updated_staticbody')
