tool
extends "res://addons/VoxelCore/src/VoxelObject.gd"
class_name VoxelMesh, 'res://addons/VoxelCore/assets/VoxelMesh.png'



# Declarations
var voxels : Dictionary = {} setget set_voxels

# Core
func _load() -> void: voxels = get_meta('voxels') if has_meta('voxels') else {}
func _save() -> void: set_meta('voxels', voxels)


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
func set_voxel(grid : Vector3, voxel : Dictionary, update : bool = false, emit : bool = true) -> void:
	voxels[grid] = voxel
	
#	if update: update(emit)
#	if emit: emit_signal('set_voxel', grid)
	.set_voxel(grid, voxel, update, emit)

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
func set_rvoxel(grid : Vector3, voxel : Dictionary, update : bool = false, emit : bool = true) -> void:
	# TODO convert Voxel ID to Voxel data and set
#	if typeof(voxel) == TYPE_INT: pass
	
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
func get_rvoxel(grid : Vector3): voxels.get(grid)

# Erase Voxel from grid position, emits 'erased_voxel'
# grid     :   Vector3   -   grid position to erase Voxel from
# update   :   bool      -   call on update
# emit     :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   erase_voxel(Vector(11, -34, 2), false)
#
func erase_voxel(grid : Vector3, update : bool = false, emit : bool = true) -> void:
	voxels.erase(grid)
	
#	if update: update(emit)
#	if emit: emit_signal('erased_voxel', grid)
	.erase_voxel(grid, update, emit)


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
	
#	for grid in voxels: set_voxel(grid, voxels[grid], false, emit)
	voxels = voxels.duplicate(true)
	
	if update: update(emit)
	if emit: emit_signal('set_voxels')

# Gets all present Voxel positions
# @returns   :   Dictionary<Vector3, Voxel>   -   Dictionary containing grid positions, as keys, and Voxels, as values
#
# Example:
#   get_voxels()   ->   { ... }
#
func get_voxels() -> Dictionary: return voxels

# Erases all present Voxels, emits 'erased_voxels'
# emit     :   bool   -   true, emit signal; false, don't emit signal
# update   :   bool   -   call on update
#
# Example:
#   erase_voxels(false)
#
func erase_voxels(emit : bool = true, update : bool = true) -> void:
#	var voxels = get_voxels()
#
#	for grid in voxels: erase_voxel(grid, false, emit)
	voxels.clear()
	
	if update: update(emit)
	if emit: emit_signal('erased_voxels')


# Updates mesh and StaticBody, emits 'updated'
# emit       :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   update(false)
#
func update(emit : bool = true) -> void:
	if voxels.size() > 0:
		var ST = SurfaceTool.new()
		ST.begin(Mesh.PRIMITIVE_TRIANGLES)
		var material = SpatialMaterial.new()
		material.roughness = 1
		material.vertex_color_is_srgb = true
		material.vertex_color_use_as_albedo = true
		ST.set_material(material)
		
		for voxel_grid in voxels:
			if not voxels.has(voxel_grid + Vector3.RIGHT): Voxel.generate_right(ST, get_voxel(voxel_grid), voxel_grid)
			if not voxels.has(voxel_grid + Vector3.LEFT): Voxel.generate_left(ST, get_voxel(voxel_grid), voxel_grid)
			if not voxels.has(voxel_grid + Vector3.UP): Voxel.generate_up(ST, get_voxel(voxel_grid), voxel_grid)
			if not voxels.has(voxel_grid + Vector3.DOWN): Voxel.generate_down(ST, get_voxel(voxel_grid), voxel_grid)
			if not voxels.has(voxel_grid + Vector3.BACK): Voxel.generate_back(ST, get_voxel(voxel_grid), voxel_grid)
			if not voxels.has(voxel_grid + Vector3.FORWARD): Voxel.generate_forward(ST, get_voxel(voxel_grid), voxel_grid)
		
		ST.index()
		mesh = ST.commit()
	else: mesh = null
	
	update_staticbody(emit)
	
#	if StaticBody: update_staticbody(emit)
#	if emit: emit_signal('updated')
	.update(emit)
	_save()

# Sets and updates static trimesh body, emits 'updated_staticbody'
# emit       :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   update_staticbody(false)
#
func update_staticbody(emit : bool = true) -> void:
	var staticbody
	if has_node('StaticBody'): staticbody = get_node('StaticBody')
	
	if Static_Body and mesh and voxels.size() > 0:
		var collisionshape
		if !staticbody:
			staticbody = StaticBody.new()
			staticbody.set_name('StaticBody')
		
		if staticbody.has_node('CollisionShape'):
			collisionshape = staticbody.get_node('CollisionShape')
		else:
			collisionshape = CollisionShape.new()
			collisionshape.set_name('CollisionShape')
		
			staticbody.add_child(collisionshape)
		
		collisionshape.shape = mesh.create_trimesh_shape()
		
		if !has_node('StaticBody'): add_child(staticbody)
		
		if Static_Body and !staticbody.owner: staticbody.set_owner(get_tree().get_edited_scene_root())
		if Static_Body and !collisionshape.owner: collisionshape.set_owner(get_tree().get_edited_scene_root())
	elif (!Static_Body or voxels.size() <= 0) and staticbody:
		remove_child(staticbody)
		staticbody.queue_free()
	
	
#	if emit: emit_signal('updated_staticbody')
	.update_staticbody(emit)
