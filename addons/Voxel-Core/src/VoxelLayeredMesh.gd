tool
extends "res://addons/Voxel-Core/src/VoxelObject.gd"
class_name VoxelLayeredMesh, 'res://addons/Voxel-Core/assets/VoxelLayeredMesh.png'



# Declarations
func Layer(name : String, voxels := {}, visible := true) -> Dictionary:
	return {
		'name': name.to_lower(),
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

func get_layer_name(layer_index : int) -> String:
	if has_layer(layer_index):
		return Layers[layer_index]['name']
	else:
		printerr('layer index out of scope')
		return ''

func set_layer_name(layer_index : int, layer_name : String) -> void:
	if has_layer(layer_index):
		if layer_name.length() == 0:
			printerr('invalid layer name')
		elif find_layer(layer_name) == -1:
			Layers[layer_index]['name'] = layer_name.to_lower()
		else:
			printerr('layer `', layer_name.to_lower(), '` already exist')
	else: printerr('layer index out of scope')

func get_layer_visible(layer_index : int) -> bool:
	if has_layer(layer_index):
		return Layers[layer_index]['visible']
	else:
		printerr('layer index out of scope')
		return false

func set_layer_visible(layer_index : int, visible : bool, update := true) -> void:
	if has_layer(layer_index):
		Layers[layer_index]['visible'] = visible
		if update: self.update()
	else: printerr('layer index out of scope')

func move_layer(from : int, to : int, update := true) -> void:
	if has_layer(from) and has_layer(to):
		Layers.insert(to, Layers[from])
		Layers.remove(from + (1 if from >= to else 0))
		if update: self.update()

func remove_layer(layer_index : int, update := true) -> void:
	if has_layer(layer_index):
		var layer_name = Layers[layer_index]['name']
		Layers.remove(layer_index)
		if Layers.size() == 0:
			add_layer('voxels')
		if layer_name == CurrentLayer:
			set_current_layer(Layers[0]['name'])
		if update: self.update()
	else: printerr('layer index out of scope')

func erase_layers(update := true) -> void:
	Layers.clear()
	add_layer('voxels', {}, false)
	set_current_layer('voxels')
	if update: self.update()


signal set_current_layer(layer)
var CurrentLayerIndex : int
export(String) var CurrentLayer : String = Layers[0]['name'] setget set_current_layer
func set_current_layer(currentlayer : String, emit := true) -> void:
	currentlayer = currentlayer.to_lower()
	var currentlayerindex = find_layer(currentlayer)
	if not currentlayerindex == -1:
		CurrentLayer = currentlayer
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
	set_current_layer(CurrentLayer, false)
	_load()


func get_rvoxel(grid : Vector3):
	return Layers[CurrentLayerIndex]['data'].get(grid)

func get_voxels() -> Dictionary:
	return Layers[CurrentLayerIndex]['data'].duplicate(true)


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


# Main function used when Greedy Meshing on update
# voxels        :   Dictionary       -   voxels from which to generate greedy mesh
# st            :   SurfaceTool      -   SurfaceTool to append Greedy Mesh to
# origin        :   Vector3          -   grid position from which to start Greedy Meshing
# direction     :   Vector3          -   orientation of face
# directions    :   Array<Vector3>   -   directions for Greedy Meshing
# used          :   Array<Vector3>   -   positions already used
# layer_index   :   int              -   position of layer from which to use data
#
# Example:
#   greed([SurfaceTool], [Vector3], [Vector3], Array<Vector3>, Array<Vector3>) -> Array<Vector3>
#
func greed(voxels : Dictionary, st : SurfaceTool, origin : Vector3, direction : Vector3, directions : Array, used : Array, layer_index : int = CurrentLayerIndex) -> Array:
	used.append(origin)
	
	var origin_voxel = get_voxel(origin)
	var origin_color = Voxel.get_color_side(origin_voxel, direction)
	var origin_texture = Voxel.get_texture_side(origin_voxel, direction)
	
	var g1 = origin
	var g2 = origin
	var g3 = origin
	var g4 = origin
	
	if origin_texture == null:
		var temp = []
		var offset = 1
		var length = 1
		
		while true:
			var temp_grid = g4 + (directions[0] * offset)
			var temp_voxel = get_voxel(temp_grid)
		
			if Layers[layer_index]['data'].has(temp_grid) and not Voxel.is_voxel_obstructed(temp_grid, direction, voxels, used) and Voxel.get_color_side(temp_voxel, direction) == origin_color:
				offset += 1
				temp.append(temp_grid)
			else: break
		
		used += temp
		length += temp.size()
		g1 += directions[0] * temp.size()
		g3 += directions[0] * temp.size()
		
		temp = []
		offset = 1
		
		while true:
			var temp_grid = g4 + (directions[1] * offset)
			var temp_voxel = get_voxel(temp_grid)
			
			if Layers[layer_index]['data'].has(temp_grid) and not Voxel.is_voxel_obstructed(temp_grid, direction, voxels, used) and Voxel.get_color_side(temp_voxel, direction) == origin_color:
				offset += 1
				temp.append(temp_grid)
			else: break
		
		used += temp
		length += temp.size()
		g2 += directions[1] * temp.size()
		g4 += directions[1] * temp.size()
		
		temp = []
		offset = 1
		
		while true:
			var temp_grid = g4 + (directions[2] * offset)
			
			var valid = true
			for temp_offset in range(length):
				var _temp_grid = temp_grid + directions[0] * temp_offset
				var temp_voxel = get_voxel(_temp_grid)
			
				if Layers[layer_index]['data'].has(_temp_grid) and not Voxel.is_voxel_obstructed(_temp_grid, direction, voxels, used) and Voxel.get_color_side(temp_voxel, direction) == origin_color:
					temp.append(_temp_grid)
				else:
					valid = false
					break
			
			if valid:
				used += temp
				offset += 1
			else: break
		
		g1 += directions[2] * (offset - 1)
		g2 += directions[2] * (offset - 1)
		
		temp = []
		offset = 1
		while true:
			var temp_grid = g4 + (directions[3] * offset)
			
			var valid = true
			for temp_offset in range(length):
				var _temp_grid = temp_grid + directions[0] * temp_offset
				var temp_voxel = get_voxel(_temp_grid)
			
				if Layers[layer_index]['data'].has(_temp_grid) and not Voxel.is_voxel_obstructed(_temp_grid, direction, voxels, used) and Voxel.get_color_side(temp_voxel, direction) == origin_color:
					temp.append(_temp_grid)
				else:
					valid = false
					break
			
			if valid:
				used += temp
				offset += 1
			else: break
		
		g3 += directions[3] * (offset - 1)
		g4 += directions[3] * (offset - 1)
	
	if UVMapping: Voxel.generate_side_with_uv(direction, st, get_voxel(origin), g1, g2, g3, g4, VoxelSet.UV_SCALE if VoxelSet else 1.0)
	else: Voxel.generate_side(direction, st, get_voxel(origin), g1, g2, g3, g4)
	
	return used


func update() -> void:
	var materials = {}
	for surface in range(mesh.get_surface_count() if mesh else 0):
		materials[mesh.surface_get_name(surface)] = get_surface_material(surface)
	
	var ST = SurfaceTool.new()
	ST.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var used_voxels := {}
	var layers := get_layers()
	var arraymesh := ArrayMesh.new()
	for layer_index in range(len(layers)):
		var voxels = Layers[layer_index]['data']
		if voxels.size() > 0:
			var material = SpatialMaterial.new()
			material.roughness = 1
			material.vertex_color_is_srgb = true
			material.vertex_color_use_as_albedo = true
			
			if UVMapping and VoxelSet and not VoxelSet.AlbedoTexture == null:
				material.albedo_texture = VoxelSet.AlbedoTexture
			
			ST.set_material(material)
			
			if editing or MeshType == MeshTypes.NAIVE:
				for voxel_grid in voxels:
					if UVMapping:
						if not voxels.has(voxel_grid + Vector3.RIGHT): Voxel.generate_right_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
						if not voxels.has(voxel_grid + Vector3.LEFT): Voxel.generate_left_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
						if not voxels.has(voxel_grid + Vector3.UP): Voxel.generate_up_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
						if not voxels.has(voxel_grid + Vector3.DOWN): Voxel.generate_down_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
						if not voxels.has(voxel_grid + Vector3.BACK): Voxel.generate_back_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
						if not voxels.has(voxel_grid + Vector3.FORWARD): Voxel.generate_forward_with_uv(ST, get_voxel(voxel_grid), voxel_grid, null, null, null, VoxelSet.UV_SCALE if VoxelSet else 1.0)
					else:
						if not voxels.has(voxel_grid + Vector3.RIGHT): Voxel.generate_right(ST, get_voxel(voxel_grid), voxel_grid)
						if not voxels.has(voxel_grid + Vector3.LEFT): Voxel.generate_left(ST, get_voxel(voxel_grid), voxel_grid)
						if not voxels.has(voxel_grid + Vector3.UP): Voxel.generate_up(ST, get_voxel(voxel_grid), voxel_grid)
						if not voxels.has(voxel_grid + Vector3.DOWN): Voxel.generate_down(ST, get_voxel(voxel_grid), voxel_grid)
						if not voxels.has(voxel_grid + Vector3.BACK): Voxel.generate_back(ST, get_voxel(voxel_grid), voxel_grid)
						if not voxels.has(voxel_grid + Vector3.FORWARD): Voxel.generate_forward(ST, get_voxel(voxel_grid), voxel_grid)
			elif MeshType == MeshTypes.GREEDY:
				var rights = []
				var right_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ]
				var lefts = []
				var left_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP ]
				var ups = []
				var up_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT ]
				var downs = []
				var down_directions = [ Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT ]
				var backs = []
				var back_directions = [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ]
				var forwards = []
				var forward_directions = [ Vector3.LEFT, Vector3.RIGHT, Vector3.DOWN, Vector3.UP ]
				
				for voxel_grid in voxels:
					if not Voxel.is_voxel_obstructed(voxel_grid, Vector3.RIGHT, voxels, rights): rights = greed(voxels, ST, voxel_grid, Vector3.RIGHT, right_directions, rights)
					if not Voxel.is_voxel_obstructed(voxel_grid, Vector3.LEFT, voxels, lefts): lefts = greed(voxels, ST, voxel_grid, Vector3.LEFT, left_directions, lefts)
					if not Voxel.is_voxel_obstructed(voxel_grid, Vector3.UP, voxels, ups): ups = greed(voxels, ST, voxel_grid, Vector3.UP, up_directions, ups)
					if not Voxel.is_voxel_obstructed(voxel_grid, Vector3.DOWN, voxels, downs): downs = greed(voxels, ST, voxel_grid, Vector3.DOWN, down_directions, downs)
					if not Voxel.is_voxel_obstructed(voxel_grid, Vector3.BACK, voxels, backs): backs = greed(voxels, ST, voxel_grid, Vector3.BACK, back_directions, backs)
					if not Voxel.is_voxel_obstructed(voxel_grid, Vector3.FORWARD, voxels, forwards): forwards = greed(voxels, ST, voxel_grid, Vector3.FORWARD, forward_directions, forwards)
			
			ST.index()
			ST.commit(arraymesh)
			arraymesh.surface_set_name(arraymesh.get_surface_count() - 1, layers[layer_index])
	
	if arraymesh.get_surface_count() == 0:
		mesh = null
	else:
		mesh = arraymesh
		for material_owner in materials:
			var surface_index := arraymesh.surface_find_by_name(material_owner)
			if not surface_index != -1:
				set_surface_material(surface_index, materials[material_owner])
	
	.update()
	_save()

func update_static_body() -> void:
	var staticbody
	if has_node('StaticBody'): staticbody = get_node('StaticBody')
	
	if (editing or BuildStaticBody) and mesh:
		var collisionshape
		if not staticbody:
			staticbody = StaticBody.new()
			staticbody.set_name('StaticBody')
		
		if staticbody.has_node('CollisionShape'):
			collisionshape = staticbody.get_node('CollisionShape')
		else:
			collisionshape = CollisionShape.new()
			collisionshape.set_name('CollisionShape')
			staticbody.add_child(collisionshape)
		
		collisionshape.shape = mesh.create_trimesh_shape()
		
		if not has_node('StaticBody'): add_child(staticbody)
		
		if BuildStaticBody and not staticbody.owner: staticbody.set_owner(get_tree().get_edited_scene_root())
		elif not BuildStaticBody and staticbody.owner: staticbody.set_owner(null)
		if BuildStaticBody and not collisionshape.owner: collisionshape.set_owner(get_tree().get_edited_scene_root())
		elif not BuildStaticBody and staticbody.owner: collisionshape.set_owner(null)
	elif staticbody:
		remove_child(staticbody)
		staticbody.queue_free()
