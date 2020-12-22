tool
extends ScrollContainer



# Refrences
onready var ImportFile := get_node("HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Import/ImportFile")
onready var ImportHow := get_node("HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Import/ImportHow")

onready var VoxelSetInfo := get_node("HBoxContainer/VBoxContainer/VoxelSetInfo")

onready var VoxelInfo := get_node("HBoxContainer/VBoxContainer/VoxelInfo")
onready var VoxelID := get_node("HBoxContainer/VBoxContainer/VoxelInfo/HBoxContainer/VoxelID")
onready var VoxelName := get_node("HBoxContainer/VBoxContainer/VoxelInfo/HBoxContainer/VoxelName")
onready var VoxelData := get_node("HBoxContainer/VBoxContainer/VoxelInfo/VoxelData")

onready var VoxelSetViewer := get_node("HBoxContainer/VBoxContainer2/VoxelSetViewer")

onready var VoxelInspector := get_node("HBoxContainer/VoxelInspector")
onready var VoxelViewer := get_node("HBoxContainer/VoxelInspector/VoxelViewer")



# Declarations
signal close


var Undo_Redo : UndoRedo


export(Resource) var VoxelSetRef = null setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if not typeof(voxel_set) == TYPE_NIL and not voxel_set is VoxelSet:
		printerr("VoxelSetEditor : Invalid Resource given expected VoxelSet")
		return
	
	if is_instance_valid(VoxelSetRef):
		if VoxelSetRef.is_connected("requested_refresh", self, "update_view"):
			VoxelSetRef.disconnect("requested_refresh", self, "update_view") 
	
	VoxelSetRef = voxel_set
	if is_instance_valid(VoxelSetRef):
		VoxelSetRef.connect("requested_refresh", self, "update_view")
	if is_instance_valid(VoxelSetViewer):
		VoxelSetViewer.VoxelSetRef = VoxelSetRef
	
	if update: update_view()



# Core
func _ready():
	set_voxel_set(VoxelSetRef)
	
	if not is_instance_valid(Undo_Redo):
		Undo_Redo = UndoRedo.new()
	VoxelSetViewer.Undo_Redo = Undo_Redo
	VoxelViewer.Undo_Redo = Undo_Redo


func update_view() -> void:
	if is_instance_valid(VoxelSetRef):
		if is_instance_valid(VoxelSetInfo):
			VoxelSetInfo.text = "Voxels:\t\t" + str(VoxelSetRef.Voxels.size())
			VoxelSetInfo.text += "\nUV Ready:\t" + str(VoxelSetRef.UVReady)
		
		if is_instance_valid(VoxelSetViewer):
			var editing_single : bool = VoxelSetViewer.Selections.size() == 1
			VoxelInfo.visible = editing_single
			VoxelInspector.visible = editing_single
			
			if editing_single:
				var id = VoxelSetViewer.Selections[0]
				
				VoxelID.text = str(id)
				VoxelName.text = VoxelSetRef.id_to_name(id)
				VoxelData.text = var2str(VoxelSetRef.get_voxel(id))
				
				VoxelViewer.setup(VoxelSetRef, id)
	else:
		if not is_instance_valid(VoxelSetInfo):
			return
		VoxelSetInfo.text = ""


func _on_Close_pressed():
	emit_signal("close")


func _on_VoxelID_text_entered(new_id):
	if not new_id.is_valid_integer(): return
	new_id = int(abs(new_id.to_int()))
	if new_id == VoxelSetViewer.Selections[0]: return
	
	var id = VoxelSetViewer.Selections[0]
	var name = VoxelSetRef.id_to_name(id)
	var voxel = VoxelSetRef.get_voxel(id)
	Undo_Redo.create_action("VoxelSetEditor : Set voxel id")
	Undo_Redo.add_do_method(VoxelSetRef, "erase_voxel", id)
	Undo_Redo.add_undo_method(VoxelSetRef, "set_voxel", voxel, name, id)
	
	var _name = VoxelSetRef.id_to_name(new_id)
	var _voxel = VoxelSetRef.get_voxel(new_id)
	if not voxel.empty():
		Undo_Redo.add_do_method(VoxelSetRef, "erase_voxel", new_id)
	Undo_Redo.add_do_method(VoxelSetRef, "set_voxel", voxel, name, new_id)
	if voxel.empty():
		Undo_Redo.add_undo_method(VoxelSetRef, "erase_voxel", new_id)
	else:
		Undo_Redo.add_undo_method(VoxelSetRef, "set_voxel", _voxel, _name, new_id)
	
	Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
	Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
	Undo_Redo.commit_action()
	VoxelSetViewer.unselect_all()
	VoxelSetViewer.select(new_id)

func _on_VoxelName_text_entered(new_name : String):
	var voxel_id = VoxelSetViewer.Selections[0]
	if new_name.empty():
		var name = VoxelSetRef.id_to_name()
		Undo_Redo.create_action("VoxelSetEditor : Remove voxel name")
		Undo_Redo.add_do_method(VoxelSetRef, "unname_voxel", voxel_id)
		Undo_Redo.add_undo_method(VoxelSetRef, "name_voxel", voxel_id, name)
	else:
		Undo_Redo.create_action("VoxelSetEditor : Rename voxel")
		Undo_Redo.add_do_method(VoxelSetRef, "name_voxel", voxel_id, new_name)
		var id = VoxelSetRef.name_to_id(new_name)
		if id > -1:
			Undo_Redo.add_undo_method(VoxelSetRef, "name_voxel", id, new_name)
		var name = VoxelSetRef.id_to_name(voxel_id)
		if not name.empty():
			Undo_Redo.add_undo_method(VoxelSetRef, "name_voxel", voxel_id, name)
	Undo_Redo.add_do_method(VoxelSetRef, "request_refresh")
	Undo_Redo.add_undo_method(VoxelSetRef, "request_refresh")
	Undo_Redo.commit_action()
	VoxelSetViewer.unselect_all()
	VoxelSetViewer.select(voxel_id)


func _on_VoxelSetViewer_selected(voxel_id : int): update_view()
func _on_VoxelSetViewer_unselected(voxel_id : int): update_view()


func open_ImportFile():
	ImportFile.popup_centered()

func open_ImportHow():
	ImportHow.popup_centered()

func close_ImportHow():
	ImportHow.hide()

var import_file_path := ""
func _on_Import_file_selected(path):
	import_file_path = path
	open_ImportHow()

func _on_Import_Append_pressed():
	var result := Reader.read_file(import_file_path)
	if result["error"] == OK:
		for voxel in result["palette"]:
			VoxelSetRef.set_voxel(result["palette"][voxel])
		
		VoxelSetRef.request_refresh()
	else: printerr(result["error"])
	close_ImportHow()

func _on_Import_Replace_pressed():
	var result := Reader.read_file(import_file_path)
	if result["error"] == OK:
		VoxelSetRef.Voxels = result["palette"]
		
		VoxelSetRef.request_refresh()
	else: printerr(result["error"])
	close_ImportHow()
