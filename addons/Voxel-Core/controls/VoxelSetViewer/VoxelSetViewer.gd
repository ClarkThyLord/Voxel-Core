tool
extends Control



# Imports
const VoxelButton := preload("res://addons/Voxel-Core/controls/VoxelButton/VoxelButton.tscn")



# Refrences
onready var SearchRef := get_node("VBoxContainer/Search")

onready var Voxels := get_node("VBoxContainer/ScrollContainer/Voxels")

onready var ContextMenu := get_node("ContextMenu")



# Declarations
signal selected(index)
signal unselected(index)


export(bool) var EditMode := false setget set_edit_mode
func set_edit_mode(edit_mode : bool, update := true) -> void:
	EditMode = edit_mode
	
	if update: _update()



var Selections := [] setget set_selections
var selections_ref := [] setget set_selections
func set_selections(selections : Array) -> void: pass

export(bool) var SelectMode := false setget set_select_mode
func set_select_mode(select_mode : bool) -> void:
	SelectMode = select_mode

export(int, 0, 1000000000) var SelectionMax := 0 setget set_selection_max
func set_selection_max(selection_max : int) -> void:
	selection_max = abs(selection_max)
	if selection_max > 0 and selection_max < SelectionMax:
		var size = Selections.size()
		while size > selection_max:
			emit_signal("unselected", size - 1)
			Selections.remove(size - 1)
			selections_ref[size - 1].pressed = false
			selections_ref.remove(size - 1)
			size = Selections.size()
	
	SelectionMax = selection_max


export(String) var Search := "" setget set_search
func set_search(search : String, update := true) -> void:
	Search = search
	
	if SearchRef: SearchRef.text = search
	if update: _update()


export(Resource) var Voxel_Set = load("res://addons/Voxel-Core/defaults/VoxelSet.tres") setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if voxel_set is VoxelSet:
		if is_instance_valid(Voxel_Set):
			if Voxel_Set.is_connected("updated_voxels", self, "_update"):
				Voxel_Set.disconnect("updated_voxels", self, "_update")
			if Voxel_Set.is_connected("updated_texture", self, "_update"):
				Voxel_Set.disconnect("updated_texture", self, "_update")
		Voxel_Set = voxel_set
		Voxel_Set.connect("updated_voxels", self, "_update")
		Voxel_Set.connect("updated_texture", self, "_update")
		
		if update: _update()
	elif typeof(voxel_set) == TYPE_NIL:
		set_voxel_set(load("res://addons/Voxel-Core/defaults/VoxelSet.tres"), update)



# Core
func _ready():
	correct()
	_update()


func correct() -> void:
	if Voxels: Voxels.columns = int(floor(rect_size.x / 36))


func _update() -> void:
	if Voxels and is_instance_valid(Voxel_Set):
		var voxels : Dictionary
		if Search.length() > 0:
			var keys = Search.split(",")
			# TODO search
			voxels = Voxel_Set.Voxels
		else: voxels = Voxel_Set.Voxels
		
		for child in Voxels.get_children():
			child.queue_free()
		
		for voxel in voxels:
			var voxel_ref = VoxelButton.instance()
			voxel_ref.toggle_mode = true
			voxel_ref.mouse_filter = Control.MOUSE_FILTER_PASS
			voxel_ref.connect("toggled", self, "_on_VoxelButton_toggled", [voxel, voxel_ref])
			voxel_ref.setup_voxel(voxel, Voxel_Set)
			Voxels.add_child(voxel_ref)
	call_deferred("correct")


func _on_Search_text_changed(new_text):
	_update()


func _on_VoxelButton_toggled(toggled : bool, id : int, voxel_ref) -> void:
	if toggled:
		if SelectionMax == 0 or Selections.size() < SelectionMax:
			Selections.append(id)
			selections_ref.append(voxel_ref)
		else:
			emit_signal("unselected", SelectionMax - 1)
			Selections[SelectionMax - 1] = id
			selections_ref[SelectionMax - 1].pressed = false
			selections_ref[SelectionMax - 1] = voxel_ref
		emit_signal("selected", Selections.size() - 1)
	else:
		var index = Selections.find(id)
		if index > -1:
			emit_signal("unselected", index)
			Selections.remove(index)
			selections_ref.remove(index)


func _on_Voxels_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		ContextMenu.clear()
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
				preload("res://addons/Voxel-Core/assets/controls/cancel.png"),
				"Deselect voxels", 3
			)
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


func _on_ContextMenu_id_pressed(id : int):
	match id:
		0: print("add")
		1: print("duplicate")
		2: print("remove")
		3: print("deselect")
		4: print("duplicates")
		5: print("removes")
