@tool
class_name VoxelSurfaceTool
extends RefCounted
@icon("res://addons/voxel-core/classes/voxel_surface_tool/voxel_surface_tool.svg")
## Helper tool to create voxel geometry; used by Voxel-Core.



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
var _surfaces : Array[SurfaceTool] = []

var _voxel_size : float = 0.25

var _voxels_tiled : bool = true

var _voxel_set : VoxelSet



# Public Methods
func set_voxel_size(new_voxel_size : float) -> void:
	pass


func set_voxels_tiled(new_voxels_tiled : bool) -> void:
	pass


## Called before adding any voxels.
func begin(voxel_set : VoxelSet) -> void:
	pass


## Clear all information passed into the voxel surface tool so far.
func clear() -> void:
	pass


## Returns a constructed ArrayMesh from current information passed in. If an 
## existing ArrayMesh is passed in as an argument, will add extra surface(s) to
## the existing ArrayMesh.
func commit(existing : ArrayMesh = null, flags : int = 0) -> ArrayMesh:
	return null


func add_face() -> void:
	pass


func add_faces() -> void:
	pass


## Creates a vertex array from an existing voxel visualization object. 
## (e.g. [VoxelMeshInstance3D]).
func create_from(voxel_object, voxel_mesh_mode : VoxelMeshType, voxel_positions : Array = []) -> void:
func create_from(voxel_object, voxel_mesh_type : VoxelMeshType, voxel_positions : Array = []) -> void:
	pass
