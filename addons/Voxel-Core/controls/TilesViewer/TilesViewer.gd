tool
extends TextureRect
# Shows tiles of VoxelSet and allows for the selection of Tile(s)



## Declarations
# Emitted when uv position has been selected
signal selected_uv(uv)
# Emitted when uv position has been unselected
signal unselected_uv(uv)


# Internal value used to track the last uv position hovered
var last_uv_hovered := -Vector2.ONE


# Selected uv positions
var Selections := [] setget set_selections
# Prevent external modifications of selections
func set_selections(selections : Array) -> void: pass

# Number of uv positions that can be selected at any one time
export(int, -1, 256) var AllowedSelections := 0 setget set_allowed_selections
# Sets AllowedSelections, shrinks Selections to new maximum if needed; and calls on update by default
func set_allowed_selections(allowed_selections : int, update := true) -> void:
	AllowedSelections = clamp(allowed_selections, -1, 256)
	unselect_shrink()
	if update: self.update()


# Color to use on hovered uv positions
export(Color) var HoveredColor := Color(1, 1, 1, 0.6) setget set_hovered_color
# Sets HoveredColor, and calls on update by default
func set_hovered_color(hovered_color : Color, update := true) -> void:
	HoveredColor = hovered_color
	if update: self.update()

# Color to use on selected uv positions
export(Color) var SelectionColor := Color.white setget set_selection_color
# Sets SelectionColor, and calls on update by default
func set_selection_color(selection_color : Color, update := true) -> void:
	SelectionColor = selection_color
	if update: self.update()

# Color to use on invalid uv positions
export(Color) var InvalidColor := Color.red setget set_invalid_color
# Sets InvalidColor, and calls on update by default
func set_invalid_color(color : Color, update := true) -> void:
	InvalidColor = color
	if update: self.update()


# VoxelSet being used
export(Resource) var VoxelSetRef = null setget set_voxel_set
# Sets VoxelSetRef, and calls on update by default
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



## Helpers
# Returns world position rounded to uv position
func world_to_uv(world : Vector2) -> Vector2:
	return (world / VoxelSetRef.TileSize).floor() if is_instance_valid(VoxelSetRef) and VoxelSetRef.UVReady else -Vector2.ONE

# Returns true if world position is valid uv position
func world_within_bounds(world : Vector2) -> bool:
	if is_instance_valid(VoxelSetRef) and VoxelSetRef.UVReady:
		var bounds = VoxelSetRef.Tiles.get_size() / VoxelSetRef.TileSize
		return world.x >= 0 and world.y >= 0 and world.x < bounds.x and world.y < bounds.y
	return false



## Core
# Selects given uv position, and emits selected_uv
func select(uv : Vector2, emit := true) -> void:
	# TODO UV within bounds
	if AllowedSelections != 0:
		unselect_shrink(AllowedSelections - 1)
		Selections.append(uv)
		if emit:
			emit_signal("selected_uv", uv)

# Unselects given uv position, and emits unselected_uv
func unselect(uv : Vector2, emit := true) -> void:
	if Selections.has(uv):
		Selections.erase(uv)
		if emit:
			emit_signal("unselected_uv", uv)

# Unselects all uv position
func unselect_all() -> void:
	while not Selections.empty():
		unselect(Selections.back())

# Unselects all uv position until given size is met
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
