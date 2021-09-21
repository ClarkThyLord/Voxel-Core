extends KinematicBody



## Constants
const voxel_size := 0.5



## Exported Variables
export(float, 0.0, 100.0) var speed := 12.0

export(float, 0.0, 100.0) var jump := 1.0

export(float, -100.0, 100.0) var gravity := -9.81

export(float, 0.0, 10.0) var camera_sensitivity := 5.0

export(NodePath) var world_path setget set_world_path



## Private Variables
var _world : VoxelMesh = null

var _block_id := 0

var _cursor_normal := Vector3()

var _cursor_position := Vector3()



## OnReady Variables
onready var camera : Camera = get_node("Camera")

onready var raycast : RayCast = get_node("Camera/RayCast")

onready var cursor : MeshInstance = get_node("Cursor")

onready var block : MeshInstance = get_node("Camera/Block")

onready var block_animation : AnimationPlayer = get_node("Camera/Block/AnimationPlayer")



## Built-In Virtual Methods
func _ready() -> void:
	set_world_path(world_path)
	cursor.visible = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event : InputEvent) -> void:
	if not camera.current:
		return
	
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
				match event.button_index:
					BUTTON_LEFT:
						var target = Voxel.world_to_grid(_cursor_position)
						target += _cursor_normal
						_world.set_voxel(target, _block_id)
						_world.update_mesh()
						block_animation.play("act")
					BUTTON_RIGHT:
						var target = Voxel.world_to_grid(_cursor_position)
						_world.erase_voxel(target)
						_world.update_mesh()
						block_animation.play("act")
					BUTTON_WHEEL_UP:
						if is_instance_valid(_world):
							_block_id = int(clamp(
									_block_id + 1, 0, _world.voxel_set.size() - 1))
							_update_block()
					BUTTON_WHEEL_DOWN:
						if is_instance_valid(_world):
							_block_id = int(clamp(
									_block_id - 1, 0, _world.voxel_set.size() - 1))
							_update_block()
				
	
	_update_cursor_position()


func _physics_process(delta : float) -> void:
	if not camera.current or Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
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
	
	if Input.is_action_just_pressed("ui_select"):
		translate(Vector3.UP * jump)
	
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
				_update_block()



## Private Methods
func _update_cursor_position() -> void:
	var pos := raycast.get_collision_point()
	_cursor_normal = raycast.get_collision_normal().round()
	_cursor_position = pos - _cursor_normal * (voxel_size / 2)
	
	cursor.visible = raycast.is_colliding()
	if cursor.visible:
		var tran = Voxel.world_to_snapped(_cursor_position)
		tran += Vector3.ONE * (voxel_size / 2)
		tran = to_local(tran)
		cursor.translation = tran


func _update_block() -> void:
	if is_instance_valid(_world) and is_instance_valid(_world.voxel_set):
		var vt := VoxelTool.new()
		
		vt.begin(_world.voxel_set, true)
		for face in Voxel.Faces:
			vt.add_face(
					_world.voxel_set.get_voxel(_block_id),
					face, -Vector3.ONE / 2)
		block.mesh = vt.commit()
