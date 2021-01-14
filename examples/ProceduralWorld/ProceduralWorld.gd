extends Spatial



## Constants
const voxel_set := preload("res://examples/ProceduralWorld/TiledVoxelSet.tres")



## Exported Variables
export(int, 16, 128) var chunk_size := 32

export var marker_path : NodePath



## Private Variables
var _chunks := {}



## OnReady Variables
onready var chunks := get_node("Chunks")



## Built-In Virtual Methods
func _process(delta):
	if not marker_path.is_empty():
		var marker : Spatial = get_node(marker_path)
		if is_instance_valid(marker):
			var chunk_key := _world_to_chunk(marker.translation)
			if not _chunks.has(chunk_key):
				var chunk := VoxelMesh.new()
				chunk.voxel_set = voxel_set
				
				for x in range(chunk_size):
					for z in range(chunk_size):
						chunk.set_voxel(Vector3(x, randi() % 3, z), 0)
				chunk.update_mesh()
				
				chunk.translation = chunk_key * chunk_size
				chunk.translation -= Vector3(1, 0, 1) * (chunk_size / 2)
				chunk.translation *= Voxel.VoxelWorldSize
				chunks.add_child(chunk)
				_chunks[chunk_key] = chunk
#			print(marker.translation, _world_to_chunk(marker.translation))



## Private Methods
func _world_to_chunk(world : Vector3) -> Vector3:
	var chunk := (world / chunk_size).round()
	chunk.y = 0
	return chunk
