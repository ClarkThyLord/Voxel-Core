tool
class_name VoxelTool, "res://addons/Voxel-Core/assets/classes/VoxelTool.png"
extends Reference
# Used to construct a Mesh with provided VoxelSet 
# and by specifying voxel faces individually.



class Surface:
	## Properties
	# Last vertex index of Mesh being constructed
	var index : int
	
	var material : SpatialMaterial
	
	# SurfaceTool used when constructing Surface
	var surface_tool : SurfaceTool
	
	
	## Methods
	func _init() -> void:
		index = 0
		surface_tool = SurfaceTool.new()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)



## Properties
# Flag indicating whether Mesh being constructed should have UV
var _uv_voxels := false setget set_uv_voxels
# Prevents external modifications of _uv_voxels
func set_uv_voxels(value : bool) -> void: pass

# Contains Surfaces being constructed
var _surfaces := {}
# Prevents external modifications of _surface_tools
func set_surface_tools(value : Dictionary) -> void: pass


# VoxelSet used when constructing Mesh, is set on begin
var _voxel_set : VoxelSet = null setget set_voxel_set
# Prevent external modifications of _voxel_set
func set_voxel_set(value : VoxelSet) -> void: pass



## Core
# Called before constructing mesh, takes the VoxelSet with which Mesh will be constructed
func begin(voxel_set : VoxelSet = null, uv_voxels := false) -> void:
	clear()
	_uv_voxels = uv_voxels and voxel_set.UVReady
	_voxel_set = voxel_set

# Clear all information
func clear() -> void:
	_uv_voxels = false
	_surfaces.clear()
	_voxel_set = null

# Returns a constructed ArrayMesh
func commit() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	for surface_id in _surfaces:
		var surface : Surface = _surfaces[surface_id]
		var submesh = surface.surface_tool.commit_to_arrays()
		mesh.add_surface_from_arrays(
			Mesh.PRIMITIVE_TRIANGLES,
			submesh
		)
		mesh.surface_set_name(mesh.get_surface_count() - 1, surface_id)
		mesh.surface_set_material(mesh.get_surface_count() - 1, surface.material)
	clear()
	return mesh


# Adds a voxel face to Mesh with given position, dimensions and voxel data
# voxel          :   Dictioanry<String, Variant>   :   voxel data to use
# face           :   Vector3                       :   face of voxel to generate
# bottom_right   :   Vector3                       :   grid position of bottom right vertex pertaining to face
# bottom_left    :   Vector3                       :   grid position of bottom left vertex pertaining to face, if not given botttom right is used
# top_right      :   Vector3                       :   grid position of top right vertex pertaining to face, if not given botttom right is used
# top_left       :   Vector3                       :   grid position of top left vertex pertaining to face, if not given botttom right is used
func add_face(
	voxel : Dictionary,
	face : Vector3,
	bottom_right : Vector3,
	bottom_left := Vector3.INF,
	top_right := Vector3.INF,
	top_left := Vector3.INF
	) -> void:
	bottom_right = bottom_right
	if bottom_left == Vector3.INF: bottom_left = bottom_right
	if top_right == Vector3.INF: top_right = bottom_right
	if top_left == Vector3.INF: top_left = bottom_right
	
	var color := Voxel.get_face_color(voxel, face)
	var uv := Voxel.get_face_texture(voxel, face) if _uv_voxels else -Vector2.ONE
	
	var metal : float = 0
	var specular : float = 0.5
	var rough : float = 1
	var energy : float = 10
	
	var surface_id := str(metal) + "," + str(specular) + "," + str(rough) + "," + str(energy)
	var surface : Surface = _surfaces.get(surface_id)
	if not is_instance_valid(surface):
		surface = Surface.new()
		var material := SpatialMaterial.new()
		
		material.albedo_color = color
		if _uv_voxels:
			material.albedo_texture = _voxel_set.Tiles
		
		material.metallic = metal
		material.metallic_specular = specular
		material.roughness = rough
		if energy > 0.0:
			material.emission_enabled = true
			material.emission = color
			material.emission_energy = energy
		
		surface.material = material
		_surfaces[surface_id] = surface
	
	surface.surface_tool.add_normal(face)
	surface.surface_tool.add_color(color)
	
	match face:
		Vector3.RIGHT:
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.RIGHT) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_left + Vector3.RIGHT + Vector3.UP) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.ONE) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_left + Vector3.RIGHT) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_right + Vector3.ONE) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.DOWN) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_right + Vector3.RIGHT + Vector3.BACK) * Voxel.VoxelSize)
		Vector3.LEFT:
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.DOWN) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_left) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_left + Vector3.UP) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.ONE) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_right + Vector3.BACK) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.RIGHT) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_right + Vector3.UP + Vector3.BACK) * Voxel.VoxelSize)
		Vector3.UP:
			if _uv_voxels: surface.surface_tool.add_uv((uv) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_left + Vector3.UP + Vector3.BACK) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.DOWN) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_left + Vector3.UP) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.RIGHT) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_right + Vector3.ONE) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.ONE) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_right + Vector3.RIGHT + Vector3.UP) * Voxel.VoxelSize)
		Vector3.DOWN:
			if _uv_voxels: surface.surface_tool.add_uv((uv) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_right + Vector3.RIGHT + Vector3.BACK) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.DOWN) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_right + Vector3.RIGHT) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.RIGHT) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_left + Vector3.BACK) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.ONE) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_left) * Voxel.VoxelSize)
		Vector3.FORWARD:
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.ONE) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_right + Vector3.RIGHT) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.RIGHT) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_right + Vector3.RIGHT + Vector3.UP) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.DOWN) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_left) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_left + Vector3.UP) * Voxel.VoxelSize)
		Vector3.BACK:
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.RIGHT) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_right + Vector3.ONE) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.ONE) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_right + Vector3.RIGHT + Vector3.BACK) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((top_left + Vector3.UP + Vector3.BACK) * Voxel.VoxelSize)
			if _uv_voxels: surface.surface_tool.add_uv((uv + Vector2.DOWN) * Voxel.VoxelSize)
			surface.surface_tool.add_vertex((bottom_left + Vector3.BACK) * Voxel.VoxelSize)
	
	surface.index += 4
	surface.surface_tool.add_index(surface.index - 4)
	surface.surface_tool.add_index(surface.index - 3)
	surface.surface_tool.add_index(surface.index - 2)
	surface.surface_tool.add_index(surface.index - 3)
	surface.surface_tool.add_index(surface.index - 1)
	surface.surface_tool.add_index(surface.index - 2)
