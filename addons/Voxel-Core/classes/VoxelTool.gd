tool
extends SurfaceTool
class_name VoxelTool, "res://addons/Voxel-Core/assets/classes/VoxelTool.png"



#
# VoxelTool, 
#



# Declarations
export(bool) var VoxelUV := false setget set_voxel_uv
func set_voxel_uv(voxel_uv : bool) -> void: pass

export(float, 0, 100) var VoxelSize := 0.5 setget set_voxel_size
func set_voxel_size(voxel_size : float) -> void: pass



# Core
func start(voxel_uv := false, voxel_size := Voxel.VoxelSize) -> void:
	VoxelUV = voxel_uv
	VoxelSize = voxel_size
	begin(Mesh.PRIMITIVE_TRIANGLES)

func end() -> Array:
	return commit_to_arrays()


func add_face(
	voxel : Dictionary,
	normal : Vector3,
	top_left : Vector3,
	top_right := Vector3.INF,
	bottom_left := Vector3.INF,
	bottom_right := Vector3.INF
	) -> void:
	top_left = Voxel.grid_to_snapped(top_left)
	if top_right == Vector3.INF: top_right = top_left
	else: top_right = Voxel.grid_to_snapped(top_right)
	if bottom_left == Vector3.INF: bottom_left = top_left
	else: bottom_left = Voxel.grid_to_snapped(bottom_left)
	if bottom_right == Vector3.INF: bottom_right = top_left
	else: bottom_right = Voxel.grid_to_snapped(bottom_right)
	
	add_normal(normal)
	add_color(Voxel.get_color_side(voxel, normal))
	
	match normal:
		Vector3.RIGHT:
			add_vertex(top_left + Vector3.RIGHT)
			
			add_vertex(top_right + Vector3.RIGHT + Vector3.BACK)
			
			add_vertex(bottom_left + Vector3.RIGHT + Vector3.UP)
			
			
			add_vertex(top_right + Vector3.RIGHT + Vector3.BACK)
			
			add_vertex(bottom_right + Vector3.ONE)
			
			add_vertex(bottom_left + Vector3.RIGHT + Vector3.UP)
		Vector3.LEFT:
			add_vertex(bottom_right + Vector3.UP + Vector3.BACK)
			
			add_vertex(top_right + Vector3.BACK)
			
			add_vertex(bottom_left + Vector3.UP)
			
			
			add_vertex(top_right + Vector3.BACK)
			
			add_vertex(top_left)
			
			add_vertex(bottom_left + Vector3.UP)
		Vector3.UP:
			add_vertex(bottom_right + Vector3.ONE)
			
			add_vertex(top_right + Vector3.UP + Vector3.BACK)
			
			add_vertex(bottom_left + Vector3.RIGHT + Vector3.UP)
			
			
			add_vertex(top_right + Vector3.UP + Vector3.BACK)
			
			add_vertex(top_left + Vector3.UP)
			
			add_vertex(bottom_left + Vector3.RIGHT + Vector3.UP)
		Vector3.DOWN:
			add_vertex(top_left)
			
			add_vertex(top_right + Vector3.BACK)
			
			add_vertex(bottom_left + Vector3.RIGHT)
			
			
			add_vertex(top_right + Vector3.BACK)
			
			add_vertex(bottom_right + Vector3.RIGHT + Vector3.BACK)
			
			add_vertex(bottom_left + Vector3.RIGHT)
		Vector3.FORWARD:
			add_vertex(top_left)
			
			add_vertex(top_right + Vector3.RIGHT)
			
			add_vertex(bottom_left + Vector3.UP)
			
			
			add_vertex(top_right + Vector3.RIGHT)
			
			add_vertex(bottom_right + Vector3.RIGHT + Vector3.UP)
			
			add_vertex(bottom_left + Vector3.UP)
		Vector3.BACK:
			add_vertex(bottom_right + Vector3.ONE)
			
			add_vertex(top_right + Vector3.RIGHT + Vector3.BACK)
			
			add_vertex(bottom_left + Vector3.UP + Vector3.BACK)
			
			
			add_vertex(top_right + Vector3.RIGHT + Vector3.BACK)
			
			add_vertex(top_left + Vector3.BACK)
			
			add_vertex(bottom_left + Vector3.UP + Vector3.BACK)
