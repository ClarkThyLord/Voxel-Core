tool
extends "res://addons/Voxel-Core/src/VoxelObject.gd"
class_name VoxelLayeredMesh, 'res://addons/Voxel-Core/assets/VoxelLayeredMesh.png'



# Declarations
signal set_current_layer(layer)
export(String) var CurrentLayer := '' setget set_current_layer
func set_current_layer(currentlayer : String, emit := true) -> void:
	CurrentLayer = currentlayer
	if emit: emit_signal('set_current_layer', CurrentLayer)

var voxel_layers := {} setget set_voxel_layers
func set_voxel_layers(voxel_layers : Dictionary) -> void: pass   #   Shouldn't be settable externally

func get_layer(layer : String) -> void:
	pass

func set_layer(layer : String, material : Material) -> void:
	pass

func erase_layer(layer : String) -> void:
	pass



# Core
func _load() -> void:
	._load()
	
	if has_meta('voxel_layers'): voxel_layers = get_meta('voxel_layers')

func _save() -> void:
	._save()
	
	set_meta('voxel_layers', voxel_layers)


func _init() -> void:
	_load()
func _ready() -> void:
	set_voxel_set_path(VoxelSetPath, false, false)
	_load()


func get_rvoxel(grid : Vector3):
	pass

func get_voxels() -> Dictionary:
	return {}


func set_voxel(grid : Vector3, voxel, update := false) -> void:
	pass

func set_voxels(_voxels : Dictionary, update := true) -> void:
	pass


func erase_voxel(grid : Vector3, update := false) -> void:
	pass

func erase_voxels(update : bool = true) -> void:
	pass
