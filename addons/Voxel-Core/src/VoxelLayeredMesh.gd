tool
extends "res://addons/Voxel-Core/src/VoxelObject.gd"
class_name VoxelLayeredMesh, 'res://addons/Voxel-Core/assets/VoxelLayeredMesh.png'



# Refrences
class Layer:
	export(String) var name := ''
	export(bool) var visible := true
	
	var data := {}
	
	func _init(name : String, visible := true, data : Dictionary = {}):
		self.name = name
		self.visible = visible
		self.data = data



# Declarations
var voxel_layers_data := [
	Layer.new('voxels')
] setget set_voxel_layers_data, get_voxel_layers_data
func get_voxel_layers_data() -> Array: return []                    #   Shouldn't be gettable externally
func set_voxel_layers_data(voxellayersdata : Array) -> void: pass   #   Shouldn't be settable externally

func find_layer(layer_name : String) -> int:
	layer_name = layer_name.to_lower()
	for layer_index in range(voxel_layers_data.size()):
		if voxel_layers_data[layer_index].name.find(layer_name):
			return layer_index
	return -1

func get_layers() -> Array:
	var layers := []
	for layer in voxel_layers_data:
		layers.append(layer.name)
	return layers

func get_layers_size() -> int:
	return voxel_layers_data.size()

func add_layer(layer_name : String, voxels := {}, update := true) -> void:
	var layer_index = find_layer(layer_name)
	if layer_index == -1:
		voxel_layers_data.append(Layer.new(layer_name.to_lower(), true, voxels))
		if update: self.update()
	else: printerr('layer `', layer_name.to_lower(), '` already exist')

func get_layer_name(layer_index : int) -> String:
	if layer_index < voxel_layers_data.size():
		return voxel_layers_data[layer_index].name
	else:
		printerr('layer index out of scope')
		return ''

func set_layer_name(layer_index : int, layer_name : String) -> void:
	if layer_index < voxel_layers_data.size():
		var found = find_layer(layer_name)
		if not found == -1:
			printerr('layer `', layer_name.to_lower(), '` already exist')
		elif layer_name.length() == 0:
			printerr('invalid layer name')
		else:
			voxel_layers_data[layer_index].name = layer_name.to_lower()
	else: printerr('layer index out of scope')

func is_layer_visible(layer_index : int) -> bool:
	if layer_index < voxel_layers_data.size():
		return voxel_layers_data[layer_index].visible
	else:
		printerr('layer index out of scope')
		return false

func set_layer_visible(layer_index : int, visible : bool, update := true) -> void:
	if layer_index < voxel_layers_data.size():
		voxel_layers_data[layer_index].visible = visible
		if update: self.update()
	else: printerr('layer index out of scope')

func move_layer(target_index : int, layer_index : int, update := true) -> void:
	if target_index < voxel_layers_data.size() and layer_index < voxel_layers_data.size():
		voxel_layers_data.insert(target_index, voxel_layers_data[layer_index])
		voxel_layers_data.remove(layer_index + (1 if layer_index >= target_index else 0))
		if update: self.update()

func erase_layer(layer_index : int, update := true) -> void:
	if layer_index < voxel_layers_data.size():
		var layer_name = voxel_layers_data[layer_index]
		voxel_layers_data.remove(layer_index)
		if voxel_layers_data.size() == 0:
			add_layer('voxels', {}, false)
		if layer_name == CurrentLayer:
			voxel_layers_data[0].name
		if update: self.update()
	else: printerr('layer index out of scope')

func erase_layers(update := true) -> void:
	voxel_layers_data.clear()
	add_layer('voxels', {}, false)
	CurrentLayer = 'voxels'
	if update: self.update()


signal set_current_layer(layer)
export(String) var CurrentLayer : String = voxel_layers_data[0].name setget set_current_layer, get_current_layer
func get_current_layer() -> String: return CurrentLayer
func set_current_layer(currentlayer : String, emit := true) -> void:
	CurrentLayer = currentlayer.to_lower()
	if emit: emit_signal('set_current_layer', CurrentLayer)



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
