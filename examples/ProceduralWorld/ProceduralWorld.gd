extends Spatial



## Enums
enum Biomes { PLAIN, DRY, TUNDRA }



## Constants
const voxel_size := 0.5

const voxel_set := preload("res://examples/ProceduralWorld/TiledVoxelSet.tres")



## Exported Variables
export(int, 8, 64) var height := 16

export(float, 0.01, 10.0, 0.01) var frequency := 1.0

export(float, 0.01, 10.0, 0.01) var amplitude := 1.0

export(float, 0.01, 10.0, 0.01) var redistribution := 1.8

export(float, 0.0, 1.0, 0.01) var structure_rate := 0.8

export(float, 0.0, 100.0, 1.0) var biome_factor := 10.0

export(int, 0, 10) var chunk_layers := 3

export(int, 16, 128) var chunk_size := 16

export var marker_path : NodePath



## Private Variables
var _noise : OpenSimplexNoise

var _chunks := {}

var _chunk_nodes := {}

var _structures := [
		[
			0.5,
			preload("res://examples/ProceduralWorld/structures/tree.oak.tscn").instance(),
		],
		[
			0.5,
			preload("res://examples/ProceduralWorld/structures/tree.birch.tscn").instance(),
		],
		[
			0.3,
			preload("res://examples/ProceduralWorld/structures/rock.tscn").instance(),
		],
		[
			0.15,
			preload("res://examples/ProceduralWorld/structures/house.tscn").instance(),
		],
		[
			0.05,
			preload("res://examples/ProceduralWorld/structures/tower.tscn").instance(),
		],
]

var _biome_structures := [
	[0, 1, 2, 4],
	[2, 3, 4],
	[0, 4],
]



## OnReady Variables
onready var Chunks := get_node("Chunks")



## Built-In Virtual Methods
func _ready():
	_noise = OpenSimplexNoise.new()
	randomize()
	_noise.seed = randi()

func _exit_tree():
	for structure in _structures:
		structure[1].free()


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
	
	var spawn_points := []
	
	for x in range(chunk_size):
		for z in range(chunk_size):
			var world_grid := _chunk_to_world(chunk) + Vector3(x, 0, z)
			
			var biome := range_lerp(
				_noise.get_noise_2d(
					floor(world_grid.x / chunk_size),
					floor(world_grid.z / chunk_size)) * biome_factor,
					-1, 1, 0, Biomes.size())
			
			var biome_key := -1
			var biome_frequency := frequency
			var biome_amplitude := amplitude
			var biome_redistribution := redistribution
			var biome_structure_rate := structure_rate
			
			if biome > 2:
				biome_key = Biomes.TUNDRA
				biome_structure_rate *= 0.05
			elif biome > 1:
				biome_key = Biomes.PLAIN
				biome_amplitude *= 0.4
			else:
				biome_key = Biomes.DRY
				biome_frequency *= 0.2
				biome_structure_rate *= 0.01
			
			var noise_1 := _noise.get_noise_3dv(
					world_grid * biome_frequency) * biome_amplitude
			var noise_2 := 0.5 * _noise.get_noise_3dv(
					world_grid * 2 * biome_frequency) * biome_amplitude
			var noise_4 := 0.25 * _noise.get_noise_3dv(
					world_grid * 4 * biome_frequency) * biome_amplitude
			var noise := pow(
					range_lerp(noise_1 + noise_2 + noise_4, -1, 1, 0, 1),
					biome_redistribution)
			
			var altitude := int(range_lerp(
					noise,
					0, 1, 0, height))
			altitude = altitude if altitude > 0 else 1
			
			var local_grid := Vector3(x, 0, z)
			for y in range(altitude):
				local_grid.y = y
				var voxel_id := -1
				if y > 19:
					if y == altitude - 1:
						voxel_id = 7 if y > 24 else 4
					else:
						voxel_id = 3
				else:
					if y == altitude - 1:
						match biome_key:
							Biomes.PLAIN:
								voxel_id = 1
							Biomes.TUNDRA:
								voxel_id = 7
							Biomes.DRY:
								voxel_id = 0
							
					elif y < altitude - 3:
						voxel_id = 3
					elif y < altitude - 1:
						voxel_id = 0
				chunk_node.set_voxel(local_grid, voxel_id)
				
				if not (local_grid.y < 19 and local_grid.y == altitude - 1):
					continue
				var spawn_point := range_lerp(
						_noise.get_noise_3dv(
								(Vector3(
										floor(world_grid.x / 5),
										0,
										floor(world_grid.z / 5))
								* biome_frequency)) *  biome_amplitude,
						-1, 1, 0, 1)
				if not spawn_points.has(spawn_point) and randf() < biome_structure_rate:
					spawn_points.append(spawn_point)
					var structure_id : int = _biome_structures[biome_key][randi() % _biome_structures[biome_key].size()]
					var structure_chance : float = _structures[structure_id][0]
					if randf() < structure_chance:
						var structure : VoxelMesh = _structures[structure_id][1]
						for structure_grid in structure.get_voxels():
							chunk_node.set_voxel(
									local_grid + Vector3.UP + structure_grid,
									structure.get_voxel_id(structure_grid))
	chunk_node.update_mesh()
	
	chunk_node.translation = chunk * chunk_size
	chunk_node.translation -= Vector3(1, 0, 1) * (chunk_size / 2)
	chunk_node.translation *= voxel_size
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
