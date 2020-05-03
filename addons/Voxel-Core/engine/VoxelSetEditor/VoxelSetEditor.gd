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
func _ready(): _update()


func _update() -> void:
	if VoxelSetInfo:
		VoxelSetInfo.text = "Voxels: " + str(Voxel_Set.Voxels.size())
		VoxelSetInfo.text += "\nTiled: " + str(is_instance_valid(Voxel_Set.Tiles))
		VoxelSetInfo.text += "\nTile Size: " + str(Vector2.ONE * Voxel_Set.TileSize)
	
	if VoxelSetViewer:
		if VoxelSetViewer.Selections.size() == 1:
			var id = str(VoxelSetViewer.Selections[0])
			if Duplicate: Duplicate.visible = true
			if Remove: Remove.visible = true
			
			if typeof(id) == TYPE_STRING:
				VoxelName.text = id
				id = Voxel_Set.name_to_id(id)
			VoxelID.text = str(id)
			VoxelData.text = var2str(Voxel_Set.get_voxel(id))
			
			if VoxelInspector:
				VoxelInspector.visible = true
				VoxelViewer.setup_voxel(id, Voxel_Set)
		else:
			if Duplicate: Duplicate.visible = false
			if Remove: Remove.visible = false
			
			if VoxelInspector:
				VoxelInspector.visible = false


func _on_Save_pressed():
	ResourceSaver.save(Voxel_Set.resource_path, Voxel_Set.duplicate())


func _on_Add_pressed():
	if is_instance_valid(Voxel_Set):
		Voxel_Set.set_voxel(Voxel.colored(Color.white))

func _on_Duplicate_pressed():
	if is_instance_valid(Voxel_Set):
		Voxel_Set.set_voxel(Voxel_Set.get_voxel(VoxelSetViewer.Selections[0]).duplicate(true))

func _on_Remove_pressed():
	if is_instance_valid(Voxel_Set):
		Voxel_Set.erase_voxel(VoxelSetViewer.Selections[0])

func _on_VoxelSetViewer_selected(index): _update()
func _on_VoxelSetViewer_unselected(index): _update()
