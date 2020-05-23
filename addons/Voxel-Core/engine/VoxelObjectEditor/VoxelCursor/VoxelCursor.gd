tool
extends MeshInstance



# Declarations
var vt := VoxelTool.new()


var Represents setget set_represents
func set_represents(represents, update := true) -> void:
	match typeof(represents):
		TYPE_INT, TYPE_DICTIONARY:
			Represents = represents
		_:
			printerr("invalid representation given")
			return
	
	if update: self.update()

var Selections := [] setget set_selections
func set_selections(selections : Array, update := true) -> void:
	Selections = selections
	
	if update: self.update()


export(Resource) var Voxel_Set = preload("res://addons/Voxel-Core/defaults/VoxelSet.tres") setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if voxel_set is VoxelSet:
		Voxel_Set = voxel_set
		
		if update: self.update()
	elif typeof(voxel_set) == TYPE_NIL:
		set_voxel_set(preload("res://addons/Voxel-Core/defaults/VoxelSet.tres"), update)



# Core
func update() -> void:
	pass
