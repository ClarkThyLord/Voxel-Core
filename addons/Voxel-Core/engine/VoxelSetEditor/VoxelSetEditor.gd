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
var Undo_Redo : UndoRedo

export(Resource) var Voxel_Set = load("res://addons/Voxel-Core/defaults/VoxelSet.tres") setget set_editing_voxel_set
func set_editing_voxel_set(editing_voxel_set : Resource, update := true) -> void:
	if editing_voxel_set is VoxelSet:
		if Voxel_Set.is_connected("updated_voxels", self, "_update"):
			Voxel_Set.disconnect("updated_voxels", self, "_update")
		Voxel_Set = editing_voxel_set
		Voxel_Set.connect("updated_voxels", self, "_update")
		
		if VoxelSetViewer:
			VoxelSetViewer.Voxel_Set = Voxel_Set
		
		if update: _update()
	elif typeof(editing_voxel_set) == TYPE_NIL:
		set_editing_voxel_set(load("res://addons/Voxel-Core/defaults/VoxelSet.tres"), update)



# Core
func _ready():
	_update()
	if not is_instance_valid(Undo_Redo):
		Undo_Redo = UndoRedo.new()


func _update() -> void:
	if VoxelSetInfo:
		VoxelSetInfo.text = "Voxels: " + str(Voxel_Set.Voxels.size())
		VoxelSetInfo.text += "\nTiled: " + str(is_instance_valid(Voxel_Set.Tiles))
		VoxelSetInfo.text += "\nTile Size: " + str(Vector2.ONE * Voxel_Set.TileSize)
	
	if VoxelSetViewer:
		if VoxelSetViewer.Selections.size() == 1:
			var id = VoxelSetViewer.Selections[0]
			if Duplicate: Duplicate.visible = true
			if Remove: Remove.visible = true
			
			VoxelInfo.visible = true
			VoxelID.text = str(id)
			VoxelName.text = Voxel_Set.id_to_name(id)
			VoxelData.text = var2str(Voxel_Set.get_voxel(id))
			
			if VoxelInspector:
				VoxelInspector.visible = true
				VoxelViewer.setup_voxel(id, Voxel_Set)
		else:
			if Duplicate: Duplicate.visible = false
			if Remove: Remove.visible = false
			
			if VoxelInfo:
				VoxelInfo.visible = false
			
			if VoxelInspector:
				VoxelInspector.visible = false


func _on_Save_pressed():
	ResourceSaver.save(Voxel_Set.resource_path, Voxel_Set.duplicate())


func _on_VoxelID_text_entered(new_text : String):
	if not new_text.is_valid_integer(): return
	var value = new_text.to_int()
	
	var id := 0
	var name := ""
	var voxel = Voxel_Set.get_voxel(VoxelSetViewer.Selections[0])
	if typeof(VoxelSetViewer.Selections[0]) == TYPE_STRING:
		name = VoxelSetViewer.Selections[0]
		id = Voxel_Set.name_to_id(name)
	else: id = VoxelSetViewer.Selections[0]
	Voxel_Set.erase_voxel(id, false)
	Voxel_Set.erase_voxel(value, false)
	Voxel_Set.set_voxel(voxel, value, false)
	VoxelSetViewer.Selections[0] = value
	if name.length() > 0:
		Voxel_Set.Names[name] = value
		VoxelSetViewer.Selections[0] = name
	Voxel_Set.updated_voxels()

func _on_VoxelName_text_entered(new_text : String):
	Voxel_Set.Names.erase(VoxelSetViewer.Selections[0])
	Voxel_Set.Names[new_text] = VoxelSetViewer.Selections[0]
	VoxelSetViewer.Selections[0] = new_text
	Voxel_Set.updated_voxels()
	
#	Undo_Redo.create_action("VoxelSetEditor : Set voxel name")
#	Undo_Redo.add_do_method(Voxel_Set, "set_voxel", Voxel.colored(Color.white))
#	Undo_Redo.add_undo_method(Voxel_Set, "erase_voxel", Voxel_Set.get_id())
#	Undo_Redo.commit_action()


func _on_Add_pressed():
	Undo_Redo.create_action("VoxelSetEditor : Add voxel")
	Undo_Redo.add_do_method(Voxel_Set, "set_voxel", Voxel.colored(Color.white))
	Undo_Redo.add_undo_method(Voxel_Set, "erase_voxel", Voxel_Set.get_id())
	Undo_Redo.commit_action()

func _on_Duplicate_pressed():
	Undo_Redo.create_action("VoxelSetEditor : Duplicate voxel")
	Undo_Redo.add_do_method(Voxel_Set, "set_voxel", Voxel_Set.get_voxel(VoxelSetViewer.Selections[0]).duplicate(true))
	Undo_Redo.add_undo_method(Voxel_Set, "erase_voxel", Voxel_Set.get_id())
	Undo_Redo.commit_action()

func _on_Remove_pressed():
	Undo_Redo.create_action("VoxelSetEditor : Remove voxel")
	Undo_Redo.add_do_method(Voxel_Set, "erase_voxel", VoxelSetViewer.Selections[0])
	Undo_Redo.add_undo_method(
		Voxel_Set,
		"set_voxel",
		Voxel_Set.get_voxel(VoxelSetViewer.Selections[0]),
		VoxelSetViewer.Selections[0],
		Voxel_Set.id_to_name(VoxelSetViewer.Selections[0])
	)
	Undo_Redo.commit_action()

func _on_VoxelSetViewer_selected(voxel_id): _update()
func _on_VoxelSetViewer_unselected(index): _update()
