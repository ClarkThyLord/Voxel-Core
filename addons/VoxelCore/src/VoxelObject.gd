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
# update   :   bool   -   call on update
# emit     :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_greedy(true, false)
#
func set_greedy(greedy : bool = !Greedy, update : bool = true, emit : bool = true) -> void:
	Greedy = greedy
	
	if update and is_inside_tree(): update(false, emit)
	if emit: emit_signal('set_greedy', Greedy)


signal set_static_body(staticbody)
# Create and maintain a trimesh static body
# NOTE: StaticBody updates with every update
export(bool) var Static_Body : bool = false setget set_static_body
# Setter for StaticBody, emits 'set_static_body'
# staticbody   :   bool   -   value to set
# update       :   bool   -   call on staticbody update
# emit         :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_static_body(true, false)
#
func set_static_body(staticbody : bool = !Static_Body, update : bool = true, emit : bool = true) -> void:
	Static_Body = staticbody
	
	if update and is_inside_tree(): update_staticbody(false, emit)
	if emit: emit_signal('set_static_body', Static_Body)


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
var voxelset : VoxelSet setget set_voxelset
# Setter for voxelset, emits 'set_voxelset'
# _voxelset   :   bool   -   value to set
# update      :   bool   -   call on update
# emit        :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxelset(true, false)
#
func set_voxelset(_voxelset = voxelset, update : bool = true, emit : bool = true) -> void:
	if voxelset == _voxelset: return;
	elif voxelset is VoxelSet: voxelset.disconnect('update', self, 'update')
	
	voxelset = _voxelset
	if not voxelset.is_connected('update', self, 'update'): voxelset.connect('update', self, 'update')
	
	if update and is_inside_tree(): update(false, emit)
	if emit: emit_signal('set_voxelset', voxelset)

# NodePath to VoxelSet
# NOTE: When getting voxelset used call on voxelset, so as to avoid issues
export(NodePath) var VoxelSetPath : NodePath = NodePath('/root/CoreVoxelSet') setget set_voxelset_path
# Setter for VoxelSetPath, emits 'set_voxelset'
# voxelsetpath   :   bool   -   value to set
# update         :   bool   -   call on update
# emit           :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxelset_path([NodePath], false)
#
func set_voxelset_path(voxelsetpath : NodePath, update : bool = true, emit : bool = true) -> void:
	# TODO clear voxeset
	if voxelsetpath.is_empty(): VoxelSetPath = voxelsetpath
	elif is_inside_tree() and has_node(voxelsetpath) and get_node(voxelsetpath) is VoxelSet:
		VoxelSetPath = voxelsetpath
		set_voxelset(get_node(voxelsetpath), update, emit)


var loaded : bool = false
func has_loaded() -> bool: return loaded



# Helper functions
# NOTE: The following don't need to be implemented by inheritor, but could
# Calculates the dimension of Voxels
# @returns   :   Vector3   -   dimension
func get_dimensions() -> Vector3:
	var dimensions : Vector3 = Vector3()
	
	var extremes : Array = get_extremes()
	
	if extremes.size() > 0: dimensions = extremes[1] - extremes[0] + Vector3.ONE
	
	return dimensions.abs()

# Calculates the extremes of Voxels
# @returns   :   Array<Vector3>   -   empty, no Voxels are present; size 2, index 0 is min extreme and index 1 is max extreme
func get_extremes() -> Array:
	var extremes = []
	
	var voxels : Array = get_voxels().keys()
	
	if voxels.size() > 0:
		var _min : Vector3 = voxels[0]
		var _max : Vector3 = voxels[0]
		
		for voxel_grid in voxels:
			if voxel_grid.x < _min.x: _min.x = voxel_grid.x
			if voxel_grid.y < _min.y: _min.y = voxel_grid.y
			if voxel_grid.z < _min.z: _min.z = voxel_grid.z
			
			if voxel_grid.x > _max.x: _max.x = voxel_grid.x
			if voxel_grid.y > _max.y: _max.y = voxel_grid.y
			if voxel_grid.z > _max.z: _max.z = voxel_grid.z
		
		extremes.append(_min)
		extremes.append(_max)
	
	return extremes

# Translates Voxels by given translation, emits 'set_voxels'
# translate   :   Vector3   -   translation
# update      :   bool      -   call on update
# emit        :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   translate([Vector3], false, false)
#
func _translate(translate : Vector3, update : bool = true, emit : bool = true) -> void:
	var voxels : Dictionary = get_voxels()
	
	if voxels.size() > 0:
		var _voxels = {}
		
		for voxel_grid in voxels: _voxels[voxel_grid + translate] = get_rvoxel(voxel_grid)
		
		set_voxels(_voxels, update, emit)

# Centers Voxels to origin, emits 'set_voxels'
# options   :   Dictionary   -   options to configure Center ::
#                                  above_axis   :   bool   - center Voxels above x and z axis
# update    :   bool         -   call on update
# emit      :   bool         -   true, emit signal; false, don't emit signal
#
# Example:
#   center({ ... }, false, false)
#
func center(options : Dictionary = {}, update : bool = true, emit : bool = true) -> void:
	var extremes : Array = get_extremes()
	
	if extremes.size() > 0:
		var dimensions = extremes[1] - extremes[0] + Vector3.ONE
		
		var center_point = (extremes[0] + dimensions / 2).floor()
		
		if options.get('above_axis', false): center_point.y += dimensions.y / 2 * -1
		
		var voxels = {}
		
		for voxel_grid in get_voxels(): voxels[(voxel_grid + (center_point * -1)).floor()] = get_rvoxel(voxel_grid)
		
		set_voxels(voxels, update, emit)



# Abstract
# NOTE: The following needs to be implemented by inheritor
# Load necessary data
func _load() -> void:
	if has_meta('voxelset_path'): set_voxelset_path(get_meta('voxelset_path'), false)

# Save necessary data
func _save() -> void:
	set_meta('voxelset_path', VoxelSetPath)


# The following will initialize the object as needed
func _init() -> void: _load()
func _ready() -> void:
	set_voxelset_path(VoxelSetPath, false)
	_load()


signal set_voxel(grid)
# Set Voxel as given to grid position, emits 'set_voxel'
# grid     :   Vector3          -   grid position to set Voxel to 
# voxel    :   int/Dictionary   -   Voxel to be set
# update   :   bool             -   call on update
# emit     :   bool             -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel(Vector(11, -34, 2), 3)         #   NOTE: This would store the Voxels ID
#   set_voxel(Vector(11, -34, 2), { ... })
#
func set_voxel(grid : Vector3, voxel, update : bool = false, emit : bool = true) -> void:
	if update: update(false, emit)
	if emit: emit_signal('set_voxel', grid)

# Set raw Voxel data to given grid position, emits 'set_voxel'
# grid     :   Vector3          -   grid position to set Voxel to 
# voxel    :   int/Dictionary   -   Voxel to be set
# update   :   bool             -   call on update
# emit     :   bool             -   true, emit signal; false, don't emit signal
#
# Example:
#   set_rvoxel(Vector(11, -34, 2), 3)         #   NOTE: This would store a copy of the Voxels present Dictionary within the VoxelSet, not the ID itself
#   set_rvoxel(Vector(11, -34, 2), { ... })
#
func set_rvoxel(grid : Vector3, voxel, update : bool = false, emit : bool = true) -> void:
	if typeof(voxel) == TYPE_INT: voxel = voxelset.get_voxel(voxel)
	
	set_voxel(grid, voxel, update, emit)

# Get Voxel data from grid position
# grid       :   Vector3      -   grid position to get Voxel from
# @returns   :   Dictionary   -   Voxel data
#
# Example:
#   get_voxel(Vector(11, -34, 2))   ->   { ... }
#
func get_voxel(grid : Vector3) -> Dictionary:
	var voxel = get_rvoxel(grid)
	
	if typeof(voxel) == TYPE_INT: voxel = voxelset.get_voxel(voxel)
	
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
# grid     :   Vector3   -   grid position to erase Voxel from
# update   :   bool      -   call on update
# emit     :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   erase_voxel(Vector(11, -34, 2), false)
#
func erase_voxel(grid : Vector3, update : bool = false, emit : bool = true) -> void:
	if update: update(false, emit)
	if emit: emit_signal('erased_voxel', grid)


signal set_voxels
# Clears and replaces all Voxels with given Voxels, emits 'set_voxels'
# voxels   :   Dictionary<Vector3, Voxel>   -   Voxels to set
# update   :   bool                         -   call on update
# emit     :   bool                         -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel({ ... })
#
func set_voxels(voxels : Dictionary, update : bool = true, emit : bool = true) -> void:
	erase_voxels(emit)
	
	for grid in voxels: set_voxel(grid, voxels[grid], false, emit)
	
	if update: update(false, emit)
	if emit: emit_signal('set_voxels')

# Gets all present Voxel positions
# @returns   :   Dictionary<Vector3, Voxel>   -   Dictionary containing grid positions, as keys, and Voxels, as values
#
# Example:
#   get_voxels()   ->   { ... }
#
func get_voxels() -> Dictionary: return {}

signal erased_voxels
# Erases all present Voxels, emits 'erased_voxels'
# emit     :   bool   -   true, emit signal; false, don't emit signal
# update   :   bool   -   call on update
#
# Example:
#   erase_voxels(false)
#
func erase_voxels(emit : bool = true, update : bool = true) -> void:
	var voxels = get_voxels()
	
	for grid in voxels: erase_voxel(grid, false, emit)
	
	if update: update(false, emit)
	if emit: emit_signal('erased_voxels')


signal updated
# Updates mesh and StaticBody, emits 'updated'
# temp   :   bool   -   true, build temporary StaticBody; false, don't build temporary StaticBody
# emit   :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   update(true, false)
#
func update(temp : bool = false, emit : bool = true) -> void:	
	if temp or Static_Body: update_staticbody(temp, emit)
	if emit: emit_signal('updated')
#	_save()

signal updated_staticbody
# Sets and updates static trimesh body, emits 'updated_staticbody'
# temp   :   bool   -   true, build temporary StaticBody; false, don't build temporary StaticBody
# emit   :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   update_staticbody(false)
#
func update_staticbody(temp : bool = false, emit : bool = true) -> void: if emit: emit_signal('updated_staticbody')
