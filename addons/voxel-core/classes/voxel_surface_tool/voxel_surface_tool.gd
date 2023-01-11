@tool
class_name VoxelSurfaceTool
extends RefCounted
@icon("res://addons/voxel-core/classes/voxel_surface/voxel_surface.svg")
## Helper tool to create voxel geometry; used by Voxel-Core.



# Inner Classes
class Surface extends SurfaceTool:
	# Public Variables
	## Index of the last vertex added.
	var index : int
	
	
	
	# Built-In Virtual Methods
	func _init() -> void:
		index = 0
		begin(Mesh.PRIMITIVE_TRIANGLES)



# Enums
## Approaches for generating voxel meshes, each approach has its own advantage 
## and disadvantage; for more information visit:
## [url=http://web.archive.org/web/20200428085802/https://0fps.net/2012/06/30/meshing-in-a-minecraft-game/]Voxel Meshing[/url],
## [url=http://web.archive.org/web/20201112011204/https://www.gedge.ca/dev/2014/08/17/greedy-voxel-meshing]Greedy Voxel Meshing[/url]
## [br]
## - Brute meshing, no culling of voxel faces; renders all voxel faces
## regardless of obstruction. (worst optimized approach)
## [br]
## - Naive meshing, simple culling of voxel faces; only renders all non
## obstructed voxels. (best optimized approach for its execution cost)
## [br]
## - Greedy meshing, culls and merges similar voxel faces; renders all non
## obstructed voxels while reducing face count. (best used for static content,
## as its very costly to execute)
enum VoxelMeshType {
	BRUTE,
	NAIVE,
	GREEDY,
}



# Private Variables
var _began : bool = false

var _voxel_set : VoxelSet

var _voxel_size : float

var _voxels_tiled : bool

var _voxel_uv_scale : Vector2

var _surfaces : Dictionary



# Public Methods
## Called before passing in any information.
func begin(voxel_set : VoxelSet, voxel_size : float = 0.25, voxels_tiled : bool = false) -> void:
	clear()
	_voxel_set = voxel_set
	_voxel_size = voxel_size
	_voxels_tiled = voxels_tiled
	if _voxels_tiled:
		if is_instance_valid(voxel_set.tiles):
			if voxel_set.tile_dimensions == Vector2i.ZERO:
				_voxels_tiled = false
				printerr("Error: VoxelSet passed to VoxelSurfaceTool has invalid `tile_dimensions`")
			else:
				_voxel_uv_scale = Vector2.ONE / (voxel_set.tiles.get_size() / Vector2(voxel_set.tile_dimensions))
		else:
			_voxels_tiled = false
			printerr("Error: VoxelSet passed to VoxelSurfaceTool is missing `tiles`")
	_began = true


## Clear all information passed into the voxel surface tool so far.
func clear() -> void:
	_voxel_set = null
	_voxel_size = 0.25
	_voxels_tiled = false
	_voxel_uv_scale = Vector2.ZERO
	_surfaces.clear()
	_began = false


## Returns a constructed [ArrayMesh] from current information passed in. If an 
## existing [ArrayMesh] is passed in as an argument, will add extra surface(s) to
## the existing [ArrayMesh].
func commit(existing : ArrayMesh = null, flags : int = 0) -> ArrayMesh:
	if not _began:
		return
	return null


func add_face(voxel_position : Vector3i, voxel_id : int, voxel_face : Vector3i) -> void:
	if not _began:
		return
	
	var voxel : Voxel = _voxel_set.get_voxel(voxel_id)
	
	# Surface ID(e.g. "1")
	var surface_id : String = str(voxel.material_index)
	
	# Should Surface be tiled?
	var surface_tiled : bool = _voxels_tiled and voxel.has_face_tile(voxel_face)
	if surface_tiled:
		# Mark Surface ID as tiled(e.g. "1_tiled")
		surface_id += "_tiled"
	
	# Surface to which to add face to
	var surface : Surface
	if _surfaces.has(surface_id):
		surface = _surfaces[surface_id]
	else:
		surface = Surface.new()
		_voxel_set.format_material(
				_voxel_set.get_material_by_index(voxel.material_index))
		surface.set_material(
				_voxel_set.get_material_by_index(voxel.material_index))
		_surfaces[surface_id] = surface
	
	surface.set_normal(voxel_face)
	surface.set_color(voxel.color)
	
	match voxel_face:
		Voxel.FACE_RIGHT:
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.RIGHT) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.RIGHT + Vector3i.UP) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.ONE) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.RIGHT) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face)) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.ONE) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.DOWN) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.RIGHT + Vector3i.BACK) * _voxel_size)
		Voxel.FACE_LEFT:
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.DOWN) * _voxel_uv_scale)
			surface.add_vertex((voxel_position) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face)) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.UP) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.ONE) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.BACK) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.RIGHT) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.UP + Vector3i.BACK) * _voxel_size)
		Voxel.FACE_UP:
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.DOWN) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.UP + Vector3i.BACK) *_voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face)) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.UP) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.ONE) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.ONE) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.RIGHT) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.RIGHT + Vector3i.UP) * _voxel_size)
		Voxel.FACE_DOWN:
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.DOWN) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.RIGHT + Vector3i.BACK) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face)) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.RIGHT) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.ONE) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.BACK) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.RIGHT) * _voxel_uv_scale)
			surface.add_vertex((voxel_position) * _voxel_size)
		Voxel.FACE_FORWARD:
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.ONE) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.RIGHT) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.RIGHT) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.RIGHT + Vector3i.UP) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.DOWN) * _voxel_uv_scale)
			surface.add_vertex((voxel_position) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face)) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.UP) * _voxel_size)
		Voxel.FACE_BACK:
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.RIGHT) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.ONE) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.ONE) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.RIGHT + Vector3i.BACK) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face)) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.UP + Vector3i.BACK) * _voxel_size)
			if surface_tiled:
				surface.set_uv(Vector2(voxel.get_face_tile(voxel_face) + Vector2i.DOWN) * _voxel_uv_scale)
			surface.add_vertex((voxel_position + Vector3i.BACK) * _voxel_size)
	
	surface.index += 4
	surface.add_index(surface.index - 4)
	surface.add_index(surface.index - 3)
	surface.add_index(surface.index - 2)
	surface.add_index(surface.index - 3)
	surface.add_index(surface.index - 1)
	surface.add_index(surface.index - 2)


func add_faces(voxel_position : Vector3i, voxel_id : int) -> void:
	if not _began:
		return
	for voxel_face in Voxel.FACES:
		add_face(voxel_position, voxel_id, voxel_face)


## Passes in information from an existing
## [code]voxel_visualization_object[/code](e.g. [VoxelMeshInstance3D]) and
## returns a constructed [ArrayMesh]. Voxel mesh is generated using a
## [member VoxelMeshType] passed via [code]voxel_mesh_mode[/code]. Can
## delimitate voxels passed from [code]voxel_visualization_object[/code] by
## passing a array of targeted [code]voxel_positions[/code]
## (e.g. Array[ Vector3i ]).
## NOTE: Internally calls on [method clear] first.
func create_from(voxel_visualization_object, voxel_mesh_type : VoxelMeshType, voxel_positions : Array = []) -> ArrayMesh:
	begin(
			voxel_visualization_object.voxel_set,
			voxel_visualization_object.voxel_size,
			voxel_visualization_object.voxels_tiled)
	
	if voxel_positions.is_empty():
		voxel_positions = voxel_visualization_object.get_voxel_positions()
	
	match voxel_mesh_type:
		VoxelMeshType.BRUTE:
			for voxel_position in voxel_positions:
				var voxel_id : int = voxel_visualization_object.get_voxel_id(voxel_position)
				add_faces(voxel_position, voxel_id)
		VoxelMeshType.NAIVE:
			pass
		VoxelMeshType.GREEDY:
			pass
	
	return null
