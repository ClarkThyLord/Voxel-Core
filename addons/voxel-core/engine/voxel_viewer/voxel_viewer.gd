@tool
extends Control
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
var camera_sensitivity : int = 8



# Private Variables
var _is_dragging : bool = false
 

# Public Methods
func set_voxel_id(new_voxel_id : int) -> void:
	voxel_id = new_voxel_id
	
	if Engine.is_editor_hint():
		update()


## Returns [member voxel_set].
func get_voxel_set() -> VoxelSet:
	return voxel_set


## Sets [member voxel_set]; and, if in engine, calls on [method update].
func set_voxel_set(new_voxel_set : VoxelSet) -> void:
	voxel_set = new_voxel_set
	
	if is_instance_valid(%Voxel):
		%Voxel.set_voxel_set(voxel_set)
	
	if Engine.is_editor_hint():
		update()


func update() -> void:
	%Voxel.erase_voxels()
	
	if voxel_id > -1:
		%Voxel.set_voxel(Vector3i.ZERO, voxel_id)
		
		%Voxel.update()



# Private Methods
func _on_sub_viewport_container_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = event.pressed
	elif event is InputEventMouseMotion:
		if _is_dragging:
			var motion : Vector2 = event.relative.normalized()
			%CameraPivot.rotation_degrees.x += -motion.y * camera_sensitivity
			%CameraPivot.rotation_degrees.y += -motion.x * camera_sensitivity
