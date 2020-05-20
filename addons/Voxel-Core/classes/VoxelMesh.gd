tool
extends "res://addons/Voxel-Core/classes/VoxelObject.gd"
class_name VoxelMesh, "res://addons/Voxel-Core/assets/classes/VoxelMesh.png"



#
# VoxelMesh, the most basic VoxelObject, should be
# used for relatively small amounts of voxels.
#



# Declarations
var voxels := {}



# Core
func _save() -> void:
	set_meta("voxels", voxels)

func _load() -> void:
	if has_meta("voxels"):
		voxels = get_meta("voxels")
		._load()
	voxels = {
		Vector3.ZERO: Voxel.colored(Color.red),
		Vector3(1, 0, 0): Voxel.colored(Color.white)
	}
	._load()


func _init() -> void: _load()
func _ready() -> void: _load()


func set_voxel(grid : Vector3, voxel) -> void:
	match typeof(voxel):
		TYPE_INT, TYPE_DICTIONARY:
			voxels[grid] = voxel
		_:
			printerr("invalid voxel set")

func set_rvoxel(grid : Vector3, voxel) -> void:
	match typeof(voxel):
		TYPE_INT, TYPE_STRING:
			voxel = Voxel_Set.get_voxel(voxel)
	set_voxel(grid, voxel)

func set_voxels(voxels : Dictionary) -> void:
	erase_voxels()
	voxels = voxels

func get_voxel(grid : Vector3) -> Dictionary:
	var voxel = get_rvoxel(grid)
	match typeof(voxel):
		TYPE_INT, TYPE_STRING:
			voxel = Voxel_Set.get_voxel(voxel)
	return voxel

func get_rvoxel(grid : Vector3):
	return voxels.get(grid)

func get_voxels() -> Array:
	return voxels.keys()

func erase_voxel(grid : Vector3) -> void:
	voxels.erase(grid)

func erase_voxels() -> void:
	voxels.clear()


func update_mesh(save := true) -> void:
	var vt := VoxelTool.new()
	var material = get_surface_material(0) if get_surface_material_count() > 0 else null
	
	vt.start(
		UVMapping,
		Voxel_Set,
		Voxel.VoxelSize
	)
	
	match MeshMode:
		MeshModes.NAIVE:
			for grid in voxels:
				for direction in Voxel.Directions:
					if not voxels.has(grid + direction):
						vt.add_face( voxels[grid], direction, grid)
	
	mesh = vt.end()
	mesh.surface_set_name(0, "voxels")
	set_surface_material(0, material)
	.update_mesh(save)

func update_static_body() -> void:
	var staticbody
	if has_node('StaticBody'):
		staticbody = get_node('StaticBody')
	
	if (EditHint or EmbedStaticBody) and mesh:
		if not staticbody:
			staticbody = StaticBody.new()
			staticbody.set_name('StaticBody')
		
		var collisionshape
		if staticbody.has_node('CollisionShape'):
			collisionshape = staticbody.get_node('CollisionShape')
		else:
			collisionshape = CollisionShape.new()
			collisionshape.set_name('CollisionShape')
			staticbody.add_child(collisionshape)
		
		collisionshape.shape = mesh.create_trimesh_shape()
		
		if not has_node('StaticBody'): add_child(staticbody)
		
		if EmbedStaticBody and not staticbody.owner: staticbody.set_owner(get_tree().get_edited_scene_root())
		elif not EmbedStaticBody and staticbody.owner: staticbody.set_owner(null)
		if EmbedStaticBody and not collisionshape.owner: collisionshape.set_owner(get_tree().get_edited_scene_root())
		elif not EmbedStaticBody and staticbody.owner: collisionshape.set_owner(null)
	elif is_instance_valid(staticbody):
		remove_child(staticbody)
		staticbody.queue_free()
