tool
extends MeshInstance
# Grid Mesh used by VoxelObjectEditor



## Enums
enum GridModes { SOLID, WIRED }



## Exported Variables
export var disabled := false setget set_disabled

export(Color, RGB) var color := Color.white setget set_modulate

export(GridModes) var grid_mode := GridModes.WIRED setget set_grid_mode

export var grid_size := Vector3(16, 16, 16) setget set_grid_size



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
	disabled = value
	visible = not disabled
	find_node("CollisionShape", true, false).disabled = disabled


func set_voxel_size(value : float, update := true) -> void:
	_voxel_size = value
	
	if update:
		self.update()

func set_modulate(value : Color) -> void:
	color = value
	
	material_override.albedo_color = color


func set_grid_mode(value : int, update := true) -> void:
	grid_mode = value
	
	if update:
		self.update()


func set_grid_size(value : Vector3, update := true) -> void:
	grid_size = Vector3(
			clamp(value.x, 1, 100),
			clamp(value.y, 1, 100),
			clamp(value.z, 1, 100))
	
	if update:
		self.update()


func setup() -> void:
	if not is_instance_valid(material_override):
		material_override = SpatialMaterial.new()
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
