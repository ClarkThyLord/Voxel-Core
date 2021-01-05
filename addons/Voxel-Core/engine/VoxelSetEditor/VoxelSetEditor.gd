tool
extends ScrollContainer



## Signals
# Emited when editor needs closing
signal close



## Exported Variables
export(Resource) var voxel_set = null setget set_voxel_set



## Public Variables
var undo_redo : UndoRedo



## Private Variables
var import_file_path := ""



## OnReady Variables
onready var ImportMenu := get_node("HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Import/ImportFile")

onready var ImportHow := get_node("HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Import/ImportHow")

onready var VoxelSetInfo := get_node("HBoxContainer/VBoxContainer/VoxelSetInfo")

onready var VoxelInfo := get_node("HBoxContainer/VBoxContainer/VoxelInfo")

onready var VoxelID := get_node("HBoxContainer/VBoxContainer/VoxelInfo/HBoxContainer/VoxelID")

onready var VoxelName := get_node("HBoxContainer/VBoxContainer/VoxelInfo/HBoxContainer/VoxelName")

onready var VoxelData := get_node("HBoxContainer/VBoxContainer/VoxelInfo/VoxelData")

onready var VoxelSetViewer := get_node("HBoxContainer/VBoxContainer2/VoxelSetViewer")

onready var VoxelInspector := get_node("HBoxContainer/VoxelInspector")

onready var VoxelViewer := get_node("HBoxContainer/VoxelInspector/VoxelViewer")



## Built-In Virtual Methods
func _ready():
	set_voxel_set(voxel_set)
	
	if not is_instance_valid(undo_redo):
		undo_redo = UndoRedo.new()
	VoxelSetViewer.undo_redo = undo_redo
	VoxelViewer.undo_redo = undo_redo



## Public Methods
func set_voxel_set(value : Resource, update := true) -> void:
	if not typeof(voxel_set) == TYPE_NIL and not voxel_set is VoxelSet:
		printerr("VoxelSetEditor : Invalid Resource given expected VoxelSet")
		return
	
	if is_instance_valid(voxel_set):
		if voxel_set.is_connected("requested_refresh", self, "update_view"):
			voxel_set.disconnect("requested_refresh", self, "update_view") 
	
	voxel_set = value
	if is_instance_valid(voxel_set):
		if not voxel_set.is_connected("requested_refresh", self, "update_view"):
			voxel_set.connect("requested_refresh", self, "update_view")
	if is_instance_valid(VoxelSetViewer):
		VoxelSetViewer.voxel_set = voxel_set
	
	if update:
		update_view()


func update_view() -> void:
	if is_instance_valid(voxel_set):
		if is_instance_valid(VoxelSetInfo):
			VoxelSetInfo.text = "Voxels:\t\t" + str(voxel_set.size())
			VoxelSetInfo.text += "\nUV Ready:\t" + str(voxel_set.uv_ready())
		
		if is_instance_valid(VoxelSetViewer):
			var editing_single : bool = VoxelSetViewer.get_selected_size() == 1
			VoxelSetInfo.size_flags_vertical = Container.SIZE_FILL if editing_single else Container.SIZE_EXPAND_FILL
			VoxelInfo.visible = editing_single
			VoxelInspector.visible = editing_single
			
			if editing_single:
				var id = VoxelSetViewer.get_selected(0)
				
				VoxelID.text = str(id)
				VoxelName.text = voxel_set.id_to_name(id)
				VoxelData.text = var2str(voxel_set.get_voxel(id))
				
				VoxelViewer.setup(voxel_set, id)
	else:
		if not is_instance_valid(VoxelSetInfo):
			return
		VoxelSetInfo.text = ""


# Show import menu centered
func show_import_menu() -> void:
	ImportMenu.popup_centered()


# Hide import menu
func hide_import_menu() -> void:
	ImportMenu.hide()


# Show import how centered
func show_import_how():
	ImportHow.popup_centered()


# Hide import how
func hide_import_how():
	ImportHow.hide()



## Private Methods
func _on_Refresh_pressed():
	voxel_set.request_refresh()


func _on_Import_file_selected(path):
	import_file_path = path
	show_import_how()


func _on_Import_Append_pressed():
	var result = voxel_set.load_file(import_file_path, true)
	if result == OK:
		voxel_set.request_refresh()
	else:
		printerr(result)
	hide_import_how()


func _on_Import_Replace_pressed():
	var result = voxel_set.load_file(import_file_path, false)
	if result == OK:
		voxel_set.request_refresh()
	else:
		printerr(result)
	hide_import_how()


func _on_Close_pressed():
	emit_signal("close")


func _on_VoxelID_text_entered(new_id):
	if not new_id.is_valid_integer():
		return
	new_id = new_id.to_int()
	if new_id == VoxelSetViewer.get_selected(0):
		return
	elif new_id <= -1 or new_id >= voxel_set.size():
		return
	
	var id = VoxelSetViewer.get_selected(0)
	var voxel = voxel_set.get_voxel(id)
	undo_redo.create_action("VoxelSetEditor : Set voxel id")
	undo_redo.add_do_method(voxel_set, "erase_voxel", id)
	undo_redo.add_undo_method(voxel_set, "insert_voxel", id, voxel)
	undo_redo.add_do_method(voxel_set, "insert_voxel", new_id, voxel)
	undo_redo.add_undo_method(voxel_set, "erase_voxel", new_id)
	undo_redo.add_do_method(voxel_set, "request_refresh")
	undo_redo.add_undo_method(voxel_set, "request_refresh")
	undo_redo.commit_action()
	VoxelSetViewer.unselect_all()
	VoxelSetViewer.select(new_id)


func _on_VoxelName_text_entered(new_name : String):
	var voxel_id = VoxelSetViewer.get_selected(0)
	var voxel = voxel_set.get_voxel(voxel_id)
	if new_name == Voxel.get_name(voxel):
		return
	
	var _voxel = voxel.duplicate(true)
	if new_name.empty():
		undo_redo.create_action("VoxelSetEditor : Remove voxel name")
		Voxel.remove_name(_voxel)
	else:
		undo_redo.create_action("VoxelSetEditor : Set voxel name")
		Voxel.set_name(_voxel, new_name)
	Voxel.clean(_voxel)
	undo_redo.add_do_method(voxel_set, "set_voxel", voxel_id, _voxel)
	undo_redo.add_undo_method(voxel_set, "set_voxel", voxel_id, voxel)
	undo_redo.add_do_method(voxel_set, "request_refresh")
	undo_redo.add_undo_method(voxel_set, "request_refresh")
	undo_redo.commit_action()


func _on_VoxelSetViewer_selected(voxel_id : int):
	update_view()


func _on_VoxelSetViewer_unselected(voxel_id : int):
	update_view()
