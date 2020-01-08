tool
extends ImmediateGeometry



# Declarations
export(Color) var CursorColor := Color(1, 0, 0, 0.6) setget set_cursor_color
func set_cursor_color(cursorcolor : Color) -> void:
	CursorColor = cursorcolor
	material_override.albedo_color = CursorColor

enum CursorTypes { SOLID, WIRED }
export(CursorTypes) var CursorType := CursorTypes.SOLID setget set_cursor_type
func set_cursor_type(cursortype : int) -> void:
	 CursorType = cursortype

enum CursorModes { CUSTOM, CUBE }
export(CursorModes) var CursorMode := CursorModes.CUBE setget set_cursor_mode
func set_cursor_mode(cursormode : int) -> void:
	 CursorMode = cursormode


export(Vector3) var CursorPosition := Vector3() setget set_cursor_position
func set_cursor_position(cursorposition : Vector3) -> void:
	CursorPosition = cursorposition

export(Vector3) var TargetPosition := Vector3() setget set_target_position
func set_target_position(targetposition : Vector3) -> void:
	TargetPosition = targetposition


var CursorPositions := []



# Core
func _init():
	material_override = SpatialMaterial.new()
	material_override.flags_transparent = true
	material_override.albedo_color = CursorColor
	material_override.params_cull_mode = SpatialMaterial.CULL_DISABLED
	set_process(true)


func abs_position() -> Vector3:
	return Voxel.grid_to_pos(grid_position())

func grid_position() -> Vector3:
	return Vector3(
		CursorPosition.x if CursorPosition.x < TargetPosition.x else TargetPosition.x,
		CursorPosition.y if CursorPosition.y < TargetPosition.y else TargetPosition.y,
		CursorPosition.z if CursorPosition.z < TargetPosition.z else TargetPosition.z
	)


func get_dimensions() -> Vector3:
	var dimensions := (TargetPosition - CursorPosition).abs() + Vector3.ONE
	if dimensions.x == 0: dimensions.x += 1
	if dimensions.y == 0: dimensions.y += 1
	if dimensions.z == 0: dimensions.z += 1
	return dimensions

func selected_grids() -> Array:
	var points = []
	var position = grid_position()
	var dimensions = get_dimensions()
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			for z in range(dimensions.z):
				points.append(position + Vector3(x, y, z))
	return points


func _process(delta):
	if visible:
		clear()
		match CursorMode:
			CursorModes.CUSTOM:
				translation = Vector3.ZERO
				begin(Mesh.PRIMITIVE_TRIANGLES)
				for position in CursorPositions:
					if not CursorPositions.has(position + Vector3.RIGHT):
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT))
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT + Vector3.UP))
						
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.ONE))
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT + Vector3.UP))
					if not CursorPositions.has(position + Vector3.LEFT):
						add_vertex(Voxel.grid_to_pos(position + Vector3.UP + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.UP))
						
						add_vertex(Voxel.grid_to_pos(position + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position))
						add_vertex(Voxel.grid_to_pos(position + Vector3.UP))
					if not CursorPositions.has(position + Vector3.UP):
						add_vertex(Voxel.grid_to_pos(position + Vector3.ONE))
						add_vertex(Voxel.grid_to_pos(position + Vector3.UP + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT + Vector3.UP))
						
						add_vertex(Voxel.grid_to_pos(position + Vector3.UP + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.UP))
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT + Vector3.UP))
					if not CursorPositions.has(position + Vector3.DOWN):
						add_vertex(Voxel.grid_to_pos(position))
						add_vertex(Voxel.grid_to_pos(position + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT))
						
						add_vertex(Voxel.grid_to_pos(position + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT))
					if not CursorPositions.has(position + Vector3.BACK):
						add_vertex(Voxel.grid_to_pos(position + Vector3.ONE))
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.UP + Vector3.BACK))
						
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.BACK))
						add_vertex(Voxel.grid_to_pos(position + Vector3.UP + Vector3.BACK))
					if not CursorPositions.has(position + Vector3.FORWARD):
						add_vertex(Voxel.grid_to_pos(position))
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT))
						add_vertex(Voxel.grid_to_pos(position + Vector3.UP))
						
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT))
						add_vertex(Voxel.grid_to_pos(position + Vector3.RIGHT + Vector3.UP))
						add_vertex(Voxel.grid_to_pos(position + Vector3.UP))
			CursorModes.CUBE:
				translation = abs_position()
				var dimensions := get_dimensions()
				match CursorType:
					CursorTypes.SOLID:
						begin(Mesh.PRIMITIVE_TRIANGLES)
						
						# Right face
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.UP * dimensions.y))
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						# Left face
						add_vertex(Vector3.ZERO)
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						add_vertex(Vector3.ZERO)
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						# Up face
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.RIGHT * dimensions.x))
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.BACK * dimensions.z))
						
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.RIGHT * dimensions.x))
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.BACK * dimensions.z))
						
						# Down face
						add_vertex(Vector3.ZERO)
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						
						# Back face
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.RIGHT * dimensions.x))
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.RIGHT * dimensions.x + Vector3.UP * dimensions.y))
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.RIGHT * dimensions.x))
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						# Forward face
						add_vertex(Vector3.ZERO)
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.UP * dimensions.y))
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						
					CursorTypes.WIRED:
						begin(Mesh.PRIMITIVE_LINES)
						
						# Right lines
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.UP * dimensions.y))
						
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.UP * dimensions.y))
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						
						# Left lines
						add_vertex(Vector3.ZERO)
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						add_vertex(Vector3.ZERO)
						
						# Top lines
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.RIGHT * dimensions.x))
						
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.BACK * dimensions.z))
						add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						
						# Bottom lines
						add_vertex(Vector3.ZERO)
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						
						add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
		end()
