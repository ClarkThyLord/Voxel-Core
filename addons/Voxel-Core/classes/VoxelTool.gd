tool
extends SurfaceTool
class_name VoxelTool, "res://addons/Voxel-Core/assets/classes/VoxelTool.png"



#
# VoxelTool, used to construct a Mesh with specified voxel data.
# It can be used to construct a Mesh from a script.
#



# Declarations
var _index := 0 setget set_index
func set_index(_index : int) -> void: pass


var VoxelUV := false setget set_voxel_uv
func set_voxel_uv(voxel_uv : bool) -> void: pass

var VoxelUVScale := 1.0 setget set_uv_scale
func set_uv_scale(voxel_uv_scale : float) -> void: pass


var VoxelSize := 0.5 setget set_voxel_size
func set_voxel_size(voxel_size : float) -> void: pass


var VoxelMaterial : SpatialMaterial = SpatialMaterial.new() setget set_voxel_material
func set_voxel_material(voxel_material : SpatialMaterial) -> void: pass

var Voxel_Set : VoxelSet = null setget set_voxel_set
func set_voxel_set(voxel_set : VoxelSet) -> void: pass



# Core
func _init():
	VoxelMaterial.vertex_color_use_as_albedo = true


func start(
	voxel_uv := false,
	voxel_set := Voxel_Set,
	voxel_size := Voxel.VoxelSize
	) -> void:
	_index = 0
	
	VoxelSize = voxel_size
	
	VoxelUV = voxel_uv
	Voxel_Set = voxel_set
	VoxelUVScale = Voxel_Set.UVScale if is_instance_valid(Voxel_Set) else 1
	
	if VoxelUV and is_instance_valid(Voxel_Set):
		VoxelMaterial.albedo_texture = Voxel_Set.Tiles
	
	begin(Mesh.PRIMITIVE_TRIANGLES)

func end() -> ArrayMesh:
	set_material(VoxelMaterial)
	return commit()


func add_face(
	voxel : Dictionary,
	normal : Vector3,
	bottom_right : Vector3,
	bottom_left := Vector3.INF,
	top_right := Vector3.INF,
	top_left := Vector3.INF
	) -> void:
	bottom_right = bottom_right
	if bottom_left == Vector3.INF: bottom_left = bottom_right
	if top_right == Vector3.INF: top_right = bottom_right
	if top_left == Vector3.INF: top_left = bottom_right
	
	add_normal(normal)
	add_color(Voxel.get_color_side(voxel, normal))
	
	var uv := Voxel.get_texture_side(voxel, normal) if VoxelUV else -Vector2.ONE
	
	match normal:
		Vector3.RIGHT:
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_right + Vector3.RIGHT) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_left + Vector3.RIGHT + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_right + Vector3.RIGHT + Vector3.UP) * VoxelSize)
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_left + Vector3.ONE) * VoxelSize)
		Vector3.LEFT:
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_right + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_left) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_right + Vector3.UP + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_left + Vector3.UP) * VoxelSize)
		Vector3.UP:
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_right + Vector3.ONE) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_left + Vector3.UP + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_right + Vector3.RIGHT + Vector3.UP) * VoxelSize)
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_left + Vector3.UP) * VoxelSize)
		Vector3.DOWN:
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_right + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_left  + Vector3.RIGHT + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_right) * VoxelSize)
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_left + Vector3.RIGHT) * VoxelSize)
		Vector3.FORWARD:
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_right) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_left + Vector3.RIGHT) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_right + Vector3.UP) * VoxelSize)
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_left + Vector3.RIGHT + Vector3.UP) * VoxelSize)
		Vector3.BACK:
			if VoxelUV: add_uv((uv + Vector2.ONE) * VoxelUVScale)
			add_vertex((bottom_right + Vector3.RIGHT + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.DOWN) * VoxelUVScale)
			add_vertex((bottom_left + Vector3.BACK) * VoxelSize)
			if VoxelUV: add_uv((uv + Vector2.RIGHT) * VoxelUVScale)
			add_vertex((top_right + Vector3.ONE) * VoxelSize)
			if VoxelUV: add_uv((uv) * VoxelUVScale)
			add_vertex((top_left + Vector3.UP + Vector3.BACK) * VoxelSize)
	
	_index += 4
	add_index(_index - 4)
	add_index(_index - 3)
	add_index(_index - 2)
	add_index(_index - 3)
	add_index(_index - 1)
	add_index(_index - 2)
