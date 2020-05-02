tool
extends ScrollContainer



# Refrences
onready var VoxelSetInfo := get_node("HBoxContainer/VBoxContainer/VoxelSetInfo")
onready var VoxelInfo := get_node("HBoxContainer/VBoxContainer/VoxelInfo")

onready var Duplicate := get_node("HBoxContainer/VBoxContainer2/ToolBar/Duplicate")
onready var Remove := get_node("HBoxContainer/VBoxContainer2/ToolBar/Remove")

onready var VoxelSetViewer := get_node("HBoxContainer/VBoxContainer2/VoxelSetViewer")

onready var VoxelInspector := get_node("HBoxContainer/VoxelInspector")
onready var VoxelView := get_node("HBoxContainer/VoxelInspector/VoxelViewer")



# Declarations
var SelectedVoxel := -1 setget set_selected_voxel
func set_selected_voxel(selected_voxel : int) -> void:
	SelectedVoxel = selected_voxel
	
	if VoxelInfo:
		VoxelInfo.visible = SelectedVoxel > -1
		VoxelInfo.text = "ID: " + str(SelectedVoxel)
		if Voxel_Set:
			VoxelInfo.text += "\nRaw Data:\n"+ var2str(Voxel_Set.get_voxel(SelectedVoxel))
	if Duplicate: Duplicate.visible = SelectedVoxel > -1
	if Remove: Remove.visible = SelectedVoxel > -1
	if VoxelInspector: VoxelInspector.visible = SelectedVoxel > -1
	if VoxelView and SelectedVoxel > -1 and is_instance_valid(Voxel_Set):
		VoxelView.setup_voxel(SelectedVoxel, Voxel_Set)

var Voxel_Set : VoxelSet



# Core
func edit_voxel_set(voxelset : VoxelSet) -> void:
	Voxel_Set = voxelset
	set_selected_voxel(-1)
	
	if VoxelSetInfo:
		VoxelSetInfo.text = "Voxels: " + str(voxelset.Voxels.size())
		VoxelSetInfo.text += "\nTiled: " + str(is_instance_valid(voxelset.Tiles))
		VoxelSetInfo.text += "\nTile Size: " + str(Vector2.ONE * voxelset.TileSize)
	if VoxelSetViewer:
		VoxelSetViewer.Voxel_Set = voxelset


func _on_Save_pressed():
	ResourceSaver.save(Voxel_Set.resource_path, Voxel_Set.duplicate())


func _on_VoxelSetViewer_selected(index):
	set_selected_voxel(VoxelSetViewer.Selections[index])


func _on_Add_pressed():
	if is_instance_valid(Voxel_Set):
		Voxel_Set.set_voxel(Voxel.colored(Color.white))

func _on_Duplicate_pressed():
	if is_instance_valid(Voxel_Set):
		Voxel_Set.set_voxel(Voxel_Set.get_voxel(SelectedVoxel))

func _on_Remove_pressed():
	if is_instance_valid(Voxel_Set):
		Voxel_Set.erase_voxel(SelectedVoxel)
