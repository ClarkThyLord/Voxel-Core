tool
extends Control



## Signals
# Emited when editing state changed
signal editing(state)

# Emited when editor needs to be closed
signal close



## Enums
# The possible palettes
enum Palettes { PRIMARY, SECONDARY }



## Constants
const VoxelGrid := preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_grid/voxel_grid.gd")

const VoxelCursor := preload("res://addons/voxel-core/engine/voxel_object_editor/voxel_cursor/voxel_cursor.gd")

const VoxelObject := preload("res://addons/voxel-core/classes/voxel_object.gd")

# Default editor config
const ConfigDefault := {
	"cursor.visible": true,
	"cursor.dynamic": true,
	"cursor.voxel_raycasting": false,
	"cursor.color": Color.white,
	"grid.visible": true,
	"grid.mode": VoxelGrid.GridModes.WIRED,
	"grid.color": Color.white,
	"grid.constant": true,
	"grid.size": Vector2(16, 16),
}



## Public Variables
# UndoRedo used to commit operations
var undo_redo : UndoRedo

# Last registered raycast hit
var last_hit := {}

# Editor's current config
var config := {}

# Reference to VoxelObject being edited
var voxel_object : VoxelObject setget start_editing



## Private Variables
# Refrence to editor's grid
var _grid := VoxelGrid.new()

# Colletions of loaded editor selection modes
var _selection_modes := [
	preload("res://addons/voxel-core/engine/voxel_object_editor/editor_selection/editor_selections/individual.gd").new(),
	preload("res://addons/voxel-core/engine/voxel_object_editor/editor_selection/editor_selections/area.gd").new(),
	preload("res://addons/voxel-core/engine/voxel_object_editor/editor_selection/editor_selections/extrude.gd").new(),
]

# Refrence to editor's voxel cursors
var _cursors := {
	Vector3(0, 0, 0): VoxelCursor.new(),
	Vector3(1, 0, 0): VoxelCursor.new(),
	Vector3(1, 1, 0): VoxelCursor.new(),
	Vector3(1, 1, 1): VoxelCursor.new(),
	Vector3(0, 1, 1): VoxelCursor.new(),
	Vector3(0, 1, 0): VoxelCursor.new(),
	Vector3(0, 0, 1): VoxelCursor.new(),
	Vector3(1, 0, 1): VoxelCursor.new(),
}

# Collection of loaded editor tools
var _tools := [
	preload("res://addons/voxel-core/engine/voxel_object_editor/editor_tool/editor_tools/add.gd").new(),
	preload("res://addons/voxel-core/engine/voxel_object_editor/editor_tool/editor_tools/sub.gd").new(),
	preload("res://addons/voxel-core/engine/voxel_object_editor/editor_tool/editor_tools/swap.gd").new(),
	preload("res://addons/voxel-core/engine/voxel_object_editor/editor_tool/editor_tools/fill.gd").new(),
	preload("res://addons/voxel-core/engine/voxel_object_editor/editor_tool/editor_tools/pick.gd").new(),
]

# Voxel id of each palette
var _palette := [ -1, -1 ]

# Path to file going to imported
var import_file_path := ""



## OnReady Variables
onready var Editing := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/HBoxContainer/Editing")

onready var Options := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options")

onready var Tool := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer/Tool")

onready var Palette := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer/Palette")

onready var SelectionMode := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer/SelectionMode")

onready var MirrorX := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer2/MirrorX")

onready var MirrorY := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer2/MirrorY")

onready var MirrorZ := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer2/MirrorZ")

onready var VoxelSize := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/VoxelSize/Size")

onready var ColorChooser := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/ColorChooser")

onready var ColorPicked := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/ColorChooser/ColorPicked")

onready var VoxelSetViewer := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VoxelSetViewer")

onready var Notice := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Notice")

onready var MoveX := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/Move/X")

onready var MoveY := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/Move/Y")

onready var MoveZ := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/Move/Z")

onready var CenterX := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/Center/X")

onready var CenterY := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/Center/Y")

onready var CenterZ := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/Center/Z")

onready var ImportMenu := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/File/Import/ImportFile")

onready var ImportHow := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer/File/Import/ImportHow")

onready var Settings := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings")

onready var CursorVisible := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Cursor/ScrollContainer/VBoxContainer/CursorVisible")

onready var CursorDynamic := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Cursor/ScrollContainer/VBoxContainer/CursorDynamic")

onready var VoxelRaycasting := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Cursor/ScrollContainer/VBoxContainer/VoxelRaycasting")

onready var CursorColor := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Cursor/ScrollContainer/VBoxContainer/HBoxContainer/CursorColor")

onready var GridVisible := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Grid/ScrollContainer/VBoxContainer/GridVisible")

onready var GridConstant := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Grid/ScrollContainer/VBoxContainer/GridConstant")

onready var GridMode := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Grid/ScrollContainer/VBoxContainer/GridMode")

onready var GridColor := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Grid/ScrollContainer/VBoxContainer/HBoxContainer2/GridColor")

onready var GridSizeX := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Grid/ScrollContainer/VBoxContainer/VBoxContainer/Size/X")

onready var GridSizeZ := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Grid/ScrollContainer/VBoxContainer/VBoxContainer/Size/Z")

onready var ColorPickerMenu := get_node("ColorPickerMenu")



## Built-In Virtual Methods
func _ready():
	if not is_instance_valid(undo_redo):
		undo_redo = UndoRedo.new()
	
	update_tools()
	update_palette()
	update_selections()
	update_mirrors()
	update_settings()
	update_grid_mode()
	update_object_params()
	
	load_config()


func _exit_tree():
	if is_instance_valid(_grid):
		_grid.queue_free()
	for cursor in _cursors:
		if is_instance_valid(_cursors[cursor]):
			_cursors[cursor].queue_free()



## Public Methods
func is_editing() -> bool:
	return Editing.pressed


# Updates the drop down ui menu in editor with all loaded tools
func update_tools(tools := _tools) -> void:
	Tool.clear()
	for tool_index in range(tools.size()):
		Tool.add_icon_item(
			load("res://addons/voxel-core/assets/controls/" + tools[tool_index].name.to_lower() + ".png"),
			tools[tool_index].name.capitalize(),
			tool_index)


# Updates the drop down ui menu in editor with palettes
func update_palette(palettes := Palettes.keys()) -> void:
	Palette.clear()
	for palette in palettes:
		Palette.add_icon_item(
			load("res://addons/voxel-core/assets/controls/" + palette.to_lower() + ".png"),
			palette.capitalize(),
			Palettes[palette.to_upper()])


# Updates the drop down ui menu in editor with all loaded selection modes
func update_selections(selection_modes := [
			"individual",
			"area",
			"extrude",
		]) -> void:
	var prev = SelectionMode.get_selected_id()
	SelectionMode.clear()
	for select_mode in range(_selection_modes.size()):
		if selection_modes.find(_selection_modes[select_mode].name.to_lower()) > -1:
			SelectionMode.add_icon_item(
					load("res://addons/voxel-core/assets/controls/" + _selection_modes[select_mode].name.to_lower() + ".png"),
					_selection_modes[select_mode].name.capitalize(), select_mode)
	if SelectionMode.get_item_index(prev) > -1:
		SelectionMode.select(SelectionMode.get_item_index(prev))
	else:
		_on_SelectionMode_selected(SelectionMode.get_selected_id())


# Disables and enables possible selection mirror(s) possible with current tool
func update_mirrors(mirror := Vector3.ONE) -> void:
	MirrorX.visible = mirror.x == 1
	MirrorX.pressed = MirrorX.pressed if mirror.x == 1 else false
	MirrorY.visible = mirror.y == 1
	MirrorY.pressed = MirrorY.pressed if mirror.y == 1 else false
	MirrorZ.visible = mirror.z == 1
	MirrorZ.pressed = MirrorZ.pressed if mirror.z == 1 else false
	set_cursors_visibility()


# Updates the setting tabs
func update_settings() -> void:
	for tab in range(Settings.get_tab_count()):
		var name : String = Settings.get_tab_title(tab)
		Settings.set_tab_icon(tab, 
				load("res://addons/voxel-core/assets/controls/" + name.to_lower() + ".png"))


# updates voxel object parameters
func update_object_params() -> void:
	if is_instance_valid(voxel_object):
		VoxelSize.value = voxel_object.voxel_size


# Sets the cursor visibility
func set_cursor_visible(visible : bool) -> void:
	config["cursor.visible"] = visible
	CursorVisible.pressed = visible
	if not visible:
		set_cursors_visibility(visible)
	save_config()


# Sets the cursor's dynamic option
# Enabling would change cursor color based on selected palette
func set_cursor_dynamic(dynamic : bool) -> void:
	config["cursor.dynamic"] = dynamic
	CursorDynamic.pressed = dynamic
	CursorColor.disabled = dynamic
	if dynamic:
		var color = ColorPicked.color
		color.a = 0.75
		set_cursor_color(color)
	else:
		set_cursor_color(config["cursor.color"])
	save_config()


# Sets the cursor color
func set_cursor_color(color : Color) -> void:
	config["cursor.color"] = color
	CursorColor.color = color
	for cursor in _cursors.values():
		cursor.color = color
	save_config()


# Returns true if grid should be visible
func is_grid_disabled() -> bool:
	return not Editing.pressed or (Editing.pressed and not GridVisible.pressed or (GridVisible.pressed and (not GridConstant.pressed and (is_instance_valid(voxel_object) and not voxel_object.empty()))))


# Sets the grid visibility
func set_grid_visible(visible : bool) -> void:
	config["grid.visible"] = visible
	GridVisible.pressed = visible
	_grid.disabled = is_grid_disabled()
	save_config()


# Sets the grid constant option
# Disabling would mean grid would not be visible once voxels are present
func set_grid_constant(constant : bool) -> void:
	config["grid.constant"] = constant
	GridConstant.pressed = constant
	_grid.disabled = is_grid_disabled()
	save_config()


# Updates the grid ui options
func update_grid_mode() -> void:
	GridMode.clear()
	for mode_index in range(VoxelGrid.GridModes.size()):
		GridMode.add_icon_item(
				load("res://addons/voxel-core/assets/controls/" + VoxelGrid.GridModes.keys()[mode_index].to_lower() + ".png"),
				VoxelGrid.GridModes.keys()[mode_index].capitalize(), mode_index)


# Sets the grid mode
func set_grid_mode(mode : int) -> void:
	config["grid.mode"] = mode
	GridMode.selected = mode
	_grid.grid_mode = mode
	save_config()


# Sets the grid color
func set_grid_color(color : Color) -> void:
	config["grid.color"] = color
	GridColor.color = color
	_grid.color = color
	save_config()


# Sets the grid size
func set_grid_size(size : Vector2) -> void:
	config["grid.size"] = size
	GridSizeX.value = size.x
	GridSizeZ.value = size.y
	_grid.grid_size = Vector3(size.x, 0, size.y)
	save_config()


# Gets the user selected mirror(s)
func get_mirrors() -> Array:
	var mirrors := []
	
	if MirrorX.pressed:
		mirrors.append(Vector3(1, 0, 0))
		if MirrorZ.pressed:
			mirrors.append(Vector3(1, 0, 1))
	if MirrorY.pressed:
		mirrors.append(Vector3(0, 1, 0))
		if MirrorX.pressed:
			mirrors.append(Vector3(1, 1, 0))
		if MirrorZ.pressed:
			mirrors.append(Vector3(0, 1, 1))
		if MirrorX.pressed && MirrorZ.pressed:
			mirrors.append(Vector3(1, 1, 1))
	if MirrorZ.pressed:
		mirrors.append(Vector3(0, 0, 1))
	
	return mirrors


# Gets the user's current voxel grid selection
func get_selection() -> Vector3:
	return Vector3.INF if last_hit.empty() else (last_hit["position"] + last_hit["normal"] * _tools[Tool.get_selected_id()].tool_normal)


# Gets each of the user's voxel grid selection with mirror applied
func get_selections() -> Array:
	var selections := [_cursors[Vector3.ZERO].selections]
	for mirror in get_mirrors():
		selections.append(_cursors[mirror].selections)
	return selections


# Sets the cursors voxel size
func set_cursors_voxel_size(size: float) -> void:
	for cursor in _cursors:
		_cursors[cursor].set_voxel_size(size)


# Sets the cursors visiblity
func set_cursors_visibility(visible := Editing.pressed) -> void:
	_cursors[Vector3.ZERO].visible = visible and CursorVisible.pressed
	var mirrors := get_mirrors()
	for cursor in _cursors:
		if not cursor == Vector3.ZERO:
			_cursors[cursor].visible = _cursors[Vector3.ZERO].visible and mirrors.has(cursor)


# Sets the cursors selection
func set_cursors_selections(
		selections := [last_hit["position"] + last_hit["normal"] * _tools[Tool.get_selected_id()].tool_normal] if not last_hit.empty() else []
	) -> void:
	_cursors[Vector3.ZERO].selections = selections
	var mirrors := get_mirrors()
	for mirror in mirrors:
		_cursors[mirror].selections = mirror_positions(selections, mirror)


# Updats the cursor visuals
func update_cursors() -> void:
	var mirrors := get_mirrors()
	for cursor in _cursors:
		if not cursor == Vector3.ZERO:
			_cursors[cursor].visible = _cursors[Vector3.ZERO].visible and mirrors.has(cursor)
			if mirrors.has(cursor):
				_cursors[cursor].selections = mirror_positions(
					_cursors[Vector3.ZERO].selections,
					cursor
				)


# Sets the palette
func set_palette(palette : int, voxel_id : int) -> void:
	_palette[palette] = voxel_id
	if palette == Palette.get_selected_id():
		ColorPicked.color = Voxel.get_color(get_rpalette())
		if CursorDynamic.pressed:
			var color = ColorPicked.color
			color.a = 0.5
			set_cursor_color(color)
		if not VoxelSetViewer.has_selected(voxel_id):
			VoxelSetViewer.select(voxel_id)


# Returns the voxel id of palette
func get_palette(palette : int = Palette.get_selected_id()) -> int:
	return _palette[palette]


# Returns the voxel dictionary of palette
func get_rpalette(palette : int = get_palette()) -> Dictionary:
	return voxel_object.voxel_set.get_voxel(palette)


func set_voxel_size(size : float) -> void:
	if is_instance_valid(voxel_object):
		voxel_object.set_voxel_size(size)
	
	set_cursors_voxel_size(size)
	
	if is_instance_valid(_grid):
		_grid.set_voxel_size(size)


# Setter for voxel raycasting, saves to config
func set_voxel_raycasting(value : bool) -> void:
	VoxelRaycasting.pressed = value
	config["cursor.voxel_raycasting"] = value
	_update_editing_hint()
	save_config()


# Saves the current editor config to file
func save_config() -> void:
	var file := File.new()
	var opened = file.open(
			"res://addons/voxel-core/engine/voxel_object_editor/config.var",
			File.WRITE)
	if opened == OK:
		file.store_var(config)
	if file.is_open():
		file.close()


# Loads and sets the config file
func load_config() -> void:
	var loaded := false
	var config_file := File.new()
	var opened = config_file.open(
			"res://addons/voxel-core/engine/voxel_object_editor/config.var",
			File.READ)
	if opened == OK and not config_file.eof_reached():
		var config_file_data = config_file.get_var()
		if typeof(config_file_data) == TYPE_DICTIONARY:
			config = config_file_data
			loaded = true
	
	if not loaded:
		config = ConfigDefault.duplicate()
	
	if config_file.is_open():
		config_file.close()
	
	if config.has("cursor.visible"):
		set_cursor_visible(config["cursor.visible"])
	if config.has("cursor.dynamic"):
		set_cursor_dynamic(config["cursor.dynamic"])
	
	if config.has("cursor.voxel_raycasting"):
		set_voxel_raycasting(config["cursor.voxel_raycasting"])
	
	if config.has("cursor.color"):
		set_cursor_color(config["cursor.color"])
	
	if config.has("grid.visible"):
		set_grid_visible(config["grid.visible"])
	if config.has("grid.mode"):
		set_grid_mode(config["grid.mode"])
	if config.has("grid.color"):
		set_grid_color(config["grid.color"])
	if config.has("grid.constant"):
		set_grid_constant(config["grid.constant"])
	if config.has("grid.size"):
		set_grid_size(config["grid.size"])


# Sets the current editor config to default
func reset_config() -> void:
	config = ConfigDefault.duplicate()
	save_config()
	load_config()


# Attempts to raycast for the VoxelObject
func raycast_for(camera : Camera, screen_position : Vector2, target : Node) -> Dictionary:
	var hit := {}
	var from := camera.project_ray_origin(screen_position)
	var direction := camera.project_ray_normal(screen_position)
	
	if VoxelRaycasting.pressed:
		hit = voxel_object.intersect_ray(
				from, direction, 64, funcref(self, "_raycast_stop"))
	else:
		var exclude := []
		var to := from + direction * 1000
		while true:
			hit = camera.get_world().direct_space_state.intersect_ray(from, to, exclude)
			if not hit.empty():
				if target.is_a_parent_of(hit.collider):
					if _grid.is_a_parent_of(hit.collider):
						hit["normal"] = Vector3.ZERO
						
					hit["position"] = Voxel.world_to_grid(
						voxel_object.to_local(
								hit.position + -hit.normal \
								* (voxel_object.voxel_size / 2)),
								voxel_object.voxel_size)
					
					hit["normal"] = hit["normal"].round()
					break
				else:
					exclude.append(hit.collider)
			else:
				break
	
	return hit


# Returns given grid position mirrored in accordance to mirror
func mirror_position(position : Vector3, mirror : Vector3) -> Vector3:
	match mirror:
		Vector3(1, 0, 0):
			return Vector3(position.x, position.y, (position.z + 1) * -1)
		Vector3(1, 0, 1):
			return Vector3((position.x + 1) * -1, position.y, (position.z + 1) * -1)
		Vector3(0, 1, 0):
			return Vector3(position.x, (position.y + 1) * -1, position.z)
		Vector3(1, 1, 0):
			return Vector3(position.x, (position.y + 1) * -1, (position.z + 1) * -1)
		Vector3(0, 1, 1):
			return Vector3((position.x + 1) * -1, (position.y + 1) * -1, position.z)
		Vector3(1, 1, 1):
			return Vector3((position.x + 1) * -1, (position.y + 1) * -1, (position.z + 1) * -1)
		Vector3(0, 0, 1):
			return Vector3((position.x + 1) * -1, position.y, position.z)
	return position


# Mirrors and returns given grid positions in accordance to mirror
func mirror_positions(positions : Array, mirror : Vector3) -> Array:
	var mirrored := []
	for position in positions:
		match typeof(position):
			TYPE_VECTOR3:
				mirrored.append(mirror_position(position, mirror))
			TYPE_ARRAY:
				var mirroring := []
				for index in range(position.size()):
					mirroring.append(mirror_position(position[index], mirror))
				mirrored.append(mirroring)
	return mirrored


# Disconnects the previous VoxelSet and connects the given VoxelSet
func setup_voxel_set(voxel_set : VoxelSet) -> void:
	VoxelSetViewer.voxel_set = voxel_set
	VoxelSetViewer.unselect_all()
	if is_instance_valid(voxel_set) and not voxel_set.empty():
		var first_voxel_id = voxel_set.get_ids()[0]
		_palette.clear()
		_palette.append(first_voxel_id)
		_palette.append(first_voxel_id)
		VoxelSetViewer.select(first_voxel_id)
	
	Editing.pressed = false
	Editing.disabled = not is_instance_valid(voxel_set)
	Options.visible = is_instance_valid(voxel_set)
	Notice.visible = not is_instance_valid(voxel_set)


# Attach editor components to current voxelobject
func attach_editor_components() -> void:
	detach_editor_components()
	voxel_object.add_child(_grid)
	for cursor in _cursors.values():
		voxel_object.add_child(cursor)


# Detach editor components from their parents
func detach_editor_components() -> void:
	if is_instance_valid(_grid.get_parent()):
		_grid.get_parent().remove_child(_grid)
	for cursor in _cursors:
		cursor = _cursors[cursor]
		if is_instance_valid(cursor.get_parent()):
			cursor.get_parent().remove_child(cursor)


# Disconnect previous edited VoxelObject and starts editing the new one
func start_editing(new_voxel_object : VoxelObject) -> void:
	if new_voxel_object == voxel_object:
		return
	
	_grid.set_voxel_size(new_voxel_object.voxel_size)
	set_cursors_voxel_size(new_voxel_object.voxel_size)
	
	stop_editing()
	
	voxel_object = new_voxel_object
	update_object_params()
	
	setup_voxel_set(voxel_object.voxel_set)
	voxel_object.connect("set_voxel_set", self, "setup_voxel_set")
	voxel_object.connect("tree_exiting", self, "stop_editing", [true])


# Disconnect currently edited VoxelObject
func stop_editing(close := false) -> void:
	if is_instance_valid(voxel_object):
		voxel_object.edit_hint = 0
		
		detach_editor_components()
		
		voxel_object.disconnect("set_voxel_set", self, "setup_voxel_set")
		voxel_object.disconnect("tree_exiting", self, "stop_editing")
	
	Editing.pressed = false
	voxel_object = null
	
	if close:
		emit_signal("close")


func get_tool_normal() -> int:
	return _tools[Tool.get_selected_id()].tool_normal

# Applies current tool
func work_tool() -> void:
	_tools[Tool.get_selected_id()].work(self)


# Handles editor input
func handle_input(camera : Camera, event : InputEvent) -> bool:
	if is_instance_valid(voxel_object):
		if event is InputEventMouse:
			var prev_hit = last_hit
			last_hit = raycast_for(camera, event.position, voxel_object)
			if Editing.pressed:
				if event.button_mask & ~BUTTON_MASK_LEFT > 0 or (event is InputEventMouseButton and not event.button_index == BUTTON_LEFT):
					set_cursors_visibility(false)
					return false
				
				var handle_result = _selection_modes[SelectionMode.get_selected_id()].select(
						self,
						event,
						prev_hit)
				
				if not GridConstant.pressed:
					_grid.disabled = is_grid_disabled()
				
				return handle_result
	return false


# Shows color menu centered
func show_color_menu(color := ColorPicked.color) -> void:
	ColorPickerMenu.color = color
	ColorPickerMenu.popup_centered()


# Hide color menu
func hide_color_menu() -> void:
	ColorPickerMenu.hide()


# Shows import menu centered
func show_import_menu() -> void:
	ImportMenu.popup_centered()


# Hides import menu
func hide_import_menu() -> void:
	ImportMenu.hide()



## Private Methods
func _raycast_stop(hit : Dictionary) -> bool:
	if not is_grid_disabled() and (hit["position"].y == -1 or hit["position"].y == 0):
		hit["normal"] = Vector3.ZERO
		return true
	return false


func _update_editing_hint() -> void:
	if is_instance_valid(voxel_object):
		var flag = 0
		if Editing.pressed:
			if VoxelRaycasting.pressed:
				flag = 1
			else:
				flag = 2
		voxel_object.edit_hint = flag


func _on_Editing_toggled(editing : bool):
	_update_editing_hint()
	
	if is_instance_valid(voxel_object):
		_grid.set_voxel_size(voxel_object.voxel_size)
		set_cursors_voxel_size(voxel_object.voxel_size)
	
	_grid.disabled = is_grid_disabled()
	set_cursors_visibility(editing)
	if editing:
		attach_editor_components()
		set_cursors_selections()
	
	emit_signal("editing", editing)


func _on_ColorPickerMenu_color_picked(color : Color):
	var voxel_id = voxel_object.voxel_set.size()
	undo_redo.create_action("VoxelObjectEditor : Add voxel to used VoxeSet")
	undo_redo.add_do_method(voxel_object.voxel_set, "add_voxel", Voxel.colored(color))
	undo_redo.add_undo_method(voxel_object.voxel_set, "erase_voxel", voxel_id)
	undo_redo.add_do_method(voxel_object.voxel_set, "request_refresh")
	undo_redo.add_undo_method(voxel_object.voxel_set, "request_refresh")
	undo_redo.commit_action()
	VoxelSetViewer.select(voxel_id)
	hide_color_menu()


func _on_Tool_selected(id : int):
	update_mirrors(_tools[id].mirror_modes)
	update_selections(_tools[id].selection_modes)


func _on_Palette_selected(id : int) -> void:
	set_palette(Palette.get_selected_id(), _palette[Palette.get_selected_id()])


func _on_SelectionMode_selected(id : int):
	set_cursors_selections()


func _on_VoxelSetViewer_selected(voxel_id : int) -> void:
	set_palette(Palette.get_selected_id(), voxel_id)


func _on_NewVoxelSet_pressed():
	voxel_object.voxel_set = VoxelSet.new()
	voxel_object.property_list_changed_notify()


func _on_Translate_Apply_pressed():
	var translation := Vector3(MoveX.value, MoveY.value, MoveZ.value)
	undo_redo.create_action("VoxelObjectEditor : Moved voxels")
	undo_redo.add_do_method(voxel_object, "move", translation)
	undo_redo.add_undo_method(voxel_object, "move", -translation)
	undo_redo.add_do_method(voxel_object, "update_mesh")
	undo_redo.add_undo_method(voxel_object, "update_mesh")
	undo_redo.commit_action()


func _on_Center_Apply_pressed():
	var translation = voxel_object.vec_to_center(Vector3(
			CenterX.value,
			CenterY.value,
			CenterZ.value))
	undo_redo.create_action("VoxelObjectEditor : Center voxels")
	undo_redo.add_do_method(voxel_object, "move", translation)
	undo_redo.add_undo_method(voxel_object, "move", -translation)
	undo_redo.add_do_method(voxel_object, "update_mesh")
	undo_redo.add_undo_method(voxel_object, "update_mesh")
	undo_redo.commit_action()


func _on_Voxel_Size_Apply_pressed():
	var old_vox_size = voxel_object.voxel_size
	var new_vox_size = VoxelSize.value
	undo_redo.create_action("VoxelObjectEditor : Resized voxels")
	undo_redo.add_do_method(self, "set_voxel_size", new_vox_size)
	undo_redo.add_undo_method(self, "set_voxel_size", old_vox_size)
	undo_redo.commit_action()


func _on_Flip_X_pressed():
	undo_redo.create_action("VoxelObjectEditor : X flip voxels")
	undo_redo.add_do_method(voxel_object, "flip", true, false, false)
	undo_redo.add_undo_method(voxel_object, "flip", true, false, false)
	undo_redo.add_do_method(voxel_object, "update_mesh")
	undo_redo.add_undo_method(voxel_object, "update_mesh")
	undo_redo.commit_action()


func _on_Flip_Y_pressed():
	undo_redo.create_action("VoxelObjectEditor : Y flip voxels")
	undo_redo.add_do_method(voxel_object, "flip", false, true, false)
	undo_redo.add_undo_method(voxel_object, "flip", false, true, false)
	undo_redo.add_do_method(voxel_object, "update_mesh")
	undo_redo.add_undo_method(voxel_object, "update_mesh")
	undo_redo.commit_action()


func _on_Flip_Z_pressed():
	undo_redo.create_action("VoxelObjectEditor : Z flip voxels")
	undo_redo.add_do_method(voxel_object, "flip", false, false, true)
	undo_redo.add_undo_method(voxel_object, "flip", false, false, true)
	undo_redo.add_do_method(voxel_object, "update_mesh")
	undo_redo.add_undo_method(voxel_object, "update_mesh")
	undo_redo.commit_action()


func _on_Clear_pressed():
	var voxels = {}
	for voxel in voxel_object.get_voxels():
		voxels[voxel] = voxel_object.get_voxel_id(voxel)
	undo_redo.create_action("VoxelObjectEditor : Clear voxels")
	undo_redo.add_do_method(voxel_object, "erase_voxels")
	undo_redo.add_undo_method(voxel_object, "set_voxels", voxels)
	undo_redo.add_do_method(voxel_object, "update_mesh")
	undo_redo.add_undo_method(voxel_object, "update_mesh")
	undo_redo.commit_action()


func _on_ExportFile_file_selected(path : String):
	var file := File.new()
	var opened = file.open(path, File.WRITE)
	if opened == OK:
		file.store_var({
			"voxels": voxel_object.get_voxel_ids()
		})
	if file.is_open():
		file.close()


func _on_ImportFile_file_selected(path : String):
	import_file_path = path
	match path.get_extension():
		"voxels":
			var result := voxel_object.load_file(import_file_path, false)
			if result == OK:
				voxel_object.voxel_set.request_refresh()
			else:
				printerr(result)
		_:
			if is_instance_valid(voxel_object.voxel_set):
				ImportHow.popup_centered()
			else:
				_on_Import_New_pressed()


func _on_Import_Overwrite_pressed():
	var result := voxel_object.load_file(import_file_path, false)
	if result == OK:
		voxel_object.voxel_set.request_refresh()
	else:
		printerr(result)
	ImportHow.hide()


func _on_Import_New_pressed():
	var result := voxel_object.load_file(import_file_path, true)
	if result == OK:
		voxel_object.voxel_set.request_refresh()
	else:
		printerr(result)
	ImportHow.hide()


func _on_Import_Cancel_pressed():
	ImportHow.hide()


func _on_Docs_pressed():
	OS.shell_open("https://github.com/ClarkThyLord/voxel-core/wiki")


func _on_Issues_pressed():
	OS.shell_open("https://github.com/ClarkThyLord/voxel-core/issues")


func _on_GitHub_pressed():
	OS.shell_open("https://github.com/ClarkThyLord/Voxel-Core")


func _on_Update_pressed():
	voxel_object.update_mesh()


func _on_Grid_Size_X_value_changed(value : int):
	set_grid_size(Vector2(value, _grid.grid_size.z))


func _on_Grid_Size_Z_value_changed(value : int):
	set_grid_size(Vector2(_grid.grid_size.x, value))
