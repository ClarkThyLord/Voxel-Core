tool
extends "res://addons/Voxel-Core/src/VoxelObject.gd"
class_name VoxelMultiMesh, 'res://addons/Voxel-Core/assets/VoxelMultiMesh.png'



# Declarations
signal set_chunk_size(chunksize)
export(int, 16, 32, 2) var ChunkSize setget set_chunk_size
func set_chunk_size(chunksize : int, emit := true) -> void:
	ChunkSize = clamp(chunksize - (chunksize % 2), 16, 32)
	if emit: emit_signal('set_chunk_size', chunksize)


func set_editing(_editing := !editing, update := true) -> void:
	for chunk in chunks.values():
		chunk.set_editing(editing, false)
	
	.set_editing(_editing, update)

func set_uv_mapping(uvmapping : bool, update := true, emit := true) -> void:
	for chunk in chunks.values():
		chunk.set_uv_mapping(uvmapping, false, false)
	
	.set_uv_mapping(uvmapping, update, emit)

func set_build_static_body(buildstaticbody : bool, update := true, emit := true) -> void:
	for chunk in chunks.values():
		chunk.set_build_static_body(buildstaticbody, false, false)
	
	.set_build_static_body(buildstaticbody, update, emit)

func set_mesh_type(meshtype : int, update := true, emit := true) -> void:
	for chunk in chunks.values():
		chunk.set_mesh_type(meshtype, false, false)
	
	.set_mesh_type(meshtype, update, emit)

func set_voxel_set(voxelset : VoxelSetClass, update := true, emit := true) -> void:
	if voxelset == VoxelSet: return
	elif typeof(voxelset) == TYPE_NIL:
		if has_node('/root/VoxelSet'): voxelset = get_node('/root/CoreVoxelSet')
		else: return
	
	if VoxelSet and VoxelSet.is_connected('updated', self, 'update'):
		VoxelSet.disconnect('updated', self, 'update')
	
	VoxelSet = voxelset
	for chunk in chunks.values():
		chunk.set_voxel_set(voxelset, false, false)
	
	if not VoxelSet.is_connected('updated', self, 'update'):
		VoxelSet.connect('updated', self, 'update')
	
	if update and is_inside_tree(): self.update()
	if emit: emit_signal('set_voxel_set', VoxelSet)


var mutex := Mutex.new() setget set_mutex, get_mutex
func get_mutex() -> Mutex: return null        #   shouldn't be gettable externally
func set_mutex(mutex : Mutex) -> void: pass   #   shouldn't be settable externally

var exit_thread := false
var thread := Thread.new() setget set_thread, get_thread
func get_thread() -> Thread: return null         #   shouldn't be gettable externally
func set_thread(thread : Thread) -> void: pass   #   shouldn't be settable externally


var chunks := {} setget set_chunks, get_chunks
func get_chunks() -> Dictionary: return {}           #   shouldn't be gettable externally
func set_chunks(chunks : Dictionary) -> void: pass   #   shouldn't be settable externally

var chunks_data := {} setget set_chunks_data, get_chunks_data
func get_chunks_data() -> Dictionary: return {}           #   shouldn't be gettable externally
func set_chunks_data(chunks : Dictionary) -> void: pass   #   shouldn't be settable externally

var queue_chunks := [] setget set_queue_chunks, get_queue_chunks
func get_queue_chunks() -> Array: return []                 #   shouldn't be gettable externally
func set_queue_chunks(queue_chunks : Array) -> void: pass   #   shouldn't be settable externally
func queue_chunk(chunk : Vector3) -> void:
	mutex.lock()
	if not queue_chunks.has(chunk):
		queue_chunks.append(chunk)
	mutex.unlock()

var update_chunks := [] setget set_update_chunks, get_update_chunks
func get_update_chunks() -> Array: return []                 #   shouldn't be gettable externally
func set_update_chunks(update_chunks : Array) -> void: pass   #   shouldn't be settable externally
func update_chunk(chunk : Vector3) -> void:
	mutex.lock()
	if not update_chunks.has(chunk):
		update_chunks.append(chunk)
	mutex.unlock()



# Core
func _load() -> void:
	mutex.lock()
	._load()
	
	if has_meta('chunks_data'): chunks_data = get_meta('chunks_data')
	mutex.unlock()

func _save() -> void:
	._save()
	
	set_meta('chunks_data', chunks_data)


func _init() -> void: _load()
func _ready() -> void:
	set_voxel_set_path(VoxelSetPath, false, false)
	_load()
	
	
	exit_thread = false
	thread.start(self, 'update_thread')

func _exit_tree():
	if mutex and thread:
		mutex.lock()
		exit_thread = true
		mutex.unlock()
		thread.wait_to_finish()


func grid_to_chunk(grid : Vector3) -> Vector3:
	return Vector3(floor(grid.x / 16), floor(grid.y / 16), floor(grid.z / 16))


func get_rvoxel(grid : Vector3):
	var voxel = null
	var chunk = chunks_data.get(grid_to_chunk(grid))
	if typeof(chunk) == TYPE_DICTIONARY:
		voxel = chunk.get(grid)
	return voxel

func get_voxels() -> Dictionary:
	var voxels := {}
	for chunk in chunks_data.values():
		for voxel in chunk:
			voxels[voxel] = chunk[voxel]
	return voxels


func set_voxel(grid : Vector3, voxel, update := false) -> void:
	var chunk := grid_to_chunk(grid)
	if not chunks_data.has(chunk):
		chunks_data[chunk] = {}
	chunks_data[chunk][grid] = voxel
	
	queue_chunk(chunk)
	.set_voxel(grid, voxel, update)

func set_voxels(voxels : Dictionary, update := true) -> void:
	for voxel in voxels:
		var chunk = grid_to_chunk(voxel)
		if not chunks_data.has(chunk):
			chunks_data[chunk] = {}
		chunks_data[chunk][voxel] = voxels[voxel]
	queue_chunks = chunks_data.keys()
	
	if update: update()


func erase_voxel(grid : Vector3, update := false) -> void:
	var chunk := grid_to_chunk(grid)
	if chunks_data.has(chunk):
		chunks_data[chunk].erase(grid)
	
	queue_chunk(chunk)
	.erase_voxel(grid, update)

func erase_voxels(update : bool = true) -> void:
	queue_chunks = chunks_data.keys()
	chunks_data.clear()
	
	if update: update()


func update() -> void:
	mutex.lock()
	if queue_chunks.size() > 0:
		for queue_chunk in queue_chunks:
			if not update_chunks.has(queue_chunk):
				update_chunks.append(queue_chunk)
		queue_chunks.clear()
	else: update_chunks = chunks_data.keys()
	mutex.unlock()
	
	_save()
func update_static_body() -> void: pass


func update_thread(userdata) -> void:
	while true:
		mutex.lock()
		var should_exit = exit_thread
		mutex.unlock()
		if should_exit: break
		
		mutex.lock()
		if update_chunks.size() > 0:
			var chunk_position = update_chunks.pop_front()
			
			var chunk = chunks.get(chunk_position)
			var chunk_data = chunks_data.get(chunk_position)
			if chunk_data:
				if not (chunk and is_instance_valid(chunk)):
					chunk = load('res://addons/Voxel-Core/src/VoxelChunk.gd').new()
					call_deferred('add_child', chunk)
					chunks[chunk_position] = chunk
				
				chunk.set_editing(editing, false)
				chunk.set_uv_mapping(UVMapping, false, false)
				chunk.set_build_static_body(BuildStaticBody, false, false)
				chunk.set_mesh_type(MeshType, false, false)
				chunk.set_voxel_set(VoxelSet, false, false)
				chunk.set_voxels(chunk_data, false)
				chunk.call_deferred('update')
			elif not chunk_data:
				queue_chunks.erase(chunk_position)
				chunks.erase(chunk_position)
				if chunk and chunk is MeshInstance:
					chunk.call_deferred('queue_free')
		mutex.unlock()
