tool
extends "res://addons/Voxel-Core/src/VoxelObject.gd"
class_name VoxelLayeredMesh, 'res://addons/Voxel-Core/assets/VoxelLayeredMesh.png'



# Declarations
func Layer(name : String, voxels := {}, visible := true) -> Dictionary:
	return {
		'name': name,
		'data': voxels,
		'visible': visible
	}

var Layers := [
	Layer('voxels')
] setget set_layers, get_layers
func get_layers() -> Array:
	var layers := []
	for layer in Layers:
		layers.append(layer['name'])
	return layers

func get_layers_count() -> int:
	return Layers.size()

func set_layers(layers : Array) -> void: pass   #   Shouldn't be settable externally

func has_layer(layer_index : int) -> bool:
	return layer_index < get_layers_count()

func find_layer(layer_name : String) -> int:
	layer_name = layer_name.to_lower()
	for layer_index in range(get_layers_count()):
		if Layers[layer_index]['name'].find(layer_name):
			return layer_index
	return -1

func add_layer(layer_name : String, voxels := {}, visible := true, position := get_layers_count(), update := true) -> void:
	var layer_index = find_layer(layer_name)
	if layer_index == -1:
		Layers.append(Layer(layer_name, voxels))
		if not position == get_layers_count() - 1: move_layer(get_layers_count(), position, false)
		if update: self.update()
	else: printerr('layer `', layer_name.to_lower(), '` already exist')

func get_layer(layer_index : int) -> Dictionary:
	if has_layer(layer_index):
		return Layers[layer_index].duplicate(true)
	else:
		printerr('layer index out of scope')	
		return {}

func get_layer_name(layer_index : int) -> String:
	if has_layer(layer_index):
		return Layers[layer_index]['name']
	else:
		printerr('layer index out of scope')
		return ''

func set_layer_name(layer_index : int, layer_name : String) -> void:
	if has_layer(layer_index):
		var found = find_layer(layer_name)
		if not found == -1:
			printerr('layer `', layer_name.to_lower(), '` already exist')
		elif layer_name.length() == 0:
			printerr('invalid layer name')
		else:
			Layers[layer_index]['name'] = layer_name.to_lower()
	else: printerr('layer index out of scope')

func get_layer_visible(layer_index : int) -> bool:
	if has_layer(layer_index):
		return Layers[layer_index].visible
	else:
		printerr('layer index out of scope')
		return false

func set_layer_visible(layer_index : int, visible : bool, update := true) -> void:
	if has_layer(layer_index):
		Layers[layer_index].visible = visible
		if update: self.update()
	else: printerr('layer index out of scope')

func move_layer(from : int, to : int, update := true) -> void:
	if has_layer(to) and has_layer(to):
		Layers.insert(to, Layers[from])
		Layers.remove(from + (1 if from >= to else 0))
		if update: self.update()

func erase_layer(layer_index : int, update := true) -> void:
	if has_layer(layer_index):
		var layer_name = Layers[layer_index]
		Layers.remove(layer_index)
		if Layers.size() == 0:
			add_layer('voxels', {}, false)
		if layer_name == CurrentLayer:
			Layers[0]['name']
		if update: self.update()
	else: printerr('layer index out of scope')

func erase_layers(update := true) -> void:
	Layers.clear()
	add_layer('voxels', {}, false)
	CurrentLayer = 'voxels'
	if update: self.update()


signal set_current_layer(layer)
var CurrentLayerIndex : int
export(String) var CurrentLayer : String = Layers[0]['name'] setget set_current_layer, get_current_layer
func get_current_layer() -> String: return CurrentLayer
func set_current_layer(currentlayer : String, emit := true) -> void:
	var currentlayerindex = find_layer(currentlayer)
	if not currentlayerindex == -1:
		CurrentLayer = currentlayer.to_lower()
		CurrentLayerIndex = currentlayerindex
		if emit: emit_signal('set_current_layer', CurrentLayer)
	else: printerr('invalid layer `', currentlayer,'`')



# Core
func _load() -> void:
	._load()
	
	if has_meta('Layers'): Layers = get_meta('Layers')

func _save() -> void:
	._save()
	
	set_meta('Layers', Layers)


func _init() -> void:
	_load()
func _ready() -> void:
	set_voxel_set_path(VoxelSetPath, false, false)
	_load()


func get_rvoxel(grid : Vector3):
	return Layers[CurrentLayerIndex]['data'].get(grid)

func get_voxels() -> Dictionary:
	var voxels := {}
	for layer in get_layers().invert():
		for voxel_grid in layer.data:
			voxels[voxel_grid] = layer.data[voxel_grid]
	return voxels


func set_voxel(grid : Vector3, voxel, update := false) -> void:
	Layers[CurrentLayerIndex]['data'][grid] = voxel
	.set_voxel(grid, voxel, update)

func set_voxels(voxels : Dictionary, update := true) -> void:
	Layers[CurrentLayerIndex]['data'] = voxels
	if update: self.update()


func erase_voxel(grid : Vector3, update := false) -> void:
	Layers[CurrentLayerIndex]['data'].erase(grid)
	.erase_voxel(grid)

func erase_voxels(update : bool = true) -> void:
	Layers[CurrentLayerIndex]['data'].clear()
	if update: self.update()
