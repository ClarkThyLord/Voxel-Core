tool
extends SurfaceTool
class_name VoxelTool, "res://addons/Voxel-Core/assets/classes/VoxelTool.png"
# Used to construct a voxel Mesh from specified voxel data.
# It can be used to construct a Mesh from a script.



## Declarations
# Index Mesh being generated is currently on
var _index := 0 setget set_index
# Prevent external modifications to _index
func set_index(_index : int) -> void: pass


# Quick access to VoxelUV
var VoxelUV := false setget set_voxel_uv
# Prevent external modifications to VoxelUV
func set_voxel_uv(voxel_uv : bool) -> void: pass

# Quick access to VoxelUVScale
var VoxelUVScale := Vector2.ONE setget set_uv_scale
# Prevent external modifications to VoxelUVScale
func set_uv_scale(voxel_uv_scale : Vector2) -> void: pass


# Quick access to VoxelSize
var VoxelSize := 0.5 setget set_voxel_size
# Prevent external modifications to VoxelSize
func set_voxel_size(voxel_size : float) -> void: pass


# SpatialMaterial used with genereated Meshes
var VoxelMaterial := SpatialMaterial.new()

# Quick access to VoxelSet
var VoxelSetRef : VoxelSet = null setget set_voxel_set
# Prevent external modifications to VoxelSetRef
func set_voxel_set(voxel_set : VoxelSet) -> void: pass



## Core
# Prepares material
func _init():
	VoxelMaterial.vertex_color_use_as_albedo = true


# Should be called first, starts the creation of a new voxel Mesh
func start(
	voxel_uv := false,
	voxel_set := VoxelSetRef,
	voxel_size := Voxel.VoxelSize
	) -> void:
	_index = 0
	
	VoxelSize = voxel_size
	
	VoxelUV = voxel_uv
	VoxelSetRef = voxel_set
	if is_instance_valid(VoxelSetRef) and VoxelSetRef.UVReady:
		VoxelUVScale = VoxelSetRef.UVScale
		if VoxelUV:
			VoxelMaterial.albedo_texture = VoxelSetRef.Tiles
	
	begin(Mesh.PRIMITIVE_TRIANGLES)

# Called once voxel Mesh has been generated
func end() -> ArrayMesh:
	set_material(VoxelMaterial)
	return commit()


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
	
	add_normal(face)
	add_color(Voxel.get_face_color(voxel, face))
	
	var uv := Voxel.get_face_texture(voxel, face) if VoxelUV else -Vector2.ONE
	
	match face:
		Vector3.RIGHT:
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_left + Vector3.RIGHT + Vector3.UP) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_left + Vector3.RIGHT) * VoxelSize)
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_right + Vector3.ONE) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_right + Vector3.RIGHT + Vector3.BACK) * VoxelSize)
		Vector3.LEFT:
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_left) * VoxelSize)
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_left + Vector3.UP) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_right + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_right + Vector3.UP + Vector3.BACK) * VoxelSize)
		Vector3.UP:
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_left + Vector3.UP + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_left + Vector3.UP) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_right + Vector3.ONE) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_right + Vector3.RIGHT + Vector3.UP) * VoxelSize)
		Vector3.DOWN:
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_right + Vector3.RIGHT + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_right + Vector3.RIGHT) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_left + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_left) * VoxelSize)
		Vector3.FORWARD:
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_right + Vector3.RIGHT) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_right + Vector3.RIGHT + Vector3.UP) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_left) * VoxelSize)
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_left + Vector3.UP) * VoxelSize)
		Vector3.BACK:
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_right + Vector3.ONE) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_right + Vector3.RIGHT + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_left + Vector3.UP + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_left + Vector3.BACK) * VoxelSize)
	
	_index += 4
	add_index(_index - 4)
	add_index(_index - 3)
	add_index(_index - 2)
	add_index(_index - 3)
	add_index(_index - 1)
	add_index(_index - 2)
