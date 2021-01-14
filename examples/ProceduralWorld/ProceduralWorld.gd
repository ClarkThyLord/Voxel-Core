extends Spatial



## Constants
const voxel_set := preload("res://examples/ProceduralWorld/TiledVoxelSet.tres")



## Exported Variables
export(int, 8, 64) var height_max := 16

export(float, 0.01, 10.0, 0.01) var frequency := 1

export(float, 0.01, 10.0, 0.01) var redistribution := 1.8

export(int, 1, 36) var chunks := 8

export(int, 16, 128) var chunk_size := 32

export var marker_path : NodePath



## Private Variables
var _noise : OpenSimplexNoise

var _chunks := {}



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
			var chunk_key := _world_to_chunk(marker.translation)
			if not _chunks.has(chunk_key):
				var chunk := VoxelMesh.new()
				chunk.uv_map = true
				chunk.voxel_set = voxel_set
				
				for x in range(chunk_size):
					for z in range(chunk_size):
						var grid_pos := _chunk_to_world(chunk_key) + Vector3(x, 0, z)
						var noise_1 := _noise.get_noise_3dv(grid_pos) * frequency
						var noise_2 := 0.5 * _noise.get_noise_3dv(grid_pos * 2) * frequency
						var noise_4 := 0.25 * _noise.get_noise_3dv(grid_pos * 4) * frequency
						var noise := pow(
								range_lerp(
								noise_1 + noise_2 + noise_4,
								-1, 1, 0, 1), 1.8) * redistribution
						
						var height := int(range_lerp(
								noise,
								0, 1, 0, height_max - 1)) + 1
						
						for y in range(height):
							chunk.set_voxel(Vector3(x, y, z), 0)
				chunk.update_mesh()
				
				chunk.translation = chunk_key * chunk_size
				chunk.translation -= Vector3(1, 0, 1) * (chunk_size / 2)
				chunk.translation *= Voxel.VoxelWorldSize
				Chunks.add_child(chunk)
				_chunks[chunk_key] = chunk



## Private Methods
func _world_to_chunk(world : Vector3) -> Vector3:
	var chunk := (world / chunk_size).round()
	chunk.y = 0
	return chunk

func _chunk_to_world(chunk : Vector3) -> Vector3:
	return chunk * chunk_size
