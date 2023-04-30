@tool
extends MeshInstance3D
## Class for VoxelObject Editor's Grid



# Enums
enum GridModes {
	SOLID,
	WIRED,
}



# Exported Variables
@export
var disabled : bool = false :
	set = set_disabled

@export_color_no_alpha
var grid_color : Color = Color.WHITE :
	set = set_grid_color

@export
var grid_mode : GridModes = GridModes.WIRED :
	set = set_grid_mode

@export
var grid_size : Vector3i = Vector3i(16, 0, 16) :
	set = set_grid_size

@export_range(0.01, 1.0, 0.01, "or_greater")
var cell_size : float = 0.25 :
	set = set_cell_size



# Private Variables
var _surface_tool := SurfaceTool.new()



## Public Methods
func set_disabled(new_value : bool) -> void:
	disabled = new_value
	visible = not disabled
	
	if not disabled:
		update()


func set_grid_color(new_value : Color) -> void:
	grid_color = new_value
	
	if not disabled:
		update()


func set_grid_mode(new_value : GridModes) -> void:
	grid_mode = new_value
	
	if not disabled:
		update()


func set_grid_size(new_value : Vector3i) -> void:
	grid_size = new_value
	
	if not disabled:
		update()


func set_cell_size(new_value : float) -> void:
	cell_size = new_value
	
	if not disabled:
		update()


func update() -> void:
	_surface_tool.clear()
	
	match grid_mode:
		GridModes.SOLID:
			_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
			_surface_tool.set_normal(Vector3.UP)
			
			_surface_tool.add_vertex(
				Vector3(0, 0, grid_size.z) * cell_size)
			_surface_tool.add_vertex(
				Vector3(0, 0, 0) * cell_size)
			_surface_tool.add_vertex(
				Vector3(grid_size.x, 0, grid_size.z) * cell_size)
			_surface_tool.add_vertex(
				Vector3(grid_size.x, 0, 0) * cell_size)
			
			_surface_tool.add_index(0)
			_surface_tool.add_index(1)
			_surface_tool.add_index(2)
			_surface_tool.add_index(1)
			_surface_tool.add_index(3)
			_surface_tool.add_index(2)
		GridModes.WIRED:
			_surface_tool.begin(Mesh.PRIMITIVE_LINES)
			_surface_tool.set_normal(Vector3.UP)
			
			for x in range(grid_size.x + 1):
				_surface_tool.add_vertex(
					Vector3(x, 0, 0) * cell_size)
				_surface_tool.add_vertex(
					Vector3(x, 0, grid_size.z) * cell_size)
			
			for z in range(grid_size.z + 1):
				_surface_tool.add_vertex(
					Vector3(0, 0, z) * cell_size)
				_surface_tool.add_vertex(
					Vector3(grid_size.x, 0, z) * cell_size)
	
	mesh = _surface_tool.commit()
	
	if not is_instance_valid(material_override):
		material_override = StandardMaterial3D.new()
	material_override.albedo_color = grid_color
	material_override.set_cull_mode(2)
