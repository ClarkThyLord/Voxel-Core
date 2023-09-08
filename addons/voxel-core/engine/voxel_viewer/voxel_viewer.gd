@tool
extends Control
## Voxel Viewer Class


# Public Variables
@export_range(-1, INF, 1, "or_greater")
var voxel_id : int = -1 :
	set = set_voxel_id

@export
var voxel_set : VoxelSet = null :
	set = set_voxel_set

@export_group("Camera")
@export_range(1, 100, 1)
var camera_sensitivity : int = 7

@export
var camera_environment : Environment = null :
	set = set_camera_environment



# Private Variables
@onready
var _highlights : Array[MeshInstance3D] = [
	%RightHighlight,
	%LeftHighlight,
	%TopHighlight,
	%BottomHighlight,
	%FrontHighlight,
	%BackHighlight
]

var _is_dragging : bool = false



# Built-In Virtual Methods
func _ready() -> void:
	for highlight in _highlights:
		highlight.visible = false


# Public Methods
func set_voxel_id(new_voxel_id : int) -> void:
	voxel_id = new_voxel_id
	
	if Engine.is_editor_hint():
		update()


## Sets [member voxel_set]; and, if in engine, calls on [method update].
func set_voxel_set(new_voxel_set : VoxelSet) -> void:
	voxel_set = new_voxel_set
	
	if is_instance_valid(%Voxel):
		%Voxel.set_voxel_set(voxel_set)
	
	if Engine.is_editor_hint():
		update()


func has_voxel_set() -> bool:
	return is_instance_valid(voxel_set)


func set_camera_environment(new_camera_environment : Environment) -> void:
	camera_environment = new_camera_environment
	
	if is_instance_valid(%Camera3D):
		%Camera3D.environment = camera_environment


func update() -> void:
	if not has_voxel_set():
		return
	
	%Voxel.erase_voxels()
	
	if is_instance_valid(voxel_set) and voxel_set.has_voxel_id(voxel_id):
		%Voxel.set_voxel(Vector3i.ZERO, voxel_id)
	
	%Voxel.update()



# Private Methods
func _get_highlight(voxel_face : Vector3i) -> MeshInstance3D:
	match voxel_face:
		Voxel.FACE_RIGHT:
			return %RightHighlight
		Voxel.FACE_LEFT:
			return %LeftHighlight
		Voxel.FACE_TOP:
			return %TopHighlight
		Voxel.FACE_BOTTOM:
			return %BottomHighlight
		Voxel.FACE_FRONT:
			return %FrontHighlight
		Voxel.FACE_BACK:
			return %BackHighlight
	return null


func _show_highlight(voxel_face : Vector3i) -> void:
	_get_highlight(voxel_face).visible = true


func _hide_highlight(voxel_face : Vector3i) -> void:
	_get_highlight(voxel_face).visible = false


func _on_sub_viewport_container_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.double_click:
			var camera_3d : Camera3D = %SubViewport.get_camera_3d()
			var direct_space_state : PhysicsDirectSpaceState3D = \
					%SubViewport.world_3d.direct_space_state
			var from : Vector3 = camera_3d.project_ray_origin(event.position)
			var normal : Vector3 = camera_3d.project_ray_normal(event.position)
			var to : Vector3 = from + normal * 100
			
			print(from, " ", normal, " ", to)
			
			var hit : Dictionary = %Voxel.raycast(from, normal, 10)
			
			print(%Voxel.world_position_to_voxel_position(from))
			print(hit)
			
			if hit.has("hit_voxel_face"):
				_show_highlight(hit["hit_voxel_face"])
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = event.pressed
	elif event is InputEventMouseMotion:
		if _is_dragging:
			var motion : Vector2 = event.relative.normalized()
			%CameraPivot.rotation_degrees.x += -motion.y * camera_sensitivity
			%CameraPivot.rotation_degrees.y += -motion.x * camera_sensitivity
