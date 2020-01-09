tool
extends MeshInstance



# Declarations
export(Color) var CursorColor := Color(1, 0, 0, 0.6) setget set_cursor_color
func set_cursor_color(cursorcolor : Color) -> void:
	CursorColor = cursorcolor
	CursorColor.a = 0.3
	material_override.albedo_color = CursorColor

enum CursorTypes { SOLID, WIRED }
export(CursorTypes) var CursorType := CursorTypes.SOLID setget set_cursor_type
func set_cursor_type(cursortype : int, update := true) -> void:
	CursorType = cursortype
	if update: self.update()

enum CursorShapes { CUSTOM, CUBE }
export(CursorShapes) var CursorShape := CursorShapes.CUBE setget set_cursor_mode
func set_cursor_mode(cursorshape : int, update := true) -> void:
	CursorShape = cursorshape
	if update: self.update()


export(Vector3) var CursorPosition := Vector3() setget set_cursor_position
func set_cursor_position(cursorposition : Vector3, update := true) -> void:
	CursorPosition = cursorposition
	if update: self.update()

export(Vector3) var TargetPosition := Vector3() setget set_target_position
func set_target_position(targetposition : Vector3, update := true) -> void:
	TargetPosition = targetposition
	if update: self.update()


var CursorPositions := [] setget set_cursor_positions, get_cursor_positions
func get_cursor_positions() -> Array:
	match CursorShape:
		CursorShapes.CUSTOM:
			return CursorPositions
		CursorShapes.CUBE:
			var positions = []
			var position = grid_position()
			var dimensions = get_dimensions()
			for x in range(dimensions.x):
				for y in range(dimensions.y):
					for z in range(dimensions.z):
						positions.append(position + Vector3(x, y, z))
			return positions
	return []

func set_cursor_positions(cursorpositions : Array, update := true) -> void:
	CursorPositions = cursorpositions
	if update: self.update()



# Core
func _init():
	material_override = SpatialMaterial.new()
	material_override.flags_transparent = true
	material_override.params_grow = true
	material_override.params_grow_amount = 0.001
	material_override.albedo_color = CursorColor
	material_override.params_cull_mode = SpatialMaterial.CULL_DISABLED


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


func update():
	if visible:
		var ST := SurfaceTool.new()
		var voxel := Voxel.colored(CursorColor)
		match CursorShape:
			CursorShapes.CUSTOM:
				translation = Vector3.ZERO
				ST.begin(Mesh.PRIMITIVE_TRIANGLES)
				for position in CursorPositions:
					if not CursorPositions.has(position + Vector3.RIGHT):
						Voxel.generate_right(ST, voxel, position)
					if not CursorPositions.has(position + Vector3.LEFT):
						Voxel.generate_left(ST, voxel, position)
					if not CursorPositions.has(position + Vector3.UP):
						Voxel.generate_up(ST, voxel, position)
					if not CursorPositions.has(position + Vector3.DOWN):
						Voxel.generate_down(ST, voxel, position)
					if not CursorPositions.has(position + Vector3.BACK):
						Voxel.generate_back(ST, voxel, position)
					if not CursorPositions.has(position + Vector3.FORWARD):
						Voxel.generate_forward(ST, voxel, position)
			CursorShapes.CUBE:
				translation = abs_position()
				var dimensions := get_dimensions()
				match CursorType:
					CursorTypes.SOLID:
						ST.begin(Mesh.PRIMITIVE_TRIANGLES)
						
						# Right face
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						# Left face
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						ST.add_vertex(Vector3.ZERO)
						
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						ST.add_vertex(Vector3.ZERO)
						
						# Up face
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.RIGHT * dimensions.x))
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.BACK * dimensions.z))
#
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.BACK * dimensions.z))
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.RIGHT * dimensions.x))
						
						# Down face
						ST.add_vertex(Vector3.ZERO)
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))

						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						
						# Back face
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.RIGHT * dimensions.x))

						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.RIGHT * dimensions.x + Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.RIGHT * dimensions.x))
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						# Forward face
						ST.add_vertex(Vector3.ZERO)
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))

						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						
						ST.index()
						ST.generate_normals()
					CursorTypes.WIRED:
						ST.begin(Mesh.PRIMITIVE_LINES)
						
						# Right lines
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.UP * dimensions.y))
						
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						
						# Left lines
						ST.add_vertex(Vector3.ZERO)
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z + Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						ST.add_vertex(Vector3.ZERO)
						
						# Top lines
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y))
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.RIGHT * dimensions.x))
						
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.BACK * dimensions.z))
						ST.add_vertex(Voxel.GridStep * (Vector3.UP * dimensions.y + Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
						
						# Bottom lines
						ST.add_vertex(Vector3.ZERO)
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x))
						
						ST.add_vertex(Voxel.GridStep * (Vector3.BACK * dimensions.z))
						ST.add_vertex(Voxel.GridStep * (Vector3.RIGHT * dimensions.x + Vector3.BACK * dimensions.z))
		mesh = ST.commit()
