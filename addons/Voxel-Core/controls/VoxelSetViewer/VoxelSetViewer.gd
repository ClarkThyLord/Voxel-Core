tool
extends Control
# Listing of voxels in VoxelSet, with the ability to search, select and edit voxels.



## Imports
const VoxelButton := preload("res://addons/Voxel-Core/controls/VoxelButton/VoxelButton.tscn")



## Refrences
onready var SearchRef := get_node("VBoxContainer/Search")

onready var Voxels := get_node("VBoxContainer/ScrollContainer/Voxels")

onready var Hints := get_node("VBoxContainer/Hints")
onready var HintRef := get_node("VBoxContainer/Hints/Hint")

onready var ContextMenu := get_node("ContextMenu")



## Declarations
# Emitted when voxel has been selected
signal selected_voxel(voxel_id)
# Emitted when voxel has been unselected
signal unselected_voxel(voxel_id)


# UndoRedo used to commit operations
var Undo_Redo : UndoRedo

# Selected voxel ids
var Selections := [] setget set_selections
# Prevent external modifications of selections
func set_selections(selections : Array) -> void: pass

# Search being done
export(String) var Search := "" setget set_search
# Sets Search, and calls on update_view by default
func set_search(search : String, update := true) -> void:
	Search = search
	
	if SearchRef: SearchRef.text = search
	if update: update_view()

# Flag indicating whether edits are allowed
export(bool) var AllowEdit := false setget set_edit_mode
# Sets AllowEdit
func set_edit_mode(edit_mode : bool, update := true) -> void:
	AllowEdit = edit_mode

# Number of uv positions that can be selected at any one time
export(int, -1, 256) var AllowedSelections := 0 setget set_allowed_selections
# Sets AllowedSelections, and shrinks Selections to new maximum if needed
func set_allowed_selections(allowed_selections : int) -> void:
	AllowedSelections = clamp(allowed_selections, -1, 256)
	unselect_shrink()

# Flag indicating whether Hints is visible
export(bool) var ShowHints := false setget set_show_hints
# Setter for ShowHints
func set_show_hints(show := ShowHints) -> void:
	ShowHints = show
	
	if is_instance_valid(Hints):
		Hints.visible = ShowHints and (AllowEdit or AllowedSelections)
		if ShowHints:
			HintRef.text = ""
			if AllowEdit:
				HintRef.text += "right click : context menu"
			if AllowedSelections != 0 or AllowedSelections != 1:
				HintRef.text += ", ctrl + left click : multiple select / unselect"


# VoxelSet being used
export(Resource) var VoxelSetRef = null setget set_voxel_set
# Setter for VoxelSetRef
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if not typeof(voxel_set) == TYPE_NIL and not voxel_set is VoxelSet:
		printerr("VoxelSetViewer : Invalid Resource given expected VoxelSet")
		return
	
	if is_instance_valid(VoxelSetRef):
		if VoxelSetRef.is_connected("requested_refresh", self, "update_view"):
			VoxelSetRef.disconnect("requested_refresh", self, "update_view") 
	
	VoxelSetRef = voxel_set
	if is_instance_valid(VoxelSetRef):
		VoxelSetRef.connect("requested_refresh", self, "update_view", [true])
	elif is_instance_valid(Voxels):
		for child in Voxels.get_children():
			Voxels.remove_child(child)
			child.queue_free()
	
	if update: update_view(true)



# Core
func _ready():
	set_show_hints(ShowHints)
	set_voxel_set(VoxelSetRef)
	
	if not is_instance_valid(Undo_Redo):
		Undo_Redo = UndoRedo.new()


# Returns VoxelButton with given voxel_id if found, else returns null
func get_voxel_button(voxel_id : int):
	return Voxels.find_node(str(voxel_id), false, false) if Voxels else null


# Selects voxel with given voxel_id if found, and emits selected_voxel
func select(voxel_id : int, emit := true) -> void:
	if AllowedSelections == 0:
		return
	
	var voxel_button = get_voxel_button(voxel_id)
	if not is_instance_valid(voxel_button):
		return
	
	unselect_shrink(AllowedSelections - 1, emit)
	
	voxel_button.pressed = true
	Selections.append(voxel_id)
	if emit: emit_signal("selected_voxel", voxel_id)

# Unselects voxel with given voxel_id if found, and emits unselected_voxel
func unselect(voxel_id : int, emit := true) -> void:
	var index := Selections.find(voxel_id)
	if index == -1:
		return
	
	Selections.remove(index)
	var voxel_button = get_voxel_button(voxel_id)
	if is_instance_valid(voxel_button):
		voxel_button.pressed = false
	if emit:
		emit_signal("unselected_voxel", voxel_id)

# Unselects all selected voxel ids
func unselect_all(emit := true) -> void:
	while not Selections.empty():
		unselect(Selections[-1], emit)

# Unselects all voxels ids until given size is met
func unselect_shrink(size := AllowedSelections, emit := true) -> void:
	if size >= 0:
		while Selections.size() > size:
			unselect(Selections[-1], emit)


# Updates the listing of voxels
# redraw   :   bool   :   if true will repopulate listing with new Voxel Buttons
func update_view(redraw := false) -> void:
	if is_instance_valid(Voxels) and is_instance_valid(VoxelSetRef):
		if redraw:
			for child in Voxels.get_children():
				Voxels.remove_child(child)
				child.queue_free()
			
			for id in VoxelSetRef.get_ids():
				var voxel_button := VoxelButton.instance()
				voxel_button.name = str(id)
				voxel_button.set_voxel_id(id, false)
				voxel_button.set_voxel_set(VoxelSetRef, false)
				voxel_button.update_view()
				voxel_button.toggle_mode = true
				voxel_button.mouse_filter = Control.MOUSE_FILTER_PASS
				voxel_button.connect("pressed", self, "_on_VoxelButton_pressed", [voxel_button])
				Voxels.add_child(voxel_button)
		
		var keys := Search.split(",", false)
		for id in VoxelSetRef.get_ids():
			var show = true
			for key in keys:
				if (key.is_valid_integer() and id == key.to_int()) or VoxelSetRef.id_to_name(id).find(key) > -1:
					show = true
					break
				show = false
			
			if not show:
				unselect(id)
			get_voxel_button(id).visible = show
		call_deferred("correct")

# Corrects the columns of listing to fit as many voxels horizonataly
func correct() -> void:
	if Voxels: Voxels.columns = int(floor(rect_size.x / 36))

func _on_Voxels_gui_input(event):
	if AllowEdit and event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		ContextMenu.clear()
		if Selections.size() > 1:
			ContextMenu.add_icon_item(
				preload("res://addons/Voxel-Core/assets/controls/cancel.png"),
				"Deselect voxels", 3
			)
			ContextMenu.add_separator()
		ContextMenu.add_icon_item(
			preload("res://addons/Voxel-Core/assets/controls/add.png"),
			"Add voxel", 0
		)
		if Selections.size() == 1:
			ContextMenu.add_icon_item(
				preload("res://addons/Voxel-Core/assets/controls/duplicate.png"),
				"Duplicate voxel", 1
			)
			ContextMenu.add_icon_item(
				preload("res://addons/Voxel-Core/assets/controls/sub.png"),
				"Remove voxel", 2
			)
		elif Selections.size() > 1:
			ContextMenu.add_separator()
			ContextMenu.add_icon_item(
				preload("res://addons/Voxel-Core/assets/controls/duplicate.png"),
				"Duplicate voxels", 4
			)
			ContextMenu.add_icon_item(
				preload("res://addons/Voxel-Core/assets/controls/sub.png"),
				"Remove voxels", 5
			)
		ContextMenu.set_as_minsize()
		
		ContextMenu.popup(Rect2(
			event.global_position,
			ContextMenu.rect_size
		))

func _on_VoxelButton_pressed(voxel_button) -> void:
	if AllowedSelections != 0:
		if voxel_button.pressed:
			if not Input.is_key_pressed(KEY_CONTROL):
				unselect_all()
			select(voxel_button.VoxelID)
		else:
			if Selections.has(voxel_button.VoxelID):
				unselect_all()
				select(voxel_button.VoxelID)
			else:
				unselect(voxel_button.VoxelID)
	else: voxel_button.pressed = false

func _on_ContextMenu_id_pressed(_id : int):
	match _id:
		0:
			Undo_Redo.create_action("VoxelSetViewer : Add voxel")
			Undo_Redo.add_do_method(VoxelSetRef, "set_voxel", Voxel.colored(Color.white))
			Undo_Redo.add_undo_method(VoxelSetRef, "erase_voxel", VoxelSetRef.get_next_id())
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
		1:
			Undo_Redo.create_action("VoxelSetViewer : Duplicate voxel")
			Undo_Redo.add_do_method(VoxelSetRef, "set_voxel", VoxelSetRef.get_voxel(Selections[0]).duplicate(true))
			Undo_Redo.add_undo_method(VoxelSetRef, "erase_voxel", VoxelSetRef.get_next_id())
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
		2:
			Undo_Redo.create_action("VoxelSetViewer : Remove voxel")
			Undo_Redo.add_do_method(VoxelSetRef, "erase_voxel", Selections[0])
			Undo_Redo.add_undo_method(
				VoxelSetRef,
				"set_voxel",
				VoxelSetRef.get_voxel(Selections[0]),
				Selections[0],
				VoxelSetRef.id_to_name(Selections[0])
			)
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
		3: unselect_all()
		4:
			Undo_Redo.create_action("VoxelSetViewer : Duplicate voxels")
			var id = VoxelSetRef.get_next_id()
			for selection in range(Selections.size()):
				Undo_Redo.add_do_method(VoxelSetRef, "set_voxel", VoxelSetRef.get_voxel(Selections[selection]).duplicate(true), "", id + selection)
				Undo_Redo.add_undo_method(VoxelSetRef, "erase_voxel", id + selection)
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
			unselect_all()
		5: 
			Undo_Redo.create_action("VoxelSetViewer : Remove voxels")
			for selection in Selections:
				Undo_Redo.add_do_method(VoxelSetRef, "erase_voxel", selection)
				Undo_Redo.add_undo_method(
					VoxelSetRef,
					"set_voxel",
					VoxelSetRef.get_voxel(selection),
					VoxelSetRef.id_to_name(selection),
					selection
				)
			Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
			Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
			Undo_Redo.commit_action()
			unselect_all()


func _on_Search_text_changed(new_text):
	Search = new_text
	update_view()
