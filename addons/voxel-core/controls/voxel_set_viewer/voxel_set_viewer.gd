tool
extends Control
# Listing of voxels in VoxelSet, with the ability to search, select and edit voxels.



## Signals
# Emitted when voxel has been selected
signal selected_voxel(voxel_id)
# Emitted when voxel has been unselected
signal unselected_voxel(voxel_id)



## Constants
const VoxelButton := preload("res://addons/voxel-core/controls/voxel_button/voxel_button.tscn")



## Exported Variables
# Search being done
export var search := "" setget set_search

# Flag indicating whether edits are allowed
export var allow_edit := false setget set_edit_mode

# Number of uv positions that can be selected at any one time
export(int, -1, 256) var selection_max := 0 setget set_selection_max

# Flag indicating whether Hints is visible
export var show_hints := false setget set_show_hints

# VoxelSet being used
export(Resource) var voxel_set = null setget set_voxel_set



## Public Variables
# UndoRedo used to commit operations
var undo_redo : UndoRedo



## Private Variables
# Selected voxel ids
var _selections := []



## OnReady Variables
onready var Search := get_node("VBoxContainer/Search")

onready var Voxels := get_node("VBoxContainer/ScrollContainer/Voxels")

onready var Hints := get_node("VBoxContainer/Hints")

onready var Hint := get_node("VBoxContainer/Hints/Hint")

onready var ContextMenu := get_node("ContextMenu")



## Built-In Virtual Methods
func _ready():
	set_show_hints(show_hints)
	set_voxel_set(voxel_set)
	
	if not is_instance_valid(undo_redo):
		undo_redo = UndoRedo.new()



## Public Methods
# Sets search, and calls on update_view by default
func set_search(value : String, update := true) -> void:
	search = value
	
	if is_instance_valid(Search):
		Search.text = search
	if update:
		update_view()


# Sets allow_edit
func set_edit_mode(value : bool, update := true) -> void:
	allow_edit = value


# Sets selection_max, and shrinks _selections to new maximum if needed
func set_selection_max(value : int) -> void:
	selection_max = clamp(value, -1, 256)
	unselect_shrink()


# Setter for show_hints
func set_show_hints(value := show_hints) -> void:
	show_hints = value
	
	if is_instance_valid(Hints):
		Hints.visible = show_hints and (allow_edit or selection_max)
		if show_hints:
			Hint.text = ""
			if allow_edit:
				Hint.text += "right click : context menu"
			if selection_max == -1 or selection_max > 1:
				Hint.text += ", ctrl + left click : multiple select / unselect"


# Setter for voxel_set
func set_voxel_set(value : Resource, update := true) -> void:
	if not (typeof(value) == TYPE_NIL or value is VoxelSet):
		printerr("Invalid Resource given expected VoxelSet")
		return
	
	if is_instance_valid(voxel_set):
		if voxel_set.is_connected("requested_refresh", self, "update_view"):
			voxel_set.disconnect("requested_refresh", self, "update_view") 
	
	voxel_set = value
	if is_instance_valid(voxel_set):
		if not voxel_set.is_connected("requested_refresh", self, "update_view"):
			voxel_set.connect("requested_refresh", self, "update_view", [true])
	elif is_instance_valid(Voxels):
		for child in Voxels.get_children():
			Voxels.remove_child(child)
			child.queue_free()
	
	if update:
		update_view(true)


# Returns true if voxel set id is selected
func has_selected(voxel_id : int) -> bool:
	return _selections.has(voxel_id)


func get_selected(index : int) -> int:
	return _selections[index]


func get_selections() -> Array:
	return _selections.duplicate()


func get_selected_size() -> int:
	return _selections.size()


# Returns VoxelButton with given voxel_id if found, else returns null
func get_voxel_button(voxel_id : int):
	return Voxels.find_node(str(voxel_id), false, false) if Voxels else null


# Selects voxel with given voxel_id if found, and emits selected_voxel
func select(voxel_id : int, emit := true) -> void:
	if selection_max == 0:
		return
	
	var voxel_button = get_voxel_button(voxel_id)
	if not is_instance_valid(voxel_button):
		return
	
	unselect_shrink(selection_max - 1, emit)
	
	voxel_button.pressed = true
	_selections.append(voxel_id)
	if emit:
		emit_signal("selected_voxel", voxel_id)


# Unselects voxel with given voxel_id if found, and emits unselected_voxel
func unselect(voxel_id : int, emit := true) -> void:
	var index := _selections.find(voxel_id)
	if index == -1:
		return
	
	_selections.remove(index)
	var voxel_button = get_voxel_button(voxel_id)
	if is_instance_valid(voxel_button):
		voxel_button.pressed = false
	if emit:
		emit_signal("unselected_voxel", voxel_id)


# Unselects all selected voxel ids
func unselect_all(emit := true) -> void:
	while not _selections.empty():
		unselect(_selections[-1], emit)


# Unselects all voxels ids until given size is met
func unselect_shrink(size := selection_max, emit := true) -> void:
	if size >= 0:
		while _selections.size() > size:
			unselect(_selections[-1], emit)


# Updates the listing of voxels
# redraw   :   bool   :   if true will repopulate listing with new Voxel Buttons
func update_view(redraw := false) -> void:
	if is_instance_valid(Voxels) and is_instance_valid(voxel_set):
		if redraw:
			for child in Voxels.get_children():
				Voxels.remove_child(child)
				child.queue_free()
			
			for id in voxel_set.get_ids():
				var voxel_button := VoxelButton.instance()
				voxel_button.name = str(id)
				voxel_button.set_voxel_id(id, false)
				voxel_button.set_voxel_set(voxel_set, false)
				voxel_button.update_view()
				voxel_button.toggle_mode = true
				voxel_button.pressed = _selections.has(id)
				voxel_button.mouse_filter = Control.MOUSE_FILTER_PASS
				voxel_button.connect("pressed", self, "_on_VoxelButton_pressed", [voxel_button])
				Voxels.add_child(voxel_button)
		
		var keys := search.split(",", false)
		for id in voxel_set.get_ids():
			var show = true
			for key in keys:
				if (key.is_valid_integer() and id == key.to_int()) or voxel_set.id_to_name(id).find(key) > -1:
					show = true
					break
				show = false
			
			if not show:
				unselect(id)
			get_voxel_button(id).visible = show
		call_deferred("correct")


# Corrects the columns of listing to fit as many voxels horizonataly
func correct() -> void:
	if is_instance_valid(Voxels):
		Voxels.columns = int(floor(rect_size.x / 36))



## Private Methods
func _on_Voxels_gui_input(event):
	if allow_edit and event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		ContextMenu.clear()
		if _selections.size() > 1:
			ContextMenu.add_icon_item(
					preload("res://addons/voxel-core/assets/controls/cancel.png"),
					"Deselect voxels", 3)
			ContextMenu.add_separator()
		ContextMenu.add_icon_item(
					preload("res://addons/voxel-core/assets/controls/add.png"),
					"Add voxel", 0)
		if _selections.size() == 1:
			ContextMenu.add_icon_item(
					preload("res://addons/voxel-core/assets/controls/duplicate.png"),
					"Duplicate voxel", 1)
			ContextMenu.add_icon_item(
					preload("res://addons/voxel-core/assets/controls/sub.png"),
					"Remove voxel", 2)
		elif _selections.size() > 1:
			ContextMenu.add_separator()
			ContextMenu.add_icon_item(
					preload("res://addons/voxel-core/assets/controls/duplicate.png"),
					"Duplicate voxels", 4)
			ContextMenu.add_icon_item(
					preload("res://addons/voxel-core/assets/controls/sub.png"),
					"Remove voxels", 5)
		ContextMenu.set_as_minsize()
		
		ContextMenu.popup(Rect2(event.global_position, ContextMenu.rect_size))


func _on_VoxelButton_pressed(voxel_button) -> void:
	if selection_max != 0:
		if voxel_button.pressed:
			if not Input.is_key_pressed(KEY_CONTROL):
				unselect_all()
			select(voxel_button.voxel_id)
		else:
			if _selections.has(voxel_button.voxel_id):
				unselect_all()
				select(voxel_button.voxel_id)
			else:
				unselect(voxel_button.voxel_id)
	else: voxel_button.pressed = false


func _on_ContextMenu_id_pressed(_id : int):
	match _id:
		0:
			var id = voxel_set.size()
			undo_redo.create_action("VoxelSetViewer : Add voxel")
			undo_redo.add_do_method(voxel_set, "add_voxel", Voxel.colored(Color.white))
			undo_redo.add_undo_method(voxel_set, "erase_voxel", id)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
			unselect_all()
			select(id)
		1:
			var id = voxel_set.size()
			undo_redo.create_action("VoxelSetViewer : Duplicate voxel")
			undo_redo.add_do_method(
					voxel_set,
					"add_voxel",
					voxel_set.get_voxel(_selections[0]).duplicate(true))
			undo_redo.add_undo_method(voxel_set, "erase_voxel", id)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
			unselect_all()
			select(id)
		2:
			undo_redo.create_action("VoxelSetViewer : Remove voxel")
			undo_redo.add_do_method(voxel_set, "erase_voxel", _selections[0])
			undo_redo.add_undo_method(
					voxel_set,
					"insert_voxel",
					_selections[0],
					voxel_set.get_voxel(_selections[0]))
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
			unselect(_selections[0])
		3: unselect_all()
		4:
			undo_redo.create_action("VoxelSetViewer : Duplicate voxels")
			var id = voxel_set.size()
			var ids = []
			for selection in range(_selections.size()):
				ids.append(id + selection)
				undo_redo.add_do_method(
						voxel_set,
						"add_voxel",
						voxel_set.get_voxel(_selections[selection]).duplicate(true))
				undo_redo.add_undo_method(
					voxel_set,
					"erase_voxel",
					id + _selections.size() - selection - 1)
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
			unselect_all()
			for _id in ids:
				select(_id)
		5: 
			undo_redo.create_action("VoxelSetViewer : Remove voxels")
			var selections := _selections.duplicate()
			selections.sort()
			for index in range(selections.size()):
				undo_redo.add_do_method(
						voxel_set,
						"erase_voxel",
						selections[selections.size() - index - 1])
				undo_redo.add_undo_method(
						voxel_set,
						"insert_voxel",
						selections[index],
						voxel_set.get_voxel(selections[index]))
			undo_redo.add_do_method(voxel_set, "request_refresh")
			undo_redo.add_undo_method(voxel_set, "request_refresh")
			undo_redo.commit_action()
			unselect_all()


func _on_Search_text_changed(new_text):
	search = new_text
	update_view()
