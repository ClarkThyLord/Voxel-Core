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
var _began : bool = false

var _voxel_set : VoxelSet

var _voxel_size : float

var _voxels_tiled : bool

var _surfaces : Dictionary



# Public Methods
## Called before passing in any information.
func begin(voxel_set : VoxelSet, voxel_size : float = 0.25, voxels_tiled : bool = true) -> void:
	clear()
	_voxel_set = voxel_set
	_voxel_size = voxel_size
	_voxels_tiled = voxels_tiled
	_began = true


## Clear all information passed into the voxel surface tool so far.
func clear() -> void:
	_voxel_set = null
	_voxel_size = 0.25
	_voxels_tiled = true
	_surfaces.clear()
	_began = false


## Returns a constructed [ArrayMesh] from current information passed in. If an 
## existing [ArrayMesh] is passed in as an argument, will add extra surface(s) to
## the existing [ArrayMesh].
func commit(existing : ArrayMesh = null, flags : int = 0) -> ArrayMesh:
	if not _began:
		return
	return null


func add_face() -> void:
	if not _began:
		return
	pass


func add_faces() -> void:
	if not _began:
		return
	pass


## Passes in information from an existing
## [code]voxel_visualization_object[/code](e.g. [VoxelMeshInstance3D]) and
## returns a constructed [ArrayMesh]. Voxel mesh is generated using a
## [member VoxelMeshType] passed via [code]voxel_mesh_mode[/code]. Can
## delimitate voxels passed from voxel visualization object by passing a array
## of targeted [code]voxel_positions[/code](e.g. Array[ Vector3i ]).
## NOTE: Internally calls on [method clear].
func create_from(voxel_visualization_object, voxel_mesh_type : VoxelMeshType, voxel_positions : Array = []) -> ArrayMesh:
	begin(
			voxel_visualization_object.voxel_set,
			voxel_visualization_object.voxel_size,
			voxel_visualization_object.voxels_tiled)
	return null
