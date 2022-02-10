@tool
extends MeshInstance3D
# Grid Mesh used by VoxelObjectEditor



## Enums
enum GridModes { SOLID, WIRED }



## Exported Variables
var _disabled: bool = false
@export var disabled: bool:
	get:
		return _disabled
	set(value):
		set_disabled(value)

var _color: Color = Color.WHITE
@export var color: Color:
	get:
		return _color
	set(value):
		set_modulate(value)

var _grid_mode: GridModes = GridModes.WIRED
@export var grid_mode: GridModes:
	get:
		return _grid_mode
	set(value):
		set_grid_mode(value)

var _grid_size: Vector3 = Vector3(16, 16, 16)
@export var grid_size: Vector3:
	get:
		return _grid_size
	set(value):
		set_grid_size(value)



## Private Variables
var _surface_tool := SurfaceTool.new()

var _voxel_size := 0.5


## Built-In Virtual Methods
func _init():
	setup()


func _ready() -> void:
	setup()



## Public Methods
func set_disabled(value : bool) -> void:
	_disabled = value
	visible = not disabled
	find_node("CollisionShape", true, false).disabled = disabled


func set_voxel_size(value : float, update := true) -> void:
	_voxel_size = value
	
	if update:
		self.update()

func set_modulate(value : Color) -> void:
	_color = value
	
	material_override.albedo_color = color


func set_grid_mode(value : int, update := true) -> void:
	_grid_mode = value
	
	if update:
		self.update()


func set_grid_size(value : Vector3, update := true) -> void:
	_grid_size = Vector3(
			clamp(value.x, 1, 100),
			clamp(value.y, 1, 100),
			clamp(value.z, 1, 100))
	
	if update:
		self.update()


func setup() -> void:
	if not is_instance_valid(material_override):
		material_override = StandardMaterial3D.new()
	material_override.albedo_color = color
	material_override.set_cull_mode(2)
	update()


func update() -> void:
	match grid_mode:
		GridModes.SOLID:
			mesh = PlaneMesh.new()
			scale = Vector3(
					grid_size.x * _voxel_size,
					1,
					grid_size.z * _voxel_size)
		
		GridModes.WIRED:
			scale = Vector3.ONE
			_surface_tool.begin(Mesh.PRIMITIVE_LINES)
			
			var x : int = -grid_size.x
			while x <= grid_size.x:
				_surface_tool.add_normal(Vector3.UP)
				_surface_tool.add_vertex(
					Voxel.grid_to_snapped(
						Vector3(x, 0, -abs(grid_size.z)), _voxel_size)
				)
				_surface_tool.add_vertex(
					Voxel.grid_to_snapped(
						Vector3(x, 0, abs(grid_size.z)), _voxel_size)
				)
				
				x += 1
			
			var z : int = -grid_size.z
			while z <= grid_size.z:
				_surface_tool.add_normal(Vector3.UP)
				_surface_tool.add_vertex(
					Voxel.grid_to_snapped(
						Vector3(-abs(grid_size.x), 0, z), _voxel_size)
				)
				_surface_tool.add_vertex(
					Voxel.grid_to_snapped(
						Vector3(abs(grid_size.x), 0, z), _voxel_size)
				)
				
				z += 1
			
			mesh = _surface_tool.commit()
	for child in get_children():
		remove_child(child)
		child.queue_free()
	create_convex_collision()
	set_disabled(disabled)
