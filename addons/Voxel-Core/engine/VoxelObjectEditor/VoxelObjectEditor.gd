tool
extends Control



# Imports
const VoxelGrid := preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelGrid/VoxelGrid.gd")
const VoxelCursor := preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelCursor/VoxelCursor.gd")

const VoxelObject := preload("res://addons/Voxel-Core/classes/VoxelObject.gd")



# Refrences
onready var Editing := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/HBoxContainer/Editing")

onready var Options := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options")

onready var Tool := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer/Tool")
func update_tools(tools := Tools) -> void:
	Tool.clear()
	for tool_index in range(tools.size()):
		Tool.add_icon_item(
			load("res://addons/Voxel-Core/assets/controls/" + tools[tool_index].name.to_lower() + ".png"),
			tools[tool_index].name.capitalize(),
			tool_index
		)

onready var Palette := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer/Palette")
func update_palette(palettes := Palettes.keys()) -> void:
	Palette.clear()
	for palette in palettes:
		Palette.add_icon_item(
			load("res://addons/Voxel-Core/assets/controls/" + palette.to_lower() + ".png"),
			palette.capitalize(),
			Palettes[palette.to_upper()]
		)

onready var SelectionMode := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer/SelectionMode")
func update_selections(selection_modes := [
		"individual",
		"area",
		"extrude"
	]) -> void:
	var prev = SelectionMode.get_selected_id()
	SelectionMode.clear()
	for select_mode in range(SelectionModes.size()):
		if selection_modes.find(SelectionModes[select_mode].name.to_lower()) > -1:
			SelectionMode.add_icon_item(
				load("res://addons/Voxel-Core/assets/controls/" + SelectionModes[select_mode].name.to_lower() + ".png"),
				SelectionModes[select_mode].name.capitalize(),
				select_mode
			)
	if SelectionMode.get_item_index(prev) > -1:
		SelectionMode.select(SelectionMode.get_item_index(prev))
	else: _on_SelectionMode_selected(SelectionMode.get_selected_id())

onready var MirrorX := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer2/MirrorX")
onready var MirrorY := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer2/MirrorY")
onready var MirrorZ := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/Options/VBoxContainer/HBoxContainer2/MirrorZ")
func update_mirrors(mirror := Vector3.ONE) -> void:
	MirrorX.visible = mirror.x == 1
	MirrorX.pressed = MirrorX.pressed if mirror.x == 1 else false
	MirrorY.visible = mirror.y == 1
	MirrorY.pressed = MirrorY.pressed if mirror.y == 1 else false
	MirrorZ.visible = mirror.z == 1
	MirrorZ.pressed = MirrorZ.pressed if mirror.z == 1 else false
	set_cursors_visibility()

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


onready var Settings := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings")
func update_settings() -> void:
	for tab in range(Settings.get_tab_count()):
		var name : String = Settings.get_tab_title(tab)
		Settings.set_tab_icon(tab, load("res://addons/Voxel-Core/assets/controls/" + name.to_lower() + ".png"))

onready var CursorVisible := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Cursor/ScrollContainer/VBoxContainer/CursorVisible")
func set_cursor_visible(visible : bool) -> void:
	Config["cursor.visible"] = visible
	CursorVisible.pressed = visible
	if not visible:
		set_cursors_visibility(visible)
	save_config()

onready var CursorDynamic := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Cursor/ScrollContainer/VBoxContainer/CursorDynamic")
func set_cursor_dynamic(dynamic : bool) -> void:
	Config["cursor.dynamic"] = dynamic
	CursorDynamic.pressed = dynamic
	CursorColor.disabled = dynamic
	if dynamic:
		var color = ColorPicked.color
		color.a = 0.5
		set_cursor_color(color)
	else:
		set_cursor_color(Config["cursor.color"])
	save_config()

onready var CursorColor := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Cursor/ScrollContainer/VBoxContainer/HBoxContainer/CursorColor")
func set_cursor_color(color : Color) -> void:
	Config["cursor.color"] = color
	CursorColor.color = color
	for cursor in Cursors.values():
		cursor.Modulate = color
	save_config()

onready var GridVisible := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Grid/ScrollContainer/VBoxContainer/GridVisible")
func set_grid_visible(visible : bool) -> void:
	Config["grid.visible"] = visible
	GridVisible.pressed = visible
	GridConstant.disabled = not visible
	Grid.Disabled = (not GridConstant.pressed and (is_instance_valid(VoxelObjectRef) and not VoxelObjectRef.empty())) or not visible
	save_config()

onready var GridConstant := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Grid/ScrollContainer/VBoxContainer/GridConstant")
func set_grid_constant(constant : bool) -> void:
	Config["grid.constant"] = constant
	GridConstant.pressed = constant
	Grid.Disabled = (not constant and (is_instance_valid(VoxelObjectRef) and not VoxelObjectRef.empty())) or not GridVisible.pressed
	save_config()

onready var GridMode := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Grid/ScrollContainer/VBoxContainer/GridMode")
func update_grid_mode() -> void:
	GridMode.clear()
	for mode_index in range(VoxelGrid.GridModes.size()):
		GridMode.add_icon_item(
			load("res://addons/Voxel-Core/assets/controls/" + VoxelGrid.GridModes.keys()[mode_index].to_lower() + ".png"),
			VoxelGrid.GridModes.keys()[mode_index].capitalize(),
			mode_index
		)

func set_grid_mode(mode : int) -> void:
	Config["grid.mode"] = mode
	GridMode.selected = mode
	Grid.GridMode = mode
	save_config()

onready var GridColor := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings/Grid/ScrollContainer/VBoxContainer/HBoxContainer2/GridColor")
func set_grid_color(color : Color) -> void:
	Config["grid.color"] = color
	GridColor.color = color
	Grid.Modulate = color
	save_config()


onready var ColorMenu := get_node("ColorMenu")
onready var ColorMenuColor := get_node("ColorMenu/VBoxContainer/Color")
onready var ColorMenuAdd := get_node("ColorMenu/VBoxContainer/HBoxContainer/Add")



# Declarations
signal editing(state)
signal close


var Undo_Redo : UndoRedo

var VoxelObjectRef : VoxelObject setget start_editing


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


var Grid := VoxelGrid.new() setget set_grid
func set_grid(grid : VoxelGrid) -> void: pass


var SelectionModes := [
	preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelections/Individual.gd").new(),
	preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelections/Area.gd").new(),
	preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorSelection/VoxelObjectEditorSelections/Extrude.gd").new()
]

var last_hit := {}

func get_selection() -> Vector3:
	return Vector3.INF if last_hit.empty() else (last_hit["position"] + last_hit["normal"] * Tools[Tool.get_selected_id()].tool_normal)

func get_selections() -> Array:
	var selections := [Cursors[Vector3.ZERO].Selections]
	for mirror in get_mirrors():
		selections.append(Cursors[mirror].Selections)
	return selections

var Cursors := {
	Vector3(0, 0, 0): VoxelCursor.new(),
	Vector3(1, 0, 0): VoxelCursor.new(),
	Vector3(1, 1, 0): VoxelCursor.new(),
	Vector3(1, 1, 1): VoxelCursor.new(),
	Vector3(0, 1, 1): VoxelCursor.new(),
	Vector3(0, 1, 0): VoxelCursor.new(),
	Vector3(0, 0, 1): VoxelCursor.new(),
	Vector3(1, 0, 1): VoxelCursor.new()
} setget set_cursors
func set_cursors(cursors : Dictionary) -> void: pass

func set_cursors_visibility(visible := Editing.pressed) -> void:
	Cursors[Vector3.ZERO].visible = visible and CursorVisible.pressed
	var mirrors := get_mirrors()
	for cursor in Cursors:
		if not cursor == Vector3.ZERO:
			Cursors[cursor].visible = Cursors[Vector3.ZERO].visible and mirrors.has(cursor)

func set_cursors_selections(
		selections := [last_hit["position"] + last_hit["normal"] * Tools[Tool.get_selected_id()].tool_normal] if not last_hit.empty() else []
	) -> void:
	Cursors[Vector3.ZERO].Selections = selections
	var mirrors := get_mirrors()
	for mirror in mirrors:
		Cursors[mirror].Selections = mirror_positions(selections, mirror)

func update_cursors() -> void:
	var mirrors := get_mirrors()
	for cursor in Cursors:
		if not cursor == Vector3.ZERO:
			Cursors[cursor].visible = Cursors[Vector3.ZERO].visible and mirrors.has(cursor)
			if mirrors.has(cursor):
				Cursors[cursor].Selections = mirror_positions(
					Cursors[Vector3.ZERO].Selections,
					cursor
				)


var Tools := [
	preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTools/Add.gd").new(),
	preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTools/Sub.gd").new(),
	preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTools/Swap.gd").new(),
	preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTools/Fill.gd").new(),
	preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelObjectEditorTool/VoxelObjectEditorTools/Pick.gd").new()
]


enum Palettes { PRIMARY, SECONDARY }
var PaletteRepresents := [ -1, -1 ]

func set_palette(palette : int, voxel_id : int) -> void:
	PaletteRepresents[palette] = voxel_id
	if palette == Palette.get_selected_id():
		ColorPicked.color = Voxel.get_color(get_rpalette())
		if CursorDynamic.pressed:
			var color = ColorPicked.color
			color.a = 0.5
			set_cursor_color(color)
		if not VoxelSetViewer.Selections.has(voxel_id):
			VoxelSetViewer.select(voxel_id)

func get_palette(palette : int = Palette.get_selected_id()) -> int:
	return PaletteRepresents[palette]

func get_rpalette(palette : int = get_palette()) -> Dictionary:
	return VoxelObjectRef.VoxelSetRef.get_voxel(palette)

const DefaultConfig := {
	"cursor.visible": true,
	"cursor.dynamic": true,
	"cursor.color": Color.white,
	"grid.visible": true,
	"grid.mode": VoxelGrid.GridModes.WIRED,
	"grid.color": Color.white,
	"grid.constant": true
}
var Config := {}
func save_config() -> void:
	var config = File.new()
	var opened = config.open(
		"res://addons/Voxel-Core/engine/VoxelObjectEditor/config.json",
		File.WRITE
	)
	if opened == OK:
		config.store_string(JSON.print(Config))
		config.close()

func load_config() -> void:
	var config = File.new()
	var opened = config.open(
		"res://addons/Voxel-Core/engine/VoxelObjectEditor/config.json",
		File.READ
	)
	if opened == OK:
		var config_ = JSON.parse(config.get_as_text())
		if config_.error == OK and typeof(config_.result) == TYPE_DICTIONARY:
			Config = config_.result
			
			Config["cursor.color"] = Config["cursor.color"].split_floats(",")
			Config["cursor.color"] = Color(
				Config["cursor.color"][0],
				Config["cursor.color"][1],
				Config["cursor.color"][2],
				Config["cursor.color"][3]
			)
			
			Config["grid.color"] = Config["grid.color"].split_floats(",")
			Config["grid.color"] = Color(
				Config["grid.color"][0],
				Config["grid.color"][1],
				Config["grid.color"][2],
				Config["grid.color"][3]
			)
		else: Config = DefaultConfig.duplicate()
		config.close()
	else: Config = DefaultConfig.duplicate()
	
	set_cursor_visible(Config["cursor.visible"])
	set_cursor_dynamic(Config["cursor.dynamic"])
	set_cursor_color(Config["cursor.color"])
	
	set_grid_visible(Config["grid.visible"])
	set_grid_mode(Config["grid.mode"])
	set_grid_color(Config["grid.color"])
	set_grid_constant(Config["grid.constant"])

func reset_config() -> void:
	Config = DefaultConfig.duplicate()
	save_config()
	load_config()



# Utilities
func raycast_for(camera : Camera, screen_position : Vector2, target : Node) -> Dictionary:
	var hit := {}
	var exclude := []
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * 1000
	while true:
		hit = camera.get_world().direct_space_state.intersect_ray(from, to, exclude)
		if not hit.empty():
			if target.is_a_parent_of(hit.collider):
				if Grid.is_a_parent_of(hit.collider):
					hit["normal"] = Vector3.ZERO
				hit["position"] = Voxel.world_to_grid(
					VoxelObjectRef.to_local(
						hit.position + -hit.normal * (Voxel.VoxelSize / 2)
					)
				)
				break
			else: exclude.append(hit.collider)
		else: break
	return hit

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



# Core
func _ready():
	if not is_instance_valid(Undo_Redo):
		Undo_Redo = UndoRedo.new()
	
	update_tools()
	update_palette()
	update_selections()
	update_mirrors()
	update_settings()
	update_grid_mode()
	
	load_config()

func _exit_tree():
	if is_instance_valid(Grid):
		Grid.queue_free()
	for cursor in Cursors:
		if is_instance_valid(Cursors[cursor]):
			Cursors[cursor].queue_free()


func setup_voxel_set(voxel_set : VoxelSet) -> void:
	VoxelSetViewer.VoxelSetRef = voxel_set
	
	Editing.pressed = false
	Editing.disabled = not is_instance_valid(voxel_set)
	Options.visible = is_instance_valid(voxel_set)
	Notice.visible = not is_instance_valid(voxel_set)

func start_editing(voxel_object : VoxelObject) -> void:
	stop_editing()
	
	VoxelObjectRef = voxel_object
	
	VoxelObjectRef.add_child(Grid)
	for cursor in Cursors.values():
		VoxelObjectRef.add_child(cursor)
	
	setup_voxel_set(VoxelObjectRef.VoxelSetRef)
	VoxelObjectRef.connect("set_voxel_set", self, "setup_voxel_set")
	VoxelObjectRef.connect("tree_exiting", self, "stop_editing", [true])

func stop_editing(close := false) -> void:
	if is_instance_valid(VoxelObjectRef):
		VoxelObjectRef.EditHint = false
		
		VoxelObjectRef.remove_child(Grid)
		for cursor in Cursors.values():
			VoxelObjectRef.remove_child(cursor)
		
		VoxelObjectRef.disconnect("set_voxel_set", self, "setup_voxel_set")
		VoxelObjectRef.disconnect("tree_exiting", self, "stop_editing")
	
	Editing.pressed = false
	VoxelObjectRef = null
	
	if close: emit_signal("close")


func handle_input(camera : Camera, event : InputEvent) -> bool:
	if is_instance_valid(VoxelObjectRef):
		if event is InputEventMouse:
			var prev_hit = last_hit
			last_hit = raycast_for(camera, event.position, VoxelObjectRef)
			
			if Editing.pressed:
				if event.button_mask & ~BUTTON_MASK_LEFT > 0 or (event is InputEventMouseButton and not event.button_index == BUTTON_LEFT):
					set_cursors_visibility(false)
					return false
				
				var handle_result = SelectionModes[SelectionMode.get_selected_id()].select(
					self,
					event,
					prev_hit
				)
				
				if not GridConstant.pressed:
					Grid.Disabled = (not GridConstant.pressed and not VoxelObjectRef.empty()) or not GridVisible.pressed
				
				return handle_result
	return false


func _on_Editing_toggled(editing : bool):
	if is_instance_valid(VoxelObjectRef):
		VoxelObjectRef.EditHint = editing
	
	if not editing: set_cursors_visibility(false)
	elif not last_hit.empty():
		set_cursors_selections()
		set_cursors_visibility(true)
	emit_signal("editing", editing)


func show_color_menu():
	ColorMenuColor.color = ColorPicked.color
	ColorMenu.popup_centered()

func _on_ColorMenu_Add_pressed():
	var voxel_id = VoxelObjectRef.VoxelSetRef.get_next_id()
	Undo_Redo.create_action("VoxelObjectEditor : Add voxel to used VoxeSet")
	Undo_Redo.add_do_method(VoxelObjectRef.VoxelSetRef, "set_voxel", Voxel.colored(ColorMenuColor.color))
	Undo_Redo.add_undo_method(VoxelObjectRef.VoxelSetRef, "erase_voxel", voxel_id)
	Undo_Redo.add_do_method(VoxelObjectRef.VoxelSetRef, "request_refresh")
	Undo_Redo.add_undo_method(VoxelObjectRef.VoxelSetRef, "request_refresh")
	Undo_Redo.commit_action()
	VoxelSetViewer.select(voxel_id)
	ColorMenu.hide()


func _on_Tool_selected(id : int):
	update_mirrors(Tools[id].mirror_modes)
	update_selections(Tools[id].selection_modes)

func _on_Palette_selected(id : int) -> void:
	set_palette(Palette.get_selected_id(), PaletteRepresents[Palette.get_selected_id()])

func _on_SelectionMode_selected(id : int):
	set_cursors_selections()


func _on_VoxelSetViewer_selected(voxel_id : int) -> void:
	set_palette(Palette.get_selected_id(), voxel_id)

func _on_GenerateVoxelSet_confirmed():
	VoxelObjectRef.generate_voxel_set()

func _on_ImportFile_file_selected(path : String):
	var result := Reader.read_file(path)
	if result["error"] == OK:
		var voxels = {}
		for voxel_position in result["voxels"]:
			voxels[voxel_position] = result["palette"][result["voxels"][voxel_position]]
		VoxelObjectRef.set_voxels(voxels)
		VoxelObjectRef.update_mesh()
	else: printerr(result["error"])


func _on_Docs_pressed():
	OS.shell_open("https://github.com/ClarkThyLord/Voxel-Core/wiki")

func _on_Issues_pressed():
	OS.shell_open("https://github.com/ClarkThyLord/Voxel-Core/issues")

func _on_GitHub_pressed():
	OS.shell_open("https://github.com/ClarkThyLord/Voxel-Core")


func _on_Translate_Apply_pressed():
	VoxelObjectRef.move(Vector3(
		MoveX.value,
		MoveY.value,
		MoveZ.value
	))
	VoxelObjectRef.update_mesh()

func _on_Center_Apply_pressed():
	VoxelObjectRef.center(Vector3(
		CenterX.value - 0.5,
		CenterY.value - 0.5,
		CenterZ.value - 0.5
	))
	VoxelObjectRef.update_mesh()
