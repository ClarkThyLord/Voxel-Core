tool
extends TextureRect



# Declarations
signal selected_tile(uv)
signal unselected_tile(uv)


var last_uv_hovered := -Vector2.ONE


var Selections := [] setget set_selections
func set_selections(selections : Array) -> void: pass

export(int, -1, 256) var AllowedSelections := 0 setget set_allowed_selections
func set_allowed_selections(allowed_selections : int, update := true) -> void:
	AllowedSelections = clamp(allowed_selections, -1, 256)
	unselect_shrink()
	if update: self.update()


export(Color) var HoveredColor := Color(1, 1, 1, 0.6) setget set_hovered_color
func set_hovered_color(hovered_color : Color, update := true) -> void:
	HoveredColor = hovered_color
	if update: self.update()

export(Color) var SelectionColor := Color.white setget set_selection_color
func set_selection_color(selection_color : Color, update := true) -> void:
	SelectionColor = selection_color
	if update: self.update()

export(Color) var InvalidColor := Color.red setget set_invalid_color
func set_invalid_color(color : Color, update := true) -> void:
	InvalidColor = color
	if update: self.update()


export(Resource) var VoxelSetRef = null setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if not typeof(voxel_set) == TYPE_NIL and not voxel_set is VoxelSet:
		printerr("VoxelViewer : Invalid Resource given expected VoxelSet")
		return
	
	if is_instance_valid(VoxelSetRef):
		if VoxelSetRef.is_connected("requested_refresh", self, "update"):
			VoxelSetRef.disconnect("requested_refresh", self, "update") 
	
	VoxelSetRef = voxel_set
	if is_instance_valid(VoxelSetRef):
		VoxelSetRef.connect("requested_refresh", self, "update")
		if is_instance_valid(VoxelSetRef.Tiles):
			texture = VoxelSetRef.Tiles
	else:
		texture = null
	
	if update: self.update()



# Helpers
func world_to_uv(world : Vector2) -> Vector2:
	return (world / VoxelSetRef.TileSize).floor() if is_instance_valid(VoxelSetRef) and VoxelSetRef.UVReady else -Vector2.ONE

func world_within_bounds(world : Vector2) -> bool:
	if is_instance_valid(VoxelSetRef) and VoxelSetRef.UVReady:
		var bounds = VoxelSetRef.Tiles.get_size() / VoxelSetRef.TileSize
		return world.x >= 0 and world.y >= 0 and world.x < bounds.x and world.y < bounds.y
	return false



# Core
func select(uv : Vector2, emit := true) -> void:
	# TODO UV within bounds
	if AllowedSelections != 0:
		unselect_shrink(AllowedSelections - 1)
		Selections.append(uv)
		if emit:
			emit_signal("selected_uv", uv)

func unselect(uv : Vector2, emit := true) -> void:
	if Selections.has(uv):
		Selections.erase(uv)
		if emit:
			emit_signal("unselected_uv", uv)

func unselect_all() -> void:
	while not Selections.empty():
		unselect(Selections.back())

func unselect_shrink(size := AllowedSelections, emit := true) -> void:
	if size >= 0:
		while Selections.size() > size:
			unselect(Selections.back(), emit)


func _gui_input(event : InputEvent):
	if event is InputEventMouse:
		last_uv_hovered = world_to_uv(event.position)
		if AllowedSelections != 0 and event is InputEventMouseButton:
			if world_within_bounds(last_uv_hovered) and event.button_index == BUTTON_LEFT and not event.is_pressed():
				if Selections.has(last_uv_hovered):
					unselect(last_uv_hovered)
				else:
					select(last_uv_hovered)
		update()


func _draw():
	if is_instance_valid(VoxelSetRef) and VoxelSetRef.UVReady:
		if AllowedSelections != 0:
			for selection in Selections:
				draw_rect(Rect2(
				selection * VoxelSetRef.TileSize,
				VoxelSetRef.TileSize
				), SelectionColor, false, 3)
		
		if last_uv_hovered == -Vector2.ONE:
			hint_tooltip = ""
		else:
			hint_tooltip = str(last_uv_hovered)
			draw_rect(Rect2(
				last_uv_hovered * VoxelSetRef.TileSize,
				VoxelSetRef.TileSize
			), HoveredColor if world_within_bounds(last_uv_hovered) else InvalidColor, false, 3)
