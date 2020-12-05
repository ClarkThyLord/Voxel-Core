tool
extends "res://addons/Voxel-Core/classes/VoxelObject.gd"
class_name VoxelMesh, "res://addons/Voxel-Core/assets/classes/VoxelMesh.png"
# Basic voxel visualization object, best used for moderate amount of voxels



# Declarations
# Used voxels, Dictionary<Vector3, int>
var voxels := {}



# Core
func _save() -> void:
	set_meta("voxels", voxels)

func _load() -> void:
	if has_meta("voxels"):
		voxels = get_meta("voxels")
	._load()


func _init() -> void: call_deferred("_load")
func _ready() -> void: call_deferred("_load")


func empty() -> bool:
	return voxels.empty()


func set_voxel(grid : Vector3, voxel : int) -> void:
	voxels[grid] = voxel

func set_voxels(_voxels : Dictionary) -> void:
	erase_voxels()
	voxels = _voxels

func get_voxel_id(grid : Vector3) -> int:
	return voxels.get(grid, -1)

func get_voxels() -> Array:
	return voxels.keys()

func erase_voxel(grid : Vector3) -> void:
	voxels.erase(grid)

func erase_voxels() -> void:
	voxels.clear()


func update_mesh(save := true) -> void:
	if voxels.size() > 0:
		var vt := VoxelTool.new()
		var material = get_surface_material(0) if get_surface_material_count() > 0 else null
		
		match MeshModes.NAIVE if EditHint else MeshMode:
			MeshModes.GREEDY:
				mesh = greed_volume(voxels.keys(), vt)
			_:
				mesh = naive_volume(voxels.keys(), vt)
		
		mesh.surface_set_name(0, "voxels")
		set_surface_material(0, material)
	else: mesh = null
	.update_mesh(save)

func update_static_body() -> void:
	var staticbody = get_node_or_null("StaticBody")
	
	if (EditHint or EmbedStaticBody) and is_instance_valid(mesh):
		if not is_instance_valid(staticbody):
			staticbody = StaticBody.new()
			staticbody.set_name("StaticBody")
			add_child(staticbody)
		
		var collisionshape
		if staticbody.has_node("CollisionShape"):
			collisionshape = staticbody.get_node("CollisionShape")
		else:
			collisionshape = CollisionShape.new()
			collisionshape.set_name("CollisionShape")
			staticbody.add_child(collisionshape)
		collisionshape.shape = mesh.create_trimesh_shape()
		
		if EmbedStaticBody and not staticbody.owner: staticbody.set_owner(get_tree().get_edited_scene_root())
		elif not EmbedStaticBody and staticbody.owner: staticbody.set_owner(null)
		if EmbedStaticBody and not collisionshape.owner: collisionshape.set_owner(get_tree().get_edited_scene_root())
		elif not EmbedStaticBody and staticbody.owner: collisionshape.set_owner(null)
	elif is_instance_valid(staticbody):
		remove_child(staticbody)
		staticbody.queue_free()
