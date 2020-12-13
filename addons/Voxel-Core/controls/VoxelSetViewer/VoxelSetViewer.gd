tool
extends Control



# Imports
const VoxelButton := preload("res://addons/Voxel-Core/controls/VoxelButton/VoxelButton.tscn")



# Refrences
onready var SearchRef := get_node("VBoxContainer/Search")

onready var Voxels := get_node("VBoxContainer/ScrollContainer/Voxels")

onready var Hints := get_node("VBoxContainer/Hints")
onready var HintRef := get_node("VBoxContainer/Hints/Hint")

onready var ContextMenu := get_node("ContextMenu")



# Declarations
signal selected(voxel_id)
signal unselected(voxel_id)

var Undo_Redo : UndoRedo

var Selections := [] setget set_selections
func set_selections(selections : Array) -> void: pass

export(String) var Search := "" setget set_search
func set_search(search : String, update := true) -> void:
	Search = search
	
	if SearchRef: SearchRef.text = search
	if update: update_view()

export(bool) var AllowEdit := false setget set_edit_mode
func set_edit_mode(edit_mode : bool, update := true) -> void:
	AllowEdit = edit_mode

export(bool) var AllowSelect := false setget set_select_mode
func set_select_mode(allow_select : bool) -> void:
	AllowSelect = allow_select
	if not AllowSelect: unselect_all()

export(int, 0, 1000000000) var SelectionMax := 0 setget set_selection_max
func set_selection_max(selection_max : int) -> void:
	selection_max = abs(selection_max)
	if selection_max > 0 and selection_max < SelectionMax:
		unselect_shrink()
	
	SelectionMax = selection_max

export(bool) var ShowHints := false setget set_show_hints
func set_show_hints(show := ShowHints) -> void:
	ShowHints = show
	
	if ShowHints and is_instance_valid(Hints):
		Hints.visible = AllowEdit or AllowSelect
		
		HintRef.text = ""
		if AllowEdit: HintRef.text += "right click : context menu"
		if AllowSelect: HintRef.text += ("   " if HintRef.text.length() > 0 else "")  + "ctrl + left click : select / unselect"


export(Resource) var VoxelSetRef = null setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if not typeof(voxel_set) == TYPE_NIL and not voxel_set is VoxelSet:
		printerr("Invalid Resource given expected VoxelSet")
		return
	
	if is_instance_valid(VoxelSetRef):
		if VoxelSetRef.is_connected("requested_refresh", self, "update_view"):
			VoxelSetRef.disconnect("requested_refresh", self, "update_view") 
	
	VoxelSetRef = voxel_set
	if is_instance_valid(VoxelSetRef) and VoxelSetRef is VoxelSet:
		VoxelSetRef.connect("requested_refresh", self, "update_view", [true])
	
	if update: update_view(true)



# Core
func _ready():
	print(VoxelSetRef)
	
	set_show_hints(ShowHints)
	set_voxel_set(VoxelSetRef)
	
	if not is_instance_valid(Undo_Redo):
		Undo_Redo = UndoRedo.new()


func get_voxel_button(voxel_id : int):
	return Voxels.find_node(str(voxel_id), false, false) if Voxels else null


func select(voxel_id : int, emit := true) -> void:
	if not AllowSelect:
		printerr("VoxelSetViewer : Selection isn't allowed")
		return
	
	var voxel_button = get_voxel_button(voxel_id)
	if not is_instance_valid(voxel_button):
		printerr("VoxelSetViewer : VoxelButton doesn't exist for " + str(voxel_id))
		return
	
	unselect_shrink(emit)
	
	voxel_button.pressed = true
	Selections.append(voxel_id)
	if emit: emit_signal("selected", voxel_id)

func unselect(voxel_id : int, emit := true) -> void:
	var index := Selections.find(voxel_id)
	if index == -1:
		printerr("VoxelID " + str(voxel_id) + "isn't selected")
		return
	
	var voxel_button = get_voxel_button(voxel_id)
	if not is_instance_valid(voxel_button):
		printerr("VoxelButton " + str(voxel_id) + " doesn't exist")
		return
	
	voxel_button.pressed = false
	Selections.remove(index)
	if emit: emit_signal("unselected", voxel_id)

func unselect_all(emit := true) -> void:
	while not Selections.empty():
		unselect(Selections[-1], emit)

func unselect_shrink(emit := true) -> void:
	if SelectionMax > 0:
		while Selections.size() > SelectionMax:
			unselect(Selections[-1], emit)


func update_view(redraw := false) -> void:
	print("update")
	if is_instance_valid(Voxels) and is_instance_valid(VoxelSetRef):
		print("start update")
		if redraw:
			print("redraw")
			for child in Voxels.get_children():
				Voxels.remove_child(child)
				child.queue_free()
			
			print(VoxelSetRef.get_ids())
			print(VoxelSetRef.Voxels)
			for id in VoxelSetRef.get_ids():
				print(id)
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
	if AllowSelect:
		if voxel_button.pressed:
			if not Input.is_key_pressed(KEY_CONTROL):
				unselect_all()
			select(voxel_button.VoxelID)
		else:
			if Selections.size() == 1 or (Selections.size() > 0 and Input.is_key_pressed(KEY_CONTROL)):
				for selection in range(Selections.size()):
					if Selections[selection] == voxel_button.VoxelID:
						unselect(selection)
						break
			else:
				unselect_all()
				select(voxel_button.VoxelID)
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
