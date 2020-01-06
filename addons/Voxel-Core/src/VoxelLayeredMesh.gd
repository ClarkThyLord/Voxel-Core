tool
extends "res://addons/Voxel-Core/src/VoxelObject.gd"
class_name VoxelLayeredMesh, 'res://addons/Voxel-Core/assets/VoxelLayeredMesh.png'



# Declarations
signal set_current_layer(layer)
export(String) var CurrentLayer := '' setget set_current_layer, get_current_layer
func get_current_layer() -> String: return CurrentLayer
func set_current_layer(currentlayer : String, emit := true) -> void:
	CurrentLayer = currentlayer
	if emit: emit_signal('set_current_layer', CurrentLayer)

var voxel_layers := {} setget set_voxel_layers, get_voxel_layers
func get_voxel_layers() -> Dictionary: return {}                #   Shouldn't be gettable externally
func set_voxel_layers(voxellayers : Dictionary) -> void: pass   #   Shouldn't be settable externally
var voxel_layers_data := {} setget set_voxel_layers_data, get_voxel_layers_data
func get_voxel_layers_data() -> Dictionary: return {}                      #   Shouldn't be gettable externally
func set_voxel_layers_data(voxel_layers_data : Dictionary) -> void: pass   #   Shouldn't be settable externally

func has_layer(layer : String) -> bool:
	return voxel_layers_data.has(layer)

func get_layers() -> Array:
	return voxel_layers_data.keys()

func set_layer(layer : String, voxels := {}) -> void:
	voxel_layers_data[layer] = voxels.duplicate(true)

func erase_layer(layer : String) -> void:
	voxel_layers_data.erase(layer)

func erase_layers() -> void:
	for voxel_layer in voxel_layers_data.keys():
		voxel_layers_data.erase(voxel_layer)



# Core
func _load() -> void:
	._load()
	
	if has_meta('voxel_layers_data'): voxel_layers_data = get_meta('voxel_layers_data')

func _save() -> void:
	._save()
	
	set_meta('voxel_layers_data', voxel_layers_data)


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
