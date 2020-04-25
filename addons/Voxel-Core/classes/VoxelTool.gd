tool
extends SurfaceTool
class_name VoxelTool, "res://addons/Voxel-Core/assets/classes/VoxelTool.png"



#
# VoxelTool, 
#



# Declarations
var _index := 0 setget set_index
func set_index(_index : int) -> void: pass

export(bool) var VoxelUV := false setget set_voxel_uv
func set_voxel_uv(voxel_uv : bool) -> void: pass

export(float, 0, 100) var VoxelSize := 0.5 setget set_voxel_size
func set_voxel_size(voxel_size : float) -> void: pass



# Core
func start(voxel_uv := false, voxel_size := Voxel.VoxelSize) -> void:
	_index = 0
	VoxelUV = voxel_uv
	VoxelSize = voxel_size
	begin(Mesh.PRIMITIVE_TRIANGLES)

func end() -> Array:
	return commit_to_arrays()


func add_face(
	voxel : Dictionary,
	normal : Vector3,
	bottom_right_ : Vector3,
	bottom_left_ := Vector3.INF,
	top_right_ := Vector3.INF,
	top_left_ := Vector3.INF
	) -> void:
	bottom_right_ = bottom_right_
	if bottom_left_ == Vector3.INF: bottom_left_ = bottom_right_
	if top_right_ == Vector3.INF: top_right_ = bottom_right_
	if top_left_ == Vector3.INF: top_left_ = bottom_right_
	
	add_normal(normal)
	add_color(Voxel.get_color_side(voxel, normal))
	
	match normal:
		Vector3.RIGHT:
			add_vertex((bottom_right_ + Vector3.RIGHT) * VoxelSize)
			add_vertex((bottom_left_ + Vector3.RIGHT + Vector3.BACK) * VoxelSize)
			add_vertex((top_right_ + Vector3.RIGHT + Vector3.UP) * VoxelSize)
			add_vertex((top_left_ + Vector3.ONE) * VoxelSize)
		Vector3.LEFT:
			add_vertex((bottom_right_ + Vector3.BACK) * VoxelSize)
			add_vertex((bottom_left_) * VoxelSize)
			add_vertex((top_right_ + Vector3.UP + Vector3.BACK) * VoxelSize)
			add_vertex((top_left_ + Vector3.UP) * VoxelSize)
		Vector3.UP:
			add_vertex((bottom_right_ + Vector3.ONE) * VoxelSize)
			add_vertex((bottom_left_ + Vector3.UP + Vector3.BACK) * VoxelSize)
			add_vertex((top_right_ + Vector3.RIGHT + Vector3.UP) * VoxelSize)
			add_vertex((top_left_ + Vector3.UP) * VoxelSize)
		Vector3.DOWN:
			add_vertex((bottom_right_ + Vector3.BACK) * VoxelSize)
			add_vertex((bottom_left_  + Vector3.RIGHT + Vector3.BACK) * VoxelSize)
			add_vertex((top_right_) * VoxelSize)
			add_vertex((top_left_ + Vector3.RIGHT) * VoxelSize)
		Vector3.FORWARD:
			add_vertex((bottom_right_) * VoxelSize)
			add_vertex((bottom_left_ + Vector3.RIGHT) * VoxelSize)
			add_vertex((top_right_ + Vector3.UP) * VoxelSize)
			add_vertex((top_left_ + Vector3.RIGHT + Vector3.UP) * VoxelSize)
		Vector3.BACK:
			add_vertex((bottom_right_ + Vector3.RIGHT + Vector3.BACK) * VoxelSize)
			add_vertex((bottom_left_ + Vector3.BACK) * VoxelSize)
			add_vertex((top_right_ + Vector3.ONE) * VoxelSize)
			add_vertex((top_left_ + Vector3.UP + Vector3.BACK) * VoxelSize)
	
	_index += 4
	add_index(_index - 4)
	add_index(_index - 3)
	add_index(_index - 2)
	add_index(_index - 3)
	add_index(_index - 1)
	add_index(_index - 2)
