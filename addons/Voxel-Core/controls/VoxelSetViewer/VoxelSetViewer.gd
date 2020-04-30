tool
extends VBoxContainer



# Imports
const VoxelImport := preload("res://addons/Voxel-Core/controls/VoxelSetViewer/Voxel/Voxel.tscn")



# Refrences
onready var Voxels := get_node("ScrollContainer/Voxels")



# Declarations
signal selection(voxel, voxel_ref)


export(Resource) var Voxel_Set = preload("res://addons/Voxel-Core/defaults/VoxelSet.tres") setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if voxel_set is VoxelSet:
		Voxel_Set = voxel_set
		
		if update: self._update()
	elif typeof(voxel_set) == TYPE_NIL:
		Voxel_Set = preload("res://addons/Voxel-Core/defaults/VoxelSet.tres")



# Core
func _ready(): correct()


func correct() -> void:
	if Voxels:
		Voxels.columns = int(floor(Voxels.rect_size.x / 32))


func selected(voxel : int, voxel_ref : Button) -> void:
	emit_signal("selection", voxel, voxel_ref)


func _update() -> void:
	if Voxels:
		for child in Voxels.get_children():
			child.queue_free()
		
		for voxel in Voxel_Set.Voxels:
			var voxel_ref := VoxelImport.instance()
			voxel_ref.setup_voxel(voxel, Voxel_Set)
			voxel_ref.connect("pressed", self, "selected", [voxel, voxel_ref])
			Voxels.add_child(voxel_ref)
