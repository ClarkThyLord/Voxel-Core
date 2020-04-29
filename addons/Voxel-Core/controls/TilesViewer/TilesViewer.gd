tool
extends TextureRect



# Declarations
signal select(index)


var Voxel_Set : VoxelSet setget setup_voxel_set

var hovered : Vector2 setget set_hovered
func set_hovered(hovered : Vector2) -> void: pass

var Selections := [] setget set_selections
func set_selections(selections : Array) -> void:
	Selections.clear()
	for selection in selections:
		if typeof(selection) == TYPE_VECTOR2:
			select(selection)
		if Selections.size() == SelectionMax: break

export(bool) var SelectMode := false setget set_select_mode
func set_select_mode(select_mode : bool) -> void:
	SelectMode = select_mode

export(int, 1, 1000000000) var SelectionMax := 1 setget set_selection_max
func set_selection_max(selection_max : int) -> void:
	SelectionMax = selection_max


export(float, 1, 1000000000, 1) var TileSize := 32.0 setget set_texture_tile
func set_texture_tile(tile_size : float, update := true) -> void:
	TileSize = floor(clamp(tile_size, 1, 1000000000))


export(Color) var HoveredColor := Color(1, 1, 1, 0.6)
export(Color) var SelectionColor := Color.white



# Helpers
func world_to_snapped(world : Vector2) -> Vector2:
	return (world / TileSize).floor()



# Core
func setup_voxel_set(voxelset : VoxelSet) -> void:
	if Voxel_Set.is_connected("updated_uv", self, "update"):
		Voxel_Set.disconnect("updated_uv", self, "update")
	Voxel_Set = voxelset
	texture = voxelset.Tiles
	TileSize = voxelset.TileSize
	Voxel_Set.connect("updated_uv", self, "update")
	update()


func select(position : Vector2, index := Selections.size() - 1) -> void:
	if index < SelectionMax:
		printerr("invalid index given")
		return
	Selections[index] = position
	emit_signal(index)


func _gui_input(event : InputEvent):
	if event is InputEventMouseMotion:
		hovered = world_to_snapped(event.position)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			if Selections.has(world_to_snapped(event.position)):
				Selections.erase(world_to_snapped(event.position))
			elif Selections.size() < SelectionMax:
				Selections.append(world_to_snapped(event.position))
			else: Selections[SelectionMax - 1] = world_to_snapped(event.position)
	update()


func _draw():
	if SelectMode:
		for selection in Selections:
			draw_rect(Rect2(
			selection * TileSize,
			Vector2(TileSize, TileSize)
			), SelectionColor, false, 3)
		
		draw_rect(Rect2(
			hovered * TileSize,
			Vector2(TileSize, TileSize)
		), HoveredColor, false, 3)
		hint_tooltip = str(hovered)
