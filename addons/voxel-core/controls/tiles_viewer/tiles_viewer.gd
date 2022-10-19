tool
extends TextureRect
# Shows tiles of VoxelSet and allows for the selection of Tile(s)



## Signals
# Emitted when a tile position has been selected
signal tile_selected(tile)

# Emitted when a tile position has been unselected
signal tile_unselected(tile)



## Exported Variables
# Maximum number of tiles that can be selected at any one time
export(int, -1, 256) var selection_max := 0 setget set_selection_max

# Color to applied to border of hovered tile
export var hovered_color := Color(1, 1, 1, 0.6) setget set_hovered_color

# Color to applied to border of selected tile
export var selected_color := Color.white setget set_selection_color

# Color to applied to border of invalid tile
export var invalid_color := Color.red setget set_invalid_color

# VoxelSet being used
export(Resource) var voxel_set = null setget set_voxel_set



## Private Variables
# Stores last tile position hovered
var _last_tile_hovered := -Vector2.ONE

# Selected tile positions
var _selections := []



## Built-In Virtual Methods
func _ready() -> void:
	connect("mouse_exited", self, "_on_mouse_exited")


func _gui_input(event : InputEvent):
	if event is InputEventMouse:
		_last_tile_hovered = world_to_tile(event.position)
		if selection_max != 0 and event is InputEventMouseButton:
			if is_valid_tile(_last_tile_hovered) and event.button_index == BUTTON_LEFT and not event.is_pressed():
				if _selections.has(_last_tile_hovered):
					unselect(_last_tile_hovered)
				else:
					select(_last_tile_hovered)
		update()


func _draw():
	if is_instance_valid(voxel_set) and voxel_set.uv_ready():
		texture = voxel_set.tiles
		if selection_max != 0:
			for selection in _selections:
				draw_rect(Rect2(
								selection * voxel_set.tile_size,
								voxel_set.tile_size),
						selected_color, false, 3)
		
		if _last_tile_hovered == -Vector2.ONE:
			hint_tooltip = ""
		else:
			hint_tooltip = str(_last_tile_hovered)
			draw_rect(Rect2(
							_last_tile_hovered * voxel_set.tile_size,
							voxel_set.tile_size),
					hovered_color if is_valid_tile(_last_tile_hovered) else invalid_color,
					false, 3)



## Public Methods
# Sets selection_max, shrinks _selections to new maximum if needed and calls on update by default
func set_selection_max(value : int, update := true) -> void:
	selection_max = clamp(value, -1, 256)
	unselect_shrink()
	if update:
		self.update()


# Sets hovered_color, and calls on update by default
func set_hovered_color(value : Color, update := true) -> void:
	hovered_color = value
	if update:
		self.update()


# Sets selected_color, and calls on update by default
func set_selection_color(value : Color, update := true) -> void:
	selected_color = value
	if update:
		self.update()


# Sets invalid_color, and calls on update by default
func set_invalid_color(value : Color, update := true) -> void:
	invalid_color = value
	if update:
		self.update()


# Sets voxel_set, calls update_mesh if needed and not told otherwise
func set_voxel_set(value : Resource, update := true) -> void:
	if not (typeof(value) == TYPE_NIL or value is VoxelSet):
		printerr("Invalid Resource given expected VoxelSet")
		return
	
	if is_instance_valid(voxel_set):
		if voxel_set.is_connected("requested_refresh", self, "update"):
			voxel_set.disconnect("requested_refresh", self, "update")
	
	voxel_set = value
	if is_instance_valid(voxel_set):
		if not voxel_set.is_connected("requested_refresh", self, "update"):
			voxel_set.connect("requested_refresh", self, "update")
	
	if update:
		self.update()


# Returns true if tile is selected
func has_selected(tile : Vector2) -> bool:
	return _selections.has(tile)


# Returns tile selected at given index
func get_selected(index : int) -> Vector2:
	return _selections[index]


# Returns array of selected faces
func get_selections() -> Array:
	return _selections.duplicate()


# Returns number of faces selected
func get_selected_size() -> int:
	return _selections.size()


# Returns world position as tile position
func world_to_tile(world : Vector2) -> Vector2:
	return (world / voxel_set.tile_size).floor() if is_instance_valid(voxel_set) and voxel_set.uv_ready() else -Vector2.ONE


# Returns true if tile position is valid
func is_valid_tile(tile : Vector2) -> bool:
	if is_instance_valid(voxel_set) and voxel_set.uv_ready():
		var bounds = voxel_set.tiles.get_size() / voxel_set.tile_size
		return tile.x >= 0 and tile.y >= 0 and tile.x < bounds.x and tile.y < bounds.y
	return false


# Returns true if world position is valid tile position
func is_valid_world(world : Vector2) -> bool:
	return is_valid_tile(world_to_tile(world))


# Selects given tile position, and emits selected_tile
func select(tile : Vector2, emit := true) -> void:
	# TODO tile within bounds
	if selection_max != 0:
		unselect_shrink(selection_max - 1)
		_selections.append(tile)
		if emit:
			emit_signal("tile_selected", tile)


# Unselects given tile position, and emits unselected_tile
func unselect(tile : Vector2, emit := true) -> void:
	if _selections.has(tile):
		_selections.erase(tile)
		if emit:
			emit_signal("tile_unselected", tile)


# Unselects all tile position
func unselect_all() -> void:
	while not _selections.empty():
		unselect(_selections.back())


# Unselects all tile position until given size is met
func unselect_shrink(size := selection_max, emit := true) -> void:
	if size >= 0:
		while _selections.size() > size:
			unselect(_selections.back(), emit)



## Private Methods
func _on_mouse_exited():
	_last_tile_hovered = -Vector2.ONE
	update()
