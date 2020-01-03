tool
extends "res://addons/Voxel-Core/src/VoxelMesh.gd"



# Declarations
var static_body
var static_body_shape_id



# Core
func _load() -> void: pass
func _save() -> void: pass
func _init() -> void: pass
func _ready() -> void: pass


func get_rvoxel(grid : Vector3):
	return voxels.get(grid)

func get_voxels() -> Dictionary:
	return voxels


func set_voxel(grid : Vector3, voxel, update := false) -> void:
	voxels[grid] = voxel

func set_voxels(_voxels : Dictionary, update := true) -> void:
	voxels = _voxels


func erase_voxel(grid : Vector3, update := false) -> void:
	voxels.erase(grid)

func erase_voxels(update : bool = true) -> void:
	voxels.clear()


func update_static_body() -> void:
	if mesh and (editing or BuildStaticBody):
		if not static_body:
			static_body = StaticBody.new()
			add_child(static_body)
			static_body.set_name('StaticBody')
			static_body_shape_id = static_body.create_shape_owner(static_body)
		
		var shape := ConcavePolygonShape.new()
		shape.set_faces(mesh.get_faces())
		static_body.shape_owner_clear_shapes(static_body_shape_id)
		static_body.shape_owner_add_shape(static_body_shape_id, shape)
	elif static_body: static_body.queue_free()
