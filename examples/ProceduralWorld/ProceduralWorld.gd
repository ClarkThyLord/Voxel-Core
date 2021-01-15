extends Spatial



## Constants
const voxel_set := preload("res://examples/ProceduralWorld/TiledVoxelSet.tres")



## Exported Variables
export(int, 8, 64) var height := 16

export(float, 0.01, 10.0, 0.01) var frequency := 1.0

export(float, 0.01, 10.0, 0.01) var amplitude := 1.0

export(float, 0.01, 10.0, 0.01) var redistribution := 1.8

export(int, 0, 10) var chunk_layers := 3

export(int, 16, 128) var chunk_size := 16

export var marker_path : NodePath



## Private Variables
var _noise : OpenSimplexNoise

var _chunks := {}

var _chunk_nodes := {}



## OnReady Variables
onready var Chunks := get_node("Chunks")



## Built-In Virtual Methods
func _ready():
	_noise = OpenSimplexNoise.new()
	randomize()
	_noise.seed = randi()


func _process(delta):
	if not marker_path.is_empty():
		var marker : Spatial = get_node(marker_path)
		if is_instance_valid(marker):
			var center_chunk := _world_to_chunk(marker.translation)
			if _chunks.has(center_chunk):
				for x in range(-chunk_layers, chunk_layers + 1):
					for z in range(-chunk_layers, chunk_layers + 1):
						var chunk := center_chunk + Vector3(x, 0, z)
						if not _chunks.has(chunk):
							_add_chunk(chunk)
							return
			else:
				_add_chunk(center_chunk)



## Private Methods
func _world_to_chunk(world : Vector3) -> Vector3:
	var chunk := (world / chunk_size).round()
	chunk.y = 0
	return chunk


func _chunk_to_world(chunk : Vector3) -> Vector3:
	return chunk * chunk_size


func _generate_chunk(chunk : Vector3) -> void:
	if _chunks.has(chunk):
		return
	
	var chunk_node := VoxelMesh.new()
	chunk_node.uv_map = true
	chunk_node.voxel_set = voxel_set
	
	for x in range(chunk_size):
		for z in range(chunk_size):
			var grid_pos := _chunk_to_world(chunk) + Vector3(x, 0, z)
			var noise_1 := _noise.get_noise_3dv(grid_pos * frequency) * amplitude
			var noise_2 := 0.5 * _noise.get_noise_3dv(grid_pos * 2 * frequency) * amplitude
			var noise_4 := 0.25 * _noise.get_noise_3dv(grid_pos * 4 * frequency) * amplitude
			var noise := pow(
					range_lerp(
					noise_1 + noise_2 + noise_4,
					-1, 1, 0, 1), 1.8) * redistribution
			
			var altitude := int(range_lerp(
					noise,
					0, 1, 0, height))
			altitude = altitude if altitude > 0 else 1
			
			for y in range(altitude):
				var voxel_id := -1
				if y == altitude - 1:
					voxel_id = 1
				elif y < altitude - 3:
					voxel_id = 3
				elif y < altitude - 1:
					voxel_id = 0
				chunk_node.set_voxel(Vector3(x, y, z), voxel_id)
	chunk_node.update_mesh()
	
	chunk_node.translation = chunk * chunk_size
	chunk_node.translation -= Vector3(1, 0, 1) * (chunk_size / 2)
	chunk_node.translation *= Voxel.VoxelWorldSize
	_chunks[chunk] = chunk_node


func _add_chunk(chunk : Vector3) -> void:
	var chunk_node : Spatial = _chunks.get(chunk, null)
	if not is_instance_valid(chunk_node):
		_generate_chunk(chunk)
		_add_chunk(chunk)
		return
	if not is_instance_valid(chunk_node.get_parent()):
		Chunks.add_child(chunk_node)


func _remove_chunk(chunk : Vector3) -> void:
	var chunk_node : Spatial = _chunks.get(chunk, null)
	if is_instance_valid(chunk_node) and is_instance_valid(chunk_node.get_parent()):
		chunk_node.get_parent().remove_child(chunk_node)
