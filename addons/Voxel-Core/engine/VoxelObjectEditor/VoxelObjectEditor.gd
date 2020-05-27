tool
extends Control



# Imports
const VoxelGrid := preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelGrid/VoxelGrid.gd")
const VoxelCursor := preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelCursor/VoxelCursor.gd")

const VoxelObject := preload("res://addons/Voxel-Core/classes/VoxelObject.gd")



# Refrences
onready var Raw := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Raw")

onready var Tool := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/Tool")
onready var Palette := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/Palette")
onready var SelectionMode := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/SelectionMode")

onready var MirrorX := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer2/MirrorX")
onready var MirrorY := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer2/MirrorY")
onready var MirrorZ := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer2/MirrorZ")

onready var ColorChooser := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer3/ColorChooser")
onready var ColorPicked := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer3/ColorChooser/ColorPicked")

onready var VoxelSetViewer := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VoxelSetViewer")


onready var Lock := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/Lock")
onready var Commit := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/Commit")
onready var Cancel := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/Cancel")

onready var More := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/More")


onready var Settings := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings")


onready var ColorMenu := get_node("ColorMenu")
onready var ColorPickerRef := get_node("ColorMenu/VBoxContainer/ColorPicker")
onready var ColorMenuUse := get_node("ColorMenu/VBoxContainer/HBoxContainer/Use")
onready var ColorMenuAdd := get_node("ColorMenu/VBoxContainer/HBoxContainer/Add")



# Declarations
signal editing(state)
signal close


var Undo_Redo : UndoRedo

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

var last_hit
var selection := []
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

func set_cursors_visibility(visible := not Lock.pressed) -> void:
	Cursors[Vector3.ZERO].visible = visible
	var mirrors := get_mirrors()
	for cursor in Cursors:
		if not cursor == Vector3.ZERO:
			Cursors[cursor].visible = visible and mirrors.has(cursor)

func set_cursors_selections(
		selections := ([last_hit] if typeof(last_hit) == TYPE_VECTOR3 else []) if Lock.pressed else selection
	) -> void:
	Cursors[Vector3.ZERO].Selections = selections
	var mirrors := get_mirrors()
	for mirror in mirrors:
		Cursors[mirror].Selections = mirror_positions(selections, mirror)


enum Tools { ADD, SUB }


enum Palettes { PRIMARY, SECONDARY }
var PaletteRepresents := [
	Voxel.colored(Color.white),
	Voxel.colored(Color.white)
]

func set_palette(palette : int, voxel) -> void:
	PaletteRepresents[palette] = voxel
	
	if palette == Palette.get_selected_id():
		ColorPicked.color = Voxel.get_color(get_rpalette(palette))
		match typeof(voxel):
			TYPE_INT, TYPE_STRING:
				if VoxelSetViewer.Selections.empty() or not VoxelSetViewer.Selections[0] == voxel:
					VoxelSetViewer.select(voxel, null, false)
			_: VoxelSetViewer.unselect_all(false)

func get_palette(palette : int):
	return PaletteRepresents[palette]

func get_rpalette(palette : int) -> Dictionary:
	var represents = get_palette(palette)
	match typeof(represents):
		TYPE_INT, TYPE_STRING:
			if is_instance_valid(VoxelObjectRef.Voxel_Set):
				represents = VoxelObjectRef.Voxel_Set.get_voxel(represents)
			else: represents = Voxel.colored(Color.transparent)
	return represents


enum SelectionModes { INDIVIDUAL, AREA, EXTRUDE }


var VoxelObjectRef : VoxelObject setget begin



# Utilities
func raycast_for(camera : Camera, screen_position : Vector2, target : Node) -> Dictionary:
	var hit := {}
	var exclude := []
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * 1000
	while true:
		hit = camera.get_world().direct_space_state.intersect_ray(from, to, exclude)
		if not hit.empty():
			if target.is_a_parent_of(hit.collider): break
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
	
	Tool.clear()
	for tool_ in Tools.keys():
		Tool.add_icon_item(
			load("res://addons/Voxel-Core/assets/controls/" + tool_.to_lower() + ".png"),
			tool_.capitalize(),
			Tools[tool_]
		)
	
	Palette.clear()
	for palette in Palettes.keys():
		Palette.add_icon_item(
			load("res://addons/Voxel-Core/assets/controls/" + palette.to_lower() + ".png"),
			palette.capitalize(),
			Palettes[palette]
		)
	
	SelectionMode.clear()
	for select_mode in SelectionModes.keys():
		SelectionMode.add_icon_item(
			load("res://addons/Voxel-Core/assets/controls/" + select_mode.to_lower() + ".png"),
			select_mode.capitalize(),
			SelectionModes[select_mode]
		)
	
	for tab in range(More.get_tab_count()):
		var name : String = More.get_tab_title(tab)
		More.set_tab_icon(tab, load("res://addons/Voxel-Core/assets/controls/" + name.to_lower() + ".png"))
	
	for tab in range(Settings.get_tab_count()):
		var name : String = Settings.get_tab_title(tab)
		Settings.set_tab_icon(tab, load("res://addons/Voxel-Core/assets/controls/" + name.to_lower() + ".png"))

func _exit_tree():
	if is_instance_valid(Grid):
		Grid.queue_free()
	for cursor in Cursors:
		if is_instance_valid(Cursors[cursor]):
			Cursors[cursor].queue_free()


func begin(voxelobject : VoxelObject) -> void:
	cancel()
	
	VoxelObjectRef = voxelobject
	VoxelObjectRef.EditHint = true
	VoxelObjectRef.add_child(Grid)
	for cursor in Cursors.values():
		VoxelObjectRef.add_child(cursor)
	VoxelSetViewer.set_voxel_set(VoxelObjectRef.Voxel_Set)
	VoxelObjectRef.connect("tree_exiting", self, "cancel", [true])
	VoxelObjectRef.connect("set_voxel_set", VoxelSetViewer, "set_voxel_set")

func commit() -> void:
	cancel()

func cancel(close := false) -> void:
	if is_instance_valid(VoxelObjectRef):
		VoxelObjectRef.EditHint = false
		VoxelObjectRef.remove_child(Grid)
		for cursor in Cursors.values():
			VoxelObjectRef.remove_child(cursor)
		VoxelObjectRef.disconnect("tree_exiting", self, "cancel")
		VoxelObjectRef.disconnect("set_voxel_set", VoxelSetViewer, "set_voxel_set")
	
	Lock.pressed = true
	Commit.disabled = true
	Cancel.disabled = true
	
	VoxelObjectRef = null
	
	if close: emit_signal("close")


func handle_input(camera : Camera, event : InputEvent) -> bool:
	if is_instance_valid(VoxelObjectRef):
		if event is InputEventMouse:
			var hit := raycast_for(camera, event.position, VoxelObjectRef)
			
			
			var prev_hit = last_hit
			last_hit = null
			if not hit.empty():
				last_hit = Voxel.world_to_grid(VoxelObjectRef.to_local(hit.position))
			
			
			if not Lock.pressed:
				if event.button_mask & ~BUTTON_MASK_LEFT > 0 or (event is InputEventMouseButton and not event.button_index == BUTTON_LEFT):
					set_cursors_visibility(false)
					return false
				
				var consume := true
				if typeof(last_hit) == TYPE_VECTOR3: #  and not last_hit == prev_hit
					match SelectionMode.get_selected_id():
						SelectionModes.AREA:
							if event is InputEventMouseButton:
								match event.button_index:
									BUTTON_LEFT:
										if event.pressed:
											selection.clear()
											selection.append([last_hit, last_hit])
										else:
											selection.clear()
											selection.append(last_hit)
							elif event is InputEventMouseMotion:
								if not selection.empty() and typeof(selection[0]) == TYPE_ARRAY:
									if event.button_mask & BUTTON_MASK_LEFT == BUTTON_MASK_LEFT:
										selection[0][1] = last_hit
								else: continue
						SelectionModes.EXTRUDE:
							pass
						_:
							selection.clear()
							selection.append(last_hit)
					set_cursors_selections(selection)
				
				set_cursors_visibility(not hit.empty())
				return consume
	return false


func _on_Lock_toggled(locked : bool) -> void:
	if locked: set_cursors_visibility(false)
	elif typeof(last_hit) == TYPE_VECTOR3:
		set_cursors_selections([last_hit])
		set_cursors_visibility(true)
	emit_signal("editing", !locked)


func _on_ColorChooser_pressed():
	ColorPickerRef.color = ColorPicked.color
	
	ColorMenuAdd.visible = is_instance_valid(VoxelObjectRef.Voxel_Set) and not VoxelObjectRef.Voxel_Set.Locked
	
	ColorMenu.popup_centered()

func _on_ColorMenu_Use_pressed():
	set_palette(Palette.get_selected_id(), Voxel.colored(ColorPickerRef.color))
	ColorMenu.hide()

func _on_ColorMenu_Add_pressed():
	var voxel_id = VoxelObjectRef.Voxel_Set.get_id()
	Undo_Redo.create_action("VoxelObjectEditor : Add voxel")
	Undo_Redo.add_do_method(VoxelObjectRef.Voxel_Set, "set_voxel", Voxel.colored(ColorPickerRef.color))
	Undo_Redo.add_undo_method(VoxelObjectRef.Voxel_Set, "erase_voxel", voxel_id)
	Undo_Redo.commit_action()
	VoxelSetViewer.select(voxel_id)
	ColorMenu.hide()


func _on_Palette_selected(id : int) -> void:
	set_palette(Palette.get_selected_id(), PaletteRepresents[Palette.get_selected_id()])


func _on_VoxelSetViewer_selected(voxel_id : int) -> void:
	set_palette(Palette.get_selected_id(), voxel_id)

func _on_VoxelSetViewer_unselected(voxel_id : int) -> void:
	if VoxelSetViewer.Selections.empty():
		set_palette(Palette.get_selected_id(), Voxel.colored(ColorPickerRef.color))
