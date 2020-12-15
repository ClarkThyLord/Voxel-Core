tool
extends ScrollContainer



# Refrences
onready var VoxelSetInfo := get_node("HBoxContainer/VBoxContainer/VoxelSetInfo")

onready var VoxelInfo := get_node("HBoxContainer/VBoxContainer/VoxelInfo")
onready var VoxelID := get_node("HBoxContainer/VBoxContainer/VoxelInfo/HBoxContainer/VoxelID")
onready var VoxelName := get_node("HBoxContainer/VBoxContainer/VoxelInfo/HBoxContainer/VoxelName")
onready var VoxelData := get_node("HBoxContainer/VBoxContainer/VoxelInfo/VoxelData")


onready var Duplicate := get_node("HBoxContainer/VBoxContainer2/ToolBar/Duplicate")
onready var Remove := get_node("HBoxContainer/VBoxContainer2/ToolBar/Remove")

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
			VoxelSetInfo.text = "Voxels: " + str(VoxelSetRef.Voxels.size())
			VoxelSetInfo.text += "\nTiled: " + str(is_instance_valid(VoxelSetRef.Tiles))
			VoxelSetInfo.text += "\nTile Size: " + str(Vector2.ONE * VoxelSetRef.TileSize)
		
		if VoxelSetViewer:
			if VoxelSetViewer.Selections.size() == 1:
				var id = VoxelSetViewer.Selections[0]
				if Duplicate: Duplicate.visible = true
				if Remove: Remove.visible = true
				
				VoxelInfo.visible = true
				VoxelID.text = str(id)
				VoxelName.text = VoxelSetRef.id_to_name(id)
				VoxelData.text = var2str(VoxelSetRef.get_voxel(id))
				
				if VoxelInspector:
					VoxelInspector.visible = true
					VoxelViewer.setup(VoxelSetRef, id)
			else:
				if Duplicate: Duplicate.visible = false
				if Remove: Remove.visible = false
				
				if VoxelInfo:
					VoxelInfo.visible = false
				
				if VoxelInspector:
					VoxelInspector.visible = false


func _on_Save_pressed():
	ResourceSaver.save(VoxelSetRef.resource_path, VoxelSetRef.duplicate())

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
	Undo_Redo.add_do_method(VoxelSetRef, "erase_voxel", id, false)
	Undo_Redo.add_undo_method(VoxelSetRef, "set_voxel", voxel, id, name, false)
	
	var _name = VoxelSetRef.id_to_name(new_id)
	var _voxel = VoxelSetRef.get_voxel(new_id)
	if not voxel.empty():
		Undo_Redo.add_do_method(VoxelSetRef, "erase_voxel", new_id, false)
	Undo_Redo.add_do_method(VoxelSetRef, "set_voxel", voxel, new_id, name, false)
	if voxel.empty():
		Undo_Redo.add_undo_method(VoxelSetRef, "erase_voxel", new_id, false)
	else:
		Undo_Redo.add_undo_method(VoxelSetRef, "set_voxel", _voxel, new_id, _name, false)
	
	Undo_Redo.add_do_method(VoxelSetRef, "updated_voxels")
	Undo_Redo.add_undo_method(VoxelSetRef, "updated_voxels")
	Undo_Redo.commit_action()

func _on_VoxelName_text_entered(new_name : String):
	if new_name.empty():
		var name = VoxelSetRef.id_to_name(VoxelSetViewer.Selections[0])
		Undo_Redo.create_action("VoxelSetEditor : Remove voxel name")
		Undo_Redo.add_do_method(VoxelSetRef, "unname_voxel", name)
		Undo_Redo.add_undo_method(VoxelSetRef, "name_voxel", VoxelSetViewer.Selections[0], name)
		Undo_Redo.add_do_method(VoxelSetRef, "updated_voxels")
		Undo_Redo.add_undo_method(VoxelSetRef, "updated_voxels")
		Undo_Redo.commit_action()
	else:
		Undo_Redo.create_action("VoxelSetEditor : Rename voxel")
		Undo_Redo.add_do_method(VoxelSetRef, "name_voxel", VoxelSetViewer.Selections[0], new_name)
		var id = VoxelSetRef.name_to_id(new_name)
		if id > -1:
			Undo_Redo.add_undo_method(VoxelSetRef, "name_voxel", id, new_name)
		var name = VoxelSetRef.id_to_name(VoxelSetViewer.Selections[0])
		if not name.empty():
			Undo_Redo.add_undo_method(VoxelSetRef, "name_voxel", VoxelSetViewer.Selections[0], name)
		Undo_Redo.add_do_method(VoxelSetRef, "updated_voxels")
		Undo_Redo.add_undo_method(VoxelSetRef, "updated_voxels")
		Undo_Redo.commit_action()


func _on_Add_pressed():
	Undo_Redo.create_action("VoxelSetEditor : Add voxel")
	Undo_Redo.add_do_method(VoxelSetRef, "set_voxel", Voxel.colored(Color.white))
	Undo_Redo.add_undo_method(VoxelSetRef, "erase_voxel", VoxelSetRef.get_next_id())
	Undo_Redo.commit_action()

func _on_Duplicate_pressed():
	Undo_Redo.create_action("VoxelSetEditor : Duplicate voxel")
	Undo_Redo.add_do_method(VoxelSetRef, "set_voxel", VoxelSetRef.get_voxel(VoxelSetViewer.Selections[0]).duplicate(true))
	Undo_Redo.add_undo_method(VoxelSetRef, "erase_voxel", VoxelSetRef.get_next_id())
	Undo_Redo.commit_action()

func _on_Remove_pressed():
	Undo_Redo.create_action("VoxelSetEditor : Remove voxel")
	Undo_Redo.add_do_method(VoxelSetRef, "erase_voxel", VoxelSetViewer.Selections[0])
	Undo_Redo.add_undo_method(
		VoxelSetRef,
		"set_voxel",
		VoxelSetRef.get_voxel(VoxelSetViewer.Selections[0]),
		VoxelSetRef.id_to_name(VoxelSetViewer.Selections[0]),
		VoxelSetViewer.Selections[0]
	)
	Undo_Redo.commit_action()

func _on_VoxelSetViewer_selected(voxel_id : int): update_view()
func _on_VoxelSetViewer_unselected(voxel_id : int): update_view()
