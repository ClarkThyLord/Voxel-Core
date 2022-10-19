tool
class_name VoxelTool
extends Reference
# Used to construct a Mesh with provided VoxelSet 
# and by specifying voxel faces individually.



class Surface:
	## Public Variables
	# Index of the last vertex in Mesh being constructed
	var index : int
	
	var material : SpatialMaterial
	
	# SurfaceTool used to construct Mesh
	var surface_tool : SurfaceTool
	
	
	
	## Built-In Virtual Methods
	func _init() -> void:
		index = 0
		surface_tool = SurfaceTool.new()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)



## Private Variables
# Flag indicating whether uv mapping should be applied to constructed mesh
var _uv_voxels := false

# Contains Surfaces being constructed
var _surfaces := {}

# VoxelSet used when constructing Mesh, is set on begin
var _voxel_set : VoxelSet = null

# 0.5 means that voxels will have the dimensions of 0.5 x 0.5 x 0.5
var _voxel_size := 0.5


## Public Methods
# Set size of voxels
# 0.5 means that voxels will have the dimensions of 0.5 x 0.5 x 0.5
func set_voxel_size(size: float) -> void:
	_voxel_size = size


# Called before constructing mesh, takes the VoxelSet with which Mesh will be constructed
func begin(voxel_set : VoxelSet = null, uv_voxels := false) -> void:
	clear()
	_uv_voxels = uv_voxels and voxel_set.uv_ready()
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
				submesh)
		mesh.surface_set_name(mesh.get_surface_count() - 1, surface_id)
		mesh.surface_set_material(mesh.get_surface_count() - 1, surface.material)
	clear()
	return mesh


# Adds a voxel face to Mesh with given vertex positions and voxel data
# voxel          :   Dictionary<String, Variant>   :   voxel data to use
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
		top_left := Vector3.INF) -> void:
	bottom_right = bottom_right
	if bottom_left == Vector3.INF: bottom_left = bottom_right
	if top_right == Vector3.INF: top_right = bottom_right
	if top_left == Vector3.INF: top_left = bottom_right
	
	var color := Voxel.get_face_color(voxel, face)
	var uv : Vector2 = Voxel.get_face_uv(voxel, face) if _uv_voxels else -Vector2.ONE
	var uv_surface := uv != -Vector2.ONE
	
	var material := Voxel.get_material(voxel)
	
	var metal := Voxel.get_metallic(voxel)
	var specular := Voxel.get_specular(voxel)
	var rough := Voxel.get_roughness(voxel)
	var energy := Voxel.get_energy(voxel)
	var energy_color := Voxel.get_energy_color(voxel)
	
	var surface_id := str(material) if material > -1 else (str(metal) + "," + str(specular) + "," + str(rough) + "," + str(energy) + "," + str(energy_color))
	if uv_surface:
		surface_id += "_uv"
	var surface : Surface = _surfaces.get(surface_id)
	if not is_instance_valid(surface):
		surface = Surface.new()
		
		surface.material = _voxel_set.get_material(material) if is_instance_valid(_voxel_set) else null
		if is_instance_valid(surface.material):
			surface.material = surface.material.duplicate()
		else:
			surface.material = SpatialMaterial.new()
			
			surface.material.metallic = metal
			surface.material.metallic_specular = specular
			surface.material.roughness = rough
			if energy > 0.0:
				surface.material.emission_enabled = true
				surface.material.emission = energy_color
				surface.material.emission_energy = energy
		
		if surface.material is SpatialMaterial:
			surface.material.vertex_color_use_as_albedo = true
			surface.material.vertex_color_is_srgb = true
			if uv_surface:
				surface.material.albedo_texture = _voxel_set.tiles
		
		_surfaces[surface_id] = surface
	
	surface.surface_tool.add_normal(face)
	surface.surface_tool.add_color(color)
	
	match face:
		Vector3.RIGHT:
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.RIGHT) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_left + Vector3.RIGHT + Vector3.UP) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.ONE) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_left + Vector3.RIGHT) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_right + Vector3.ONE) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.DOWN) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_right + Vector3.RIGHT + Vector3.BACK) * _voxel_size)
		Vector3.LEFT:
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.DOWN) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_left) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_left + Vector3.UP) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.ONE) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_right + Vector3.BACK) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.RIGHT) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_right + Vector3.UP + Vector3.BACK) * _voxel_size)
		Vector3.UP:
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.DOWN) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_left + Vector3.UP + Vector3.BACK) *_voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_left + Vector3.UP) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.ONE) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_right + Vector3.ONE) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.RIGHT) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_right + Vector3.RIGHT + Vector3.UP) * _voxel_size)
		Vector3.DOWN:
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.DOWN) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_right + Vector3.RIGHT + Vector3.BACK) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_right + Vector3.RIGHT) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.ONE) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_left + Vector3.BACK) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.RIGHT) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_left) * _voxel_size)
		Vector3.FORWARD:
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.ONE) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_right + Vector3.RIGHT) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.RIGHT) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_right + Vector3.RIGHT + Vector3.UP) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.DOWN) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_left) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_left + Vector3.UP) * _voxel_size)
		Vector3.BACK:
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.RIGHT) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_right + Vector3.ONE) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.ONE) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_right + Vector3.RIGHT + Vector3.BACK) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((top_left + Vector3.UP + Vector3.BACK) * _voxel_size)
			if uv_surface:
				surface.surface_tool.add_uv((uv + Vector2.DOWN) * _voxel_set.uv_scale())
			surface.surface_tool.add_vertex((bottom_left + Vector3.BACK) * _voxel_size)
	
	surface.index += 4
	surface.surface_tool.add_index(surface.index - 4)
	surface.surface_tool.add_index(surface.index - 3)
	surface.surface_tool.add_index(surface.index - 2)
	surface.surface_tool.add_index(surface.index - 3)
	surface.surface_tool.add_index(surface.index - 1)
	surface.surface_tool.add_index(surface.index - 2)


# Adds all the faces of a voxel to Mesh at given position and with voxel data
# voxel   :   Dictioanry<String, Variant>   :   voxel data to use
# grid    :   Vector3                       :   voxel grid position of voxel
func add_faces(voxel : Dictionary, grid : Vector3) -> void:
	for face in Voxel.Faces:
		add_face(voxel, face, grid)
