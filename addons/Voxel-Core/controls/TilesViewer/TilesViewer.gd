tool
extends TextureRect



# Declarations
signal selected(index)
signal unselecting(index)
signal unselected(index)


var hovered : Vector2 setget set_hovered
func set_hovered(hovered : Vector2) -> void: pass

var Selections := [] setget set_selections
func set_selections(selections : Array) -> void: pass

export(bool) var SelectMode := false setget set_select_mode
func set_select_mode(select_mode : bool) -> void:
	SelectMode = select_mode
	if not SelectMode: unselect_all()

export(int, 0, 1000000000) var SelectionMax := 0 setget set_selection_max
func set_selection_max(selection_max : int) -> void:
	selection_max = abs(selection_max)
	if selection_max > 0 and selection_max < SelectionMax:
		while Selections.size() > selection_max:
			unselect(Selections.size() - 1)
	
	SelectionMax = selection_max


export(float, 1, 1000000000, 1) var TileSize := 32.0 setget set_texture_tile
func set_texture_tile(tile_size : float, update := true) -> void:
	TileSize = floor(clamp(tile_size, 1, 1000000000))


export(Color) var HoveredColor := Color(1, 1, 1, 0.6)
export(Color) var SelectionColor := Color.white


export(Resource) var Voxel_Set = preload("res://addons/Voxel-Core/defaults/VoxelSet.tres") setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if voxel_set is VoxelSet:
		if Voxel_Set.is_connected("updated_texture", self, "update"):
			Voxel_Set.disconnect("updated_texture", self, "update")
		Voxel_Set = voxel_set
		texture = Voxel_Set.Tiles
		TileSize = Voxel_Set.TileSize
		Voxel_Set.connect("updated_texture", self, "update")
		
		if update: self.update()
	elif typeof(voxel_set) == TYPE_NIL:
		set_voxel_set(preload("res://addons/Voxel-Core/defaults/VoxelSet.tres"), update)



# Helpers
func world_to_uv(world : Vector2) -> Vector2:
	return (world / TileSize).floor()



# Core
func select(uv : Vector2) -> int:
	if SelectMode:
		if SelectionMax == 0 or Selections.size() < SelectionMax:
			Selections.append(uv)
		else:
			unselect(Selections.size() - 1)
			return select(uv)
		emit_signal("selected", Selections.size() - 1)
		return Selections.size() - 1
	else: return -1

func unselect(index : int) -> void:
	emit_signal("unselecting", index)
	if index > Selections.size():
		printerr("unselect index out of range: ", index)
		return
	Selections.remove(index)
	emit_signal("unselected", index)

func unselect_all() -> void:
	while not Selections.empty():
		unselect(Selections.size() - 1)


func _gui_input(event : InputEvent):
	if event is InputEventMouse:
		var uv := world_to_uv(event.position)
		if event is InputEventMouseMotion:
			hovered = uv
		elif SelectMode and event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and not event.is_pressed():
				var index := Selections.find(uv)
				if index == -1: select(uv)
				else: unselect(index)
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
