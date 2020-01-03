tool
extends "res://addons/Voxel-Core/src/VoxelMesh.gd"



# Declarations
var static_body
var static_body_shape
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


func update() -> void:
	if voxels.size() > 0:
		var ST = SurfaceTool.new()
		ST.begin(Mesh.PRIMITIVE_TRIANGLES)
		var material = SpatialMaterial.new()
		material.roughness = 1
		material.vertex_color_is_srgb = true
		material.vertex_color_use_as_albedo = true
		
		if UVMapping and VoxelSet and not VoxelSet.AlbedoTexture == null:
			material.albedo_texture = VoxelSet.AlbedoTexture
		
		ST.set_material(material)
		
		
		if editing or MeshType == MeshTypes.NAIVE:
			for voxel_grid in voxels:
				if UVMapping:
					if not voxels.has(voxel_grid + Vector3.RIGHT): Voxel.generate_right_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
					if not voxels.has(voxel_grid + Vector3.LEFT): Voxel.generate_left_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
					if not voxels.has(voxel_grid + Vector3.UP): Voxel.generate_up_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
					if not voxels.has(voxel_grid + Vector3.DOWN): Voxel.generate_down_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
					if not voxels.has(voxel_grid + Vector3.BACK): Voxel.generate_back_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
					if not voxels.has(voxel_grid + Vector3.FORWARD): Voxel.generate_forward_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
				else:
					if not voxels.has(voxel_grid + Vector3.RIGHT): Voxel.generate_right(ST, get_voxel(voxel_grid), voxel_grid)
					if not voxels.has(voxel_grid + Vector3.LEFT): Voxel.generate_left(ST, get_voxel(voxel_grid), voxel_grid)
					if not voxels.has(voxel_grid + Vector3.UP): Voxel.generate_up(ST, get_voxel(voxel_grid), voxel_grid)
					if not voxels.has(voxel_grid + Vector3.DOWN): Voxel.generate_down(ST, get_voxel(voxel_grid), voxel_grid)
					if not voxels.has(voxel_grid + Vector3.BACK): Voxel.generate_back(ST, get_voxel(voxel_grid), voxel_grid)
					if not voxels.has(voxel_grid + Vector3.FORWARD): Voxel.generate_forward(ST, get_voxel(voxel_grid), voxel_grid)
		elif MeshType == MeshTypes.GREEDY:
			var rights = []
			var right_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ]
			var lefts = []
			var left_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ]
			var ups = []
			var up_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT ]
			var downs = []
			var down_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT ]
			var backs = []
			var back_directions = [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ]
			var forwards = []
			var forward_directions = [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ]
			
			for voxel_grid in voxels:
				if is_valid_face(voxel_grid, Vector3.RIGHT, rights): rights = greed(ST, voxel_grid, Vector3.RIGHT, right_directions, rights)
				if is_valid_face(voxel_grid, Vector3.LEFT, lefts): lefts = greed(ST, voxel_grid, Vector3.LEFT, left_directions, lefts)
				if is_valid_face(voxel_grid, Vector3.UP, ups): ups = greed(ST, voxel_grid, Vector3.UP, up_directions, ups)
				if is_valid_face(voxel_grid, Vector3.DOWN, downs): downs = greed(ST, voxel_grid, Vector3.DOWN, down_directions, downs)
				if is_valid_face(voxel_grid, Vector3.BACK, backs): backs = greed(ST, voxel_grid, Vector3.BACK, back_directions, backs)
				if is_valid_face(voxel_grid, Vector3.FORWARD, forwards): forwards = greed(ST, voxel_grid, Vector3.FORWARD, forward_directions, forwards)
		
		ST.index()
		mesh = ST.commit()
#		call_deferred('set_mesh', _mesh)
	else: mesh = null
	update_static_body()

func update_static_body() -> void:
	if mesh and (editing or BuildStaticBody):
		if not static_body:
			static_body = StaticBody.new()
			add_child(static_body)
			static_body.set_name('StaticBody')
#			call_deferred('add_child', static_body)
			static_body_shape_id = static_body.create_shape_owner(static_body)
		
#		if not static_body_shape:
#			static_body_shape = CollisionShape.new()
#			static_body_shape.set_name('CollisionShape')
#			static_body.call_deferred('add_child', static_body_shape)
#			static_body.add_child(static_body_shape)
		
		var shape := ConcavePolygonShape.new()
		shape.set_faces(mesh.get_faces())
		static_body.shape_owner_clear_shapes(static_body_shape_id)
		static_body.shape_owner_add_shape(static_body_shape_id, shape)
#		static_body_shape.call_deferred('set_shape', mesh.create_trimesh_shape())
#		static_body_shape.shape = mesh.create_trimesh_shape()
		
#		if not has_node('StaticBody'): add_child(static_body)
	elif static_body:
		static_body.queue_free()
#		static_body.call_deferred('queue_free', static_body)
#		remove_child(static_body)
#		static_body.queue_free()
