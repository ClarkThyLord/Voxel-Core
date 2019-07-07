tool
extends "res://addons/VoxelCore/src/VoxelObject.gd"
class_name VoxelMultiMesh, 'res://addons/VoxelCore/assets/VoxelMultiMesh.png'



# VoxeMultiMesh is a more complex VoxelObject, with the objective of visualizing large amounts of Voxels with little to no latency between operations and updates



# Declarations
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
	
	for chunk_position in chunks: (chunks[chunk_position] as VoxelMesh).set_greedy(greedy, false, false)
	
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
	elif _voxelset == null: _voxelset = get_node('/root/CoreVoxelSet')
	elif voxelset is VoxelSet: voxelset.disconnect('update', self, 'update')
	
	voxelset = _voxelset
	for chunk in chunks: (chunks[chunk] as VoxelMesh).set_voxelset(_voxelset, false, false)
	if not voxelset.is_connected('update', self, 'update'): voxelset.connect('update', self, 'update')
	
	queue_chunks = chunks.keys()
	
	if update and is_inside_tree(): update(false, emit)
	if emit: emit_signal('set_voxelset', voxelset)

# Setter for StaticBody, emits 'set_static_body'
# staticbody   :   bool   -   value to set
# update       :   bool   -   call on staticbody update
# emit         :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_static_body(true, false)
#
func set_static_body(staticbody : bool = !Static_Body, update : bool = true, emit : bool = true) -> void:
	if staticbody != Static_Body: staticbody_chunks = chunks_data.keys()
	
	set_static_body_temp(false, false)
	Static_Body = staticbody
	
	# No need to call on StaticBody update
#	if update and is_inside_tree(): update_staticbody(false, emit)
	if update: staticbody_chunks = chunks_data.keys()
	if emit: emit_signal('set_static_body', Static_Body)

# Whether a StaticBody should be built temporarily
var static_body_temp : bool = false setget set_static_body_temp
# Setter for StaticBody, emits 'set_static_body'
# staticbody   :   bool   -   value to set
# update       :   bool   -   call on staticbody update
# emit         :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_static_body(true, false)
#
func set_static_body_temp(staticbody_temp : bool = !static_body_temp, update : bool = true) -> void:
	if staticbody_temp != static_body_temp:
		static_body_temp = staticbody_temp
		if update: staticbody_chunks = chunks_data.keys()
	
	static_body_temp = staticbody_temp


# Thread used for loading, creating and updating Voxels/Chunks
var thread : Thread = Thread.new() setget set_thread
func set_thread(_thread : Thread) -> void: return                      #   Shouldn't be settable externally


signal set_chunk_size(chunksize)
# Dimensions for Chunks
export(int, 2, 16, 2) var ChunkSize : int = 10 setget set_chunk_size
# Setter for ChunkSize, emits 'set_chunk_size'
# chunksize   :   bool   -   value to set
# emit        :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_chunk_size(16, false, false)
#
func set_chunk_size(chunksize : int, emit : bool = true) -> void:
	ChunkSize = chunksize
	
	remake_chunks(false, emit)
	if emit: emit_signal('set_chunk_size', ChunkSize)

# Chunks are VoxelMeshes that compose this VoxelObject
var chunks : Dictionary = {} setget set_chunks
func set_chunks(_chunks : Dictionary) -> void: return                  #   Shouldn't be settable externally

var chunks_data : Dictionary = {} setget set_chunks_data
func set_chunks_data(chunksdata : Dictionary) -> void: return          #   Shouldn't be settable externally


# Queue Chunks will be placed into update chunks on the next update call
var queue_chunks : Array = [] setget set_queue_chunks
func set_queue_chunks(queuechunks : Array) -> void: return             #   Shouldn't be settable externally

func queue_chunk(chunk_position : Vector3) -> void:
	if not queue_chunks.has(chunk_position) and not update_chunks.has(chunk_position): queue_chunks.append(chunk_position)

# Update Chunks will be updated in order within thread
var update_chunks : Array = [] setget set_update_chunks
func set_update_chunks(updatechunks : Array) -> void: return           #   Shouldn't be settable externally

# StaticBody Chunks will have their StaticBody updated
var staticbody_chunks : Array = [] setget set_staticbody_chunks
func set_staticbody_chunks(staticbodychunks : Array) -> void: return   #   Shouldn't be settable externally



# Core
func _load() -> void:
	._load()
	
	if has_meta('chunks_data'):
		chunks_data = get_meta('chunks_data')
		update_chunks = chunks_data.keys()
func _save() -> void:
	._save()
	
	set_meta('chunks_data', chunks_data)


# The following will initialize the object as needed
func _init() -> void: _load()
func _ready() -> void:
	set_voxelset_path(VoxelSetPath, false)
	_load()

func _exit_tree(): if thread.is_active(): thread.wait_to_finish()


func _process(delta):
	if update_chunks.size() > 0 and not thread.is_active():
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
	var chunk_position = grid_to_chunk(grid)
	
	if not chunks_data.has(chunk_position): create_chunk_in_data(chunk_position)
	
#	(chunks[chunk_position] as VoxelMesh).set_voxel(grid, voxel, false, false)
	chunks_data[chunk_position][grid] = voxel
	
	queue_chunk(chunk_position)
#	if not queue_chunks.has(chunk_position) and not update_chunks.has(chunk_position): queue_chunks.append(chunk_position)
	
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
	var chunk_position = grid_to_chunk(grid)
	
#	if chunks.has(chunk_position):
#		return (chunks[chunk_position] as VoxelMesh).get_voxel(grid)
#	else: return null
#	return (chunks[chunk_position] as VoxelMesh).get_voxel(grid) if chunks.has(chunk_position) else null
	return (chunks_data[chunk_position] as Dictionary).get(grid) if chunks_data.has(chunk_position) else null

# Erase Voxel from grid position, emits 'erased_voxel'
# grid     :   Vector3   -   grid position to erase Voxel from
# update   :   bool      -   call on update
# emit     :   bool      -   true, emit signal; false, don't emit signal
#
# Example:
#   erase_voxel(Vector(11, -34, 2), false)
#
func erase_voxel(grid : Vector3, update : bool = false, emit : bool = true) -> void:
	var chunk_position = grid_to_chunk(grid)
	
	if chunks_data.has(chunk_position):
		(chunks_data[chunk_position] as Dictionary).erase(grid)
		
		queue_chunk(chunk_position)
#		if not queue_chunks.has(chunk_position): queue_chunks.append(chunk_position)
	
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
	
	for chunk_position in chunks_data:
		var _voxels = chunks_data[chunk_position]
		for _voxel_grid in _voxels: voxels[_voxel_grid] = _voxels[_voxel_grid]
	
	return voxels

# Erases all present Voxels, emits 'erased_voxels'
# update   :   bool   -   call on update
# emit     :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   erase_voxels(false, false)
#
func erase_voxels(update : bool = true, emit : bool = true) -> void:
	for chunk_position in chunks:
		remove_child((chunks[chunk_position] as VoxelMesh))
		(chunks[chunk_position] as VoxelMesh).queue_free()
	
	chunks.clear()
	chunks_data.clear()
	queue_chunks.clear()
	update_chunks.clear()
	
	# no need to update
#	if update: update(false, emit)
	if emit: emit_signal('erased_voxels')


# Updates mesh and StaticBody, emits 'updated'
# temp   :   bool   -   true, build temporary StaticBody; false, don't build temporary StaticBody
# emit   :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   update(false)
#
func update(temp : bool = false, emit : bool = true) -> void:
	if queue_chunks.size() > 0:
		update_chunks = queue_chunks
		queue_chunks = []
	elif update_chunks.size() == 0: update_chunks = chunks.keys()
	
	.update(temp, emit)

# Sets and updates static trimesh body, emits 'updated_staticbody'
# temp   :   bool   -   true, build temporary StaticBody; false, don't build temporary StaticBody
# emit   :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   update_staticbody(false)
#
func update_staticbody(temp : bool = false, emit : bool = true) -> void:
	# TODO build and maintain StaticBody in thread!
	set_static_body_temp(temp)
#	if temp != staticbody_temp:
#		staticbody_temp = temp
#		staticbody_chunks = chunks_data.keys()
#	for chunk_position in chunks: (chunks[chunk_position] as VoxelMesh).update_staticbody(temp, false)
	
	.update_staticbody(temp, emit)


func grid_to_chunk(grid : Vector3) -> Vector3: return Vector3(floor(grid.x / ChunkSize), floor(grid.y / ChunkSize), floor(grid.z / ChunkSize))


func create_chunk(chunk_position : Vector3, add : bool = false) -> VoxelMesh:
	var chunk : VoxelMesh = VoxelMesh.new()
	
	chunk.set_greedy(Greedy, false, false)
	
	chunks[chunk_position] = chunk
	if add: call_deferred('add_child', chunk)
	
	return chunk

func create_chunk_in_data(chunk_position) -> void:
	chunks_data[chunk_position] = {}


signal updated_chunks
func update_chunk(data : Array) -> void:
	var thread : Thread = data[0]
	var chunk : VoxelMesh = chunks[data[1]] if chunks.has(data[1]) else create_chunk(data[1])
	var chunk_data : Dictionary = chunks_data[data[1]]
	
	chunk.set_voxels(chunk_data, false, false)
	chunk.update(Static_Body or static_body_temp, false)
	
	if not is_a_parent_of(chunk): call_deferred('add_child', chunk)
	
	call_deferred('updated_chunk', thread, data[1])

func updated_chunk(thread : Thread, chunk_position : Vector3) -> void:
	update_chunks.erase(chunk_position)
	if queue_chunks.size() == 0 and update_chunks.size() == 0:
		_save()
		emit_signal('updated_chunks')
	thread.wait_to_finish()


func remake_chunks(update : bool = true, emit : bool = true) -> void:
	var voxels = get_voxels()
	
	erase_voxels(false, emit)
	
	set_voxels(voxels, update, emit)
