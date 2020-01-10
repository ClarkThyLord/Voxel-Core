tool
extends "res://addons/Voxel-Core/src/VoxelObject.gd"
class_name VoxelLayeredMesh, 'res://addons/Voxel-Core/assets/VoxelLayeredMesh.png'



# Refrences
class Layer:
	export(String) var name := ''
	export(bool) var visible := true
	
	func _init(name : String, visible := true):
		self.name = name
		self.visible = visible



# Declarations
signal set_current_layer(layer)
export(String) var CurrentLayer := 'voxels' setget set_current_layer, get_current_layer
func get_current_layer() -> String: return CurrentLayer
func set_current_layer(currentlayer : String, emit := true) -> void:
	CurrentLayer = currentlayer
	if emit: emit_signal('set_current_layer', CurrentLayer)

#var voxel_layers := {} setget set_voxel_layers, get_voxel_layers
#func get_voxel_layers() -> Dictionary: return {}                #   Shouldn't be gettable externally
#func set_voxel_layers(voxellayers : Dictionary) -> void: pass   #   Shouldn't be settable externally
var voxel_layers_data := [] setget set_voxel_layers_data, get_voxel_layers_data
func get_voxel_layers_data() -> Array: return []                    #   Shouldn't be gettable externally
func set_voxel_layers_data(voxellayersdata : Array) -> void: pass   #   Shouldn't be settable externally

func find_layer(layer_name : String) -> int:
	layer_name = layer_name.to_lower()
	for layer_index in range(voxel_layers_data.size()):
		if voxel_layers_data[layer_index].name.find(layer_name):
			return layer_index
	return -1

func get_layer_name(layer : int) -> String:
	if layer < voxel_layers_data.size():
		return voxel_layers_data[layer].name
	return ''

func is_layer_visible(layer) -> bool:
	if typeof(layer) == TYPE_INT:
		if layer < voxel_layers_data.size():
			return voxel_layers_data[layer].visible
	elif typeof(layer) == TYPE_STRING:
		layer = find_layer(layer)
		if layer != -1:
			return voxel_layers_data[layer].visible
	return false

func get_layers() -> Array:
	var layers := []
	for layer in voxel_layers_data:
		layers.append(layer.name)
	return layers

func set_layer(layer_name : String, voxels := {}, update := true) -> void:
	var layer_index = find_layer(layer_name)
	if layer_index == -1:
		pass
	else:
		pass
	if update: self.update()

func erase_layer(layer_name : String, update := true) -> void:
	voxel_layers_data.erase(layer_name)
	if update: self.update()

func erase_layers(update := true) -> void:
	voxel_layers_data.clear()
	if update: self.update()



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
