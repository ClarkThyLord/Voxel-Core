tool
extends VBoxContainer



# Imports
const VoxelButton := preload("res://addons/Voxel-Core/controls/VoxelButton/VoxelButton.tscn")



# Refrences
onready var SearchRef := get_node("Search")

onready var Voxels := get_node("ScrollContainer/Voxels")



# Declarations
signal selection(voxel, voxel_ref)


export(bool) var EditMode := false setget set_edit_mode
func set_edit_mode(edit_mode : bool, update := true) -> void:
	EditMode = edit_mode
	
	if update: _update()


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
func _ready(): correct()


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
			voxel_ref.connect("pressed", self, "emit_signal", ["selection", voxel, voxel_ref])
			voxel_ref.setup_voxel(voxel, Voxel_Set)
			Voxels.add_child(voxel_ref)
	call_deferred("correct")


func _on_Search_text_changed(new_text):
	_update()
