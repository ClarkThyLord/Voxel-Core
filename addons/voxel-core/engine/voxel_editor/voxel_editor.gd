@tool
extends VBoxContainer
## Voxel Viewer Class



# Public Variables
@export
var voxel_id : int = -1 :
	set = set_voxel_id

@export
var voxel_set : VoxelSet = null :
	get = get_voxel_set,
	set = set_voxel_set

@export_range(1, 100, 1)
var camera_sensitivity : int = 8 :
	set = set_camera_sensitivity



# Private Variables
var _is_dragging : bool = false



# Public Methods
func set_voxel_id(new_voxel_id : int) -> void:
	voxel_id = new_voxel_id
	
	if is_instance_valid(%VoxelViewer):
		%VoxelViewer.voxel_id = voxel_id


func set_camera_sensitivity(new_camera_sensitivity : int) -> void:
	camera_sensitivity = new_camera_sensitivity
	
	if is_instance_valid(%VoxelViewer):
		%VoxelViewer.camera_sensitivity = camera_sensitivity


## Returns [member voxel_set].
func get_voxel_set() -> VoxelSet:
	return voxel_set


## Sets [member voxel_set]; and, if in engine, calls on [method update].
func set_voxel_set(new_voxel_set : VoxelSet) -> void:
	voxel_set = new_voxel_set
	
	if is_instance_valid(%VoxelViewer):
		%VoxelViewer.voxel_set = voxel_set


func edit_voxel(voxel_set : VoxelSet, voxel_id : int) -> void:
	set_voxel_set(voxel_set)
	set_voxel_id(voxel_id)
