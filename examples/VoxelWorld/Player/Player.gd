extends KinematicBody



## Exported Variables
export(float, 0.0, 100.0) var speed := 12.0

export(float, -100.0, 100.0) var gravity := -9.81

export(float, 0.0, 10.0) var camera_sensitivity := 5.0

export(NodePath) var world_path setget set_world_path



## Private Variables
var _world : VoxelMesh = null

var _cursor_normal := Vector3()

var _cursor_position := Vector3()



## OnReady Variables
onready var camera : Camera = get_node("Camera")

onready var raycast : RayCast = get_node("Camera/RayCast")

onready var cursor : MeshInstance = get_node("Cursor")



## Built-In Virtual Methods
func _ready() -> void:
	set_world_path(world_path)
	cursor.visible = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and not event.is_pressed():
			Input.set_mouse_mode(
					Input.MOUSE_MODE_CAPTURED
					if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE
					else Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			return
		
		var movement : Vector2 = event.relative.normalized()
		camera.rotation_degrees.x += -movement.y * camera_sensitivity
		camera.rotation_degrees.y += -movement.x * camera_sensitivity
	elif event is InputEventMouseButton:
		if not event.pressed:
			if is_instance_valid(_world) and raycast.is_colliding():
				if event.button_index == BUTTON_LEFT:
					var target = Voxel.world_to_grid(_cursor_position)
					target += _cursor_normal
					_world.set_voxel(target, 0)
				if event.button_index == BUTTON_RIGHT:
					var target = Voxel.world_to_grid(_cursor_position)
					_world.erase_voxel(target)
				_world.update_mesh()
	
	_update_cursor_position()


func _physics_process(delta : float) -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	
	var direction := Vector3()
	if Input.is_action_pressed("ui_up"):
		direction += Vector3.BACK
	if Input.is_action_pressed("ui_down"):
		direction += Vector3.FORWARD
	if Input.is_action_pressed("ui_right"):
		direction += Vector3.RIGHT
	if Input.is_action_pressed("ui_left"):
		direction += Vector3.LEFT
	
	var velocity := Vector3()
	velocity += -camera.global_transform.basis.z * direction.z
	velocity += camera.global_transform.basis.x * direction.x
	velocity.y = 0
	velocity = (velocity * speed) + Vector3(0, gravity, 0)
	
	move_and_collide(velocity * delta)
	_update_cursor_position()



## Public Methods
func set_world_path(path : NodePath) -> void:
	if path.is_empty():
		world_path = null
		_world = null
	else:
		world_path = path
		if is_inside_tree():
			var node = get_node(path)
			if node is VoxelMesh:
				_world = node



## Private Methods
func _update_cursor_position() -> void:
	var pos := raycast.get_collision_point()
	_cursor_normal = raycast.get_collision_normal().round()
	_cursor_position = pos - _cursor_normal * (Voxel.VoxelWorldSize / 2)
	
	cursor.visible = raycast.is_colliding()
	if cursor.visible:
		var tran = Voxel.world_to_snapped(_cursor_position)
		tran += Vector3.ONE * (Voxel.VoxelWorldSize / 2)
		tran = to_local(tran)
		cursor.translation = tran
