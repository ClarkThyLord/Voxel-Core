tool
extends "res://addons/VoxelCore/src/VoxelObject.gd"
class_name VoxelMultiMesh, 'res://addons/VoxelCore/assets/VoxelMultiMesh.png'



# Declarations
var thread : Thread = Thread.new()


signal set_processing(processing)
var Processing : bool = false setget set_processing
func set_processing(processing : bool = !Processing, emit : bool = true) -> void:
	if emit and Processing != processing: emit_signal('set_processing', Processing)
	
	Processing = processing


var queue_chunks : Array = [] setget set_queue_chunks
func set_queue_chunks(queuechunks : Array) -> void: return

var update_chunks : Array = [] setget set_update_chunks
func set_update_chunks(updatechunks : Array) -> void: return


var chunks : Dictionary = {} setget set_chunks
func set_chunks(_chunks : Dictionary, emit : bool = true) -> void:
	erase_voxels(false, emit)
	
	for chunk in _chunks:
		if typeof(chunk) == TYPE_VECTOR3 and _chunks[chunk] is VoxelMesh:
			chunks[chunk] = _chunks[chunk]
#			add_child((_chunks[chunk] as VoxelMesh))
	queue_chunks = chunks.keys()

signal set_chunk_size(chunksize)
export(int, 2, 16, 2) var ChunkSize : int = 10 setget set_chunk_size
func set_chunk_size(chunksize : int, update : bool = true, emit : bool = true) -> void:
	ChunkSize = chunksize
	
	remake_chunks(false, emit)
	
	if update: update(emit)
	if emit: emit_signal('set_chunk_size', ChunkSize)


# Setter for Greedy, emits 'set_greedy'
# greedy   :   bool   -   value to set
# update   :   bool   -   call on update
# emit     :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_greedy(true, false)
#
func set_greedy(greedy : bool = !Greedy, update : bool = true, emit : bool = true) -> void:
	Greedy = greedy
	
	for chunk in chunks: (chunks[chunk] as VoxelMesh).set_greedy(greedy, false, false)
	
	queue_chunks = chunks.keys()
	
	if update and is_inside_tree(): update(false, emit)
	if emit: emit_signal('set_greedy', Greedy)

# Setter for voxelset, emits 'set_voxelset'
# _voxelset   :   bool   -   value to set
# update      :   bool   -   call on update
# emit        :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxelset(true, false)
#
func set_voxelset(_voxelset = voxelset, update : bool = true, emit : bool = true) -> void:
	if voxelset == _voxelset: return;
	elif voxelset is VoxelSet: voxelset.disconnect('update', self, 'update')
	
	voxelset = _voxelset
	for chunk in chunks: (chunks[chunk] as VoxelMesh).set_voxelset(_voxelset, false, false)
	if not voxelset.is_connected('update', self, 'update'): voxelset.connect('update', self, 'update')
	
	queue_chunks = chunks.keys()
	
	if update and is_inside_tree(): update(false, emit)
	if emit: emit_signal('set_voxelset', voxelset)



# Core
func _load() -> void:
	._load()
	
	if has_meta('chunks'): set_chunks(get_meta('chunks'))
func _save() -> void:
	._save()
	
	set_meta('chunks', chunks)


func _init() -> void: ._init()

func _exit_tree(): if thread.is_active(): thread.wait_to_finish()


func _process(delta):
	if not thread.is_active() and update_chunks.size() > 0:
		set_processing(true)
		thread.start(self, 'update_chunk', [thread, update_chunks[0]])


# Set Voxel as given to grid position, emits 'set_voxel'
# grid     :   Vector3          -   grid position to set Voxel to 
# voxel    :   int/Dictionary   -   Voxel to be set
# update   :   bool             -   call on update
# emit     :   bool             -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel(Vector(11, -34, 2), 3)         #   NOTE: This would store the Voxels ID
#   set_voxel(Vector(11, -34, 2), { ... })
#
func set_voxel(grid : Vector3, voxel, update : bool = false, emit : bool = true) -> void:
	var chunk_grid = grid_to_chunk(grid)
	
	if not chunks.has(chunk_grid): create_chunk(chunk_grid)
	
	(chunks[chunk_grid] as VoxelMesh).set_voxel(grid, voxel, false, false)
	
	if not queue_chunks.has(chunk_grid): queue_chunks.append(chunk_grid)
	
	if update: update(false, emit)
	if emit: emit_signal('set_voxel', grid)

# Set raw Voxel data to given grid position, emits 'set_voxel'
# grid     :   Vector3          -   grid position to set Voxel to 
# voxel    :   int/Dictionary   -   Voxel to be set
# update   :   bool             -   call on update
# emit     :   bool             -   true, emit signal; false, don't emit signal
#
# Example:
#   set_rvoxel(Vector(11, -34, 2), 3)         #   NOTE: This would store a copy of the Voxels present Dictionary within the VoxelSet, not the ID itself
#   set_rvoxel(Vector(11, -34, 2), { ... })
#
func set_rvoxel(grid : Vector3, voxel : Dictionary, update : bool = false, emit : bool = true) -> void:
	.set_rvoxel(grid, voxel, update, emit)

# Get Voxel data from grid position
# grid       :   Vector3      -   grid position to get Voxel from
# @returns   :   Dictionary   -   Voxel data
#
# Example:
#   get_voxel(Vector(11, -34, 2))   ->   { ... }
#
func get_voxel(grid : Vector3) -> Dictionary: return .get_voxel(grid)

# Get raw Voxel from grid position
# grid       :   Vector3          -   grid position to get Voxel from
# @returns   :   int/Dictionary   -   raw Voxel
#
# Example:
#   get_rvoxel(Vector(11, -34, 2))   ->   3         #   NOTE: Returned ID representing  Voxel data
#   get_rvoxel(Vector(-7, 0, 96))    ->   { ... }   #   NOTE: Returned Voxel data
#
func get_rvoxel(grid : Vector3):
	var chunk_grid = grid_to_chunk(grid)
	
#	if chunks.has(chunk_grid):
#		return (chunks[chunk_grid] as VoxelMesh).get_voxel(grid)
#	else: return null
	return (chunks[chunk_grid] as VoxelMesh).get_voxel(grid) if chunks.has(chunk_grid) else null

# Erase Voxel from grid position, emits 'erased_voxel'
# grid     :   Vector3   -   grid position to erase Voxel from
# update   :   bool      -   call on update
# emit     :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   erase_voxel(Vector(11, -34, 2), false)
#
func erase_voxel(grid : Vector3, update : bool = false, emit : bool = true) -> void:
	var chunk_grid = grid_to_chunk(grid)
	
	if chunks.has(chunk_grid):
		(chunks[chunk_grid] as VoxelMesh).erase_voxel(grid, false, false)
	
	if not queue_chunks.has(chunk_grid): queue_chunks.append(chunk_grid)
#	update_chunks.append(chunk_grid)
	
	.erase_voxel(grid, update, emit)


# Clears and replaces all Voxels with given Voxels, emits 'set_voxels'
# voxels   :   Dictionary<Vector3, Voxel>   -   Voxels to set
# update   :   bool                         -   call on update
# emit     :   bool                         -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxels({ ... }, false, false)
#
func set_voxels(_voxels : Dictionary, update : bool = true, emit : bool = true) -> void:
	erase_voxels(false, emit)
	
	for voxel_grid in _voxels: set_voxel(voxel_grid, _voxels[voxel_grid], false, emit)
	
	queue_chunks = chunks.keys()
	
	if update: update(false, emit)
	if emit: emit_signal('set_voxels')

# Gets all present Voxel positions
# @returns   :   Dictionary<Vector3, Voxel>   -   Dictionary containing grid positions, as keys, and Voxels, as values
#
# Example:
#   get_voxels()   ->   { ... }
#
func get_voxels() -> Dictionary:
	var voxels = {}
	
	for chunk_grid in chunks:
		var _voxels = (chunks[chunk_grid] as VoxelMesh).get_voxels()
		for _voxel_grid in _voxels: voxels[_voxel_grid] = _voxels[_voxel_grid]
	
	return voxels

# Erases all present Voxels, emits 'erased_voxels'
# emit     :   bool   -   true, emit signal; false, don't emit signal
# update   :   bool   -   call on update
#
# Example:
#   erase_voxels(false)
#
func erase_voxels(emit : bool = true, update : bool = true) -> void:
	for chunk in chunks:
		remove_child(chunks[chunk])
		chunks[chunk].queue_free()
	
	chunks.clear()
	queue_chunks.clear()
	update_chunks.clear()
	
	if update: update(false, emit)
	if emit: emit_signal('erased_voxels')


# Updates mesh and StaticBody, emits 'updated'
# temp   :   bool   -   true, build temporary StaticBody; false, don't build temporary StaticBody
# emit   :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   update(false)
#
func update(temp : bool = false, emit : bool = true) -> void:
	print('updating VoxelMultiMesh')
	if queue_chunks.size() > 0:
		update_chunks = queue_chunks
		queue_chunks = []
	else: update_chunks = chunks.keys()
	
	.update(temp, emit)

# Sets and updates static trimesh body, emits 'updated_staticbody'
# temp   :   bool   -   true, build temporary StaticBody; false, don't build temporary StaticBody
# emit   :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   update_staticbody(false)
#
func update_staticbody(temp : bool = false, emit : bool = true) -> void:
	for chunk_grid in chunks: (chunks[chunk_grid] as VoxelMesh).update_staticbody(temp, false)
	
	.update_staticbody(temp, emit)


func grid_to_chunk(grid : Vector3) -> Vector3: return Vector3(floor(grid.x / ChunkSize), floor(grid.y / ChunkSize), floor(grid.z / ChunkSize))


func create_chunk(chunk_position, update : bool = true, emit : bool = true) -> void:
	var chunk : VoxelMesh = VoxelMesh.new()
	
	chunk.set_greedy(Greedy, false, false)
#	chunk.Static_Body = Static_Body
	
	chunks[chunk_position] = chunk
	add_child(chunk)


func update_chunk(data : Array) -> void:
	var thread : Thread = data[0]
	var chunk : VoxelMesh = chunks[data[1]]
	
	chunk.update(false, false)
	
	if not is_a_parent_of(chunk): call_deferred('add_child', chunk)
	
	call_deferred('updated_chunk', thread, data[1])

func updated_chunk(thread : Thread, chunk_grid : Vector3) -> void:
	update_chunks.erase(chunk_grid)
	if queue_chunks.size() == 0 and update_chunks.size() == 0:
		_save()
		set_processing(false)
	thread.wait_to_finish()


func remake_chunks(update : bool = true, emit : bool = true) -> void:
	var voxels = get_voxels()
	
	erase_voxels(false, emit)
	
	set_voxels(voxels, update, emit)
