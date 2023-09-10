@tool
extends MeshInstance3D
## VoxelObject Editor's Grid Class



# Const
const grid_shader : ShaderMaterial = \
		preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_object_editor_grid/voxel_object_editor_grid_shader.tres")



# Enums
enum GridModes {
	SOLID,
	WIRED,
}

enum GridThemes {
	AXES,
	CUSTOM_COLOR,
}



# Exported Variables
@export
var disabled : bool = false :
	set = set_disabled

@export_category("Grid")
@export
var grid_mode : GridModes = GridModes.WIRED :
	set = set_grid_mode

@export
var grid_theme : GridThemes = GridThemes.AXES :
	set = set_grid_theme

@export_color_no_alpha
var grid_color : Color = Color.WHITE :
	set = set_grid_color

@export
var grid_shape : Vector3i = Vector3i(32, 32, 32) :
	set = set_grid_shape

@export_range(0.01, 1, 0.01, "or_greater")
var grid_cell_size : float = 0.25 :
	set = set_grid_cell_size



# Built-In Virtual Methods
func _ready() -> void:
	update()



# Public Methods
func set_disabled(new_disabled : bool) -> void:
	disabled = new_disabled
	
	visible = not disabled
	
	update()


func set_grid_mode(new_grid_mode : GridModes) -> void:
	grid_mode = new_grid_mode
	
	update()


func set_grid_theme(new_grid_theme : GridThemes) -> void:
	grid_theme = new_grid_theme
	
	update()



func set_grid_color(new_grid_color : Color) -> void:
	grid_color = new_grid_color
	
	update()


func set_grid_shape(new_grid_shape : Vector3i) -> void:
	grid_shape = new_grid_shape.clamp(
			Vector3i.ONE, new_grid_shape.abs())
	
	update()


func set_grid_cell_size(new_grid_cell_size : float) -> void:
	grid_cell_size = new_grid_cell_size
	
	update()


func update() -> void:
	if disabled:
		return
	
	var surface_tool : SurfaceTool = SurfaceTool.new()
	
	match grid_mode:
		GridModes.SOLID:
			surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
			
			var index : int = 0
			
			# RIGHT OF GRID
			surface_tool.set_normal(Vector3.LEFT)
			
			surface_tool.add_vertex((Vector3i.RIGHT + Vector3i.UP) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.RIGHT) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.ONE) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.RIGHT + Vector3i.BACK) * grid_shape * grid_cell_size)
			
			surface_tool.add_index(index + 0)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 2)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 3)
			surface_tool.add_index(index + 2)
			index += 4
			
			# LEFT OF GRID
			surface_tool.set_normal(Vector3.RIGHT)
			
			surface_tool.add_vertex((Vector3i.ZERO) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.UP) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.BACK) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.UP + Vector3i.BACK) * grid_shape * grid_cell_size)
			
			surface_tool.add_index(index + 0)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 2)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 3)
			surface_tool.add_index(index + 2)
			index += 4
			
			# TOP OF GRID
			surface_tool.set_normal(Vector3.DOWN)
			
			surface_tool.add_vertex((Vector3i.UP + Vector3i.BACK) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.UP) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.ONE) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.RIGHT + Vector3i.UP) * grid_shape * grid_cell_size)
			
			surface_tool.add_index(index + 0)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 2)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 3)
			surface_tool.add_index(index + 2)
			index += 4
			
			# BOTTOM OF GRID
			surface_tool.set_normal(Vector3.UP)
			
			surface_tool.add_vertex((Vector3i.RIGHT + Vector3i.BACK) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.RIGHT) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.BACK) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.ZERO) * grid_shape * grid_cell_size)
			
			surface_tool.add_index(index + 0)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 2)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 3)
			surface_tool.add_index(index + 2)
			index += 4
			
			# FRONT OF GRID
			surface_tool.set_normal(Vector3.BACK)
			
			surface_tool.add_vertex((Vector3i.RIGHT) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.RIGHT + Vector3i.UP) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.ZERO) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.UP) * grid_shape * grid_cell_size)
			
			surface_tool.add_index(index + 0)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 2)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 3)
			surface_tool.add_index(index + 2)
			index += 4
			
			# BACK OF GRID
			surface_tool.set_normal(Vector3.FORWARD)
			
			surface_tool.add_vertex((Vector3i.ONE) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.RIGHT + Vector3i.BACK) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.UP + Vector3i.BACK) * grid_shape * grid_cell_size)
			surface_tool.add_vertex((Vector3i.BACK) * grid_shape * grid_cell_size)
			
			surface_tool.add_index(index + 0)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 2)
			surface_tool.add_index(index + 1)
			surface_tool.add_index(index + 3)
			surface_tool.add_index(index + 2)
			index += 4
			
			
		GridModes.WIRED:
			surface_tool.begin(Mesh.PRIMITIVE_LINES)
			
			# RIGHT OF GRID
			surface_tool.set_normal(Vector3.RIGHT)

			for y in range(grid_shape.y + 1):
				surface_tool.add_vertex(
					Vector3(grid_shape.x, y, 0) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(grid_shape.x, y, grid_shape.z) * grid_cell_size)

			for z in range(grid_shape.z + 1):
				surface_tool.add_vertex(
					Vector3(grid_shape.x, 0, z) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(grid_shape.x, grid_shape.y, z) * grid_cell_size)
			
			# LEFT OF GRID
			surface_tool.set_normal(Vector3.LEFT)

			for y in range(grid_shape.y + 1):
				surface_tool.add_vertex(
					Vector3(0, y, 0) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(0, y, grid_shape.z) * grid_cell_size)

			for z in range(grid_shape.z + 1):
				surface_tool.add_vertex(
					Vector3(0, 0, z) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(0, grid_shape.y, z) * grid_cell_size)
			
			# TOP OF GRID
			surface_tool.set_normal(Vector3.UP)

			for x in range(grid_shape.x + 1):
				surface_tool.add_vertex(
					Vector3(x, grid_shape.y, 0) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(x, grid_shape.y, grid_shape.z) * grid_cell_size)

			for z in range(grid_shape.z + 1):
				surface_tool.add_vertex(
					Vector3(0, grid_shape.y, z) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(grid_shape.x, grid_shape.y, z) * grid_cell_size)
			
			# BOTTOM OF GRID
			surface_tool.set_normal(Vector3.DOWN)

			for x in range(grid_shape.x + 1):
				surface_tool.add_vertex(
					Vector3(x, 0, 0) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(x, 0, grid_shape.z) * grid_cell_size)

			for z in range(grid_shape.z + 1):
				surface_tool.add_vertex(
					Vector3(0, 0, z) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(grid_shape.x, 0, z) * grid_cell_size)
			
			# FRONT OF GRID
			surface_tool.set_normal(Vector3.FORWARD)

			for x in range(grid_shape.x + 1):
				surface_tool.add_vertex(
					Vector3(x, 0, 0) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(x, grid_shape.y, 0) * grid_cell_size)

			for y in range(grid_shape.y + 1):
				surface_tool.add_vertex(
					Vector3(0, y, 0) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(grid_shape.x, y, 0) * grid_cell_size)
			
			# BACK OF GRID
			surface_tool.set_normal(Vector3.BACK)

			for x in range(grid_shape.x + 1):
				surface_tool.add_vertex(
					Vector3(x, 0, grid_shape.z) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(x, grid_shape.y, grid_shape.z) * grid_cell_size)

			for y in range(grid_shape.y + 1):
				surface_tool.add_vertex(
					Vector3(0, y, grid_shape.z) * grid_cell_size)
				surface_tool.add_vertex(
					Vector3(grid_shape.x, y, grid_shape.z) * grid_cell_size)
	
	mesh = surface_tool.commit()
	
	if not is_instance_valid(material_override):
		material_override = grid_shader
	match grid_theme:
		GridThemes.AXES:
			material_override.set_shader_parameter("color", Color.TRANSPARENT)
		GridThemes.CUSTOM_COLOR:
			material_override.set_shader_parameter("color", grid_color)
