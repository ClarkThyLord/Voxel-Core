tool
extends MeshInstance
class_name VoxelObject, 'res://addons/VoxelCore/assets/VoxelCore.png'



# Declarations
signal set_lock(lock)
# Whether VoxelObject can be 'edited'
export var Lock : bool = false setget set_lock
# Setter for Lock
# lock   :   bool   -   true, able to edit; false, unable to edit
# emit   :   bool   -   true, emit 'set_lock' signal; false, don't emit 'set_lock' signal
#
# Example:
#   set_lock(false, false)
#
func set_lock(lock : bool = !Lock, emit : bool = true) -> void:
	Lock = lock
	
	if emit: emit_signal('set_lock', lock)

signal set_permanent(permanent)
# Makes the VoxelObject permanent; permanent VoxelObject's can't have their original voxels modified
export var Permanent : bool = false setget set_permanent
# Setter for Permanent
# permanent   :   bool   -   true, able to edit 'editor' voxels; false, unable to edit 'editor' voxels
# emit        :   bool   -   true, emit 'set_permanent' signal; false, don't emit 'set_permanent' signal
#
# Example:
#   set_permanent(false, false)
#
func set_permanent(permanent : bool = !Permanent, emit : bool = true) -> void:
	Permanent = permanent
	
	if emit: emit_signal('set_permanent', permanent)


signal set_mirror_x(mirror)
# Flag that operations done to this VoxelObject should be mirrored over x axis
export var Mirror_X : bool = false setget set_mirror_x
# Setter for Mirror_X
# mirror   :   bool   -   true, mirror over x axis; false, don't mirror over x axis
# emit     :   bool   -   true, emit 'set_mirror_x' signal; false, don't emit 'set_mirror_x' signal
#
# Example:
#   set_mirror_x(false, false)
#
func set_mirror_x(mirror : bool = !Mirror_X, emit : bool = true) -> void:
	Mirror_X = mirror
	
	if emit: emit_signal('set_mirror_x', mirror)

signal set_mirror_y(mirror)
# Flag that operations done to this VoxelObject should be mirrored over y axis
export var Mirror_Y : bool = false setget set_mirror_y
# Setter for Mirror_Y
# mirror   :   bool   -   true, mirror over y axis; false, don't mirror over y axis
# emit     :   bool   -   true, emit 'set_mirror_y' signal; false, don't emit 'set_mirror_y' signal
#
# Example:
#   set_mirror_y(false, false)
#
func set_mirror_y(mirror : bool = !Mirror_Y, emit : bool = true) -> void:
	Mirror_Y = mirror
	
	if emit: emit_signal('set_mirror_y', mirror)

signal set_mirror_z(mirror)
# Flag that operations done to this VoxelObject should be mirrored over z axis
export var Mirror_Z : bool = false setget set_mirror_z
# Setter for Mirror_Z
# mirror   :   bool   -   true, mirror over z axis; false, don't mirror over z axis
# emit     :   bool   -   true, emit 'set_mirror_z' signal; false, don't emit 'set_mirror_z' signal
#
# Example:
#   set_mirror_z(false, false)
#
func set_mirror_z(mirror : bool = !Mirror_Z, emit : bool = true) -> void:
	Mirror_Z = mirror
	
	if emit: emit_signal('set_mirror_z', mirror)


signal set_buildgreedy(buildgreedy)
# Whether mesh of this VoxelObject is built greedy
export var BuildGreedy : bool = false setget set_buildgreedy
# Setter for BuildGreedy
# buildgreedy   :   bool   -   true, build greedy; false, don't build greedy
# update        :   bool   -   true, call for update; false, doens't call for update
# emit          :   bool   -   true, emit 'set_buildgreedy' signal; false, don't emit 'set_buildgreedy' signal
#
# Example:
#   set_buildgreedy(false, false)
#
func set_buildgreedy(buildgreedy : bool = !BuildGreedy, update : bool = true, emit : bool = true) -> void:
	BuildGreedy = buildgreedy
	
	if update and is_inside_tree(): update()
	if emit: emit_signal('set_buildgreedy', buildgreedy)


signal set_buildbody(buildbody)
# Whether to build a staticbody for this VoxelObject; NOTE: body is static trimesh
export var BuildBody : bool = false setget set_buildbody
# Setter for BuildBody
# buildbody   :   bool   -   true, build a static body; false, don't build a static body
# update      :   bool   -   true, call for update; false, doens't call for update
# emit        :   bool   -   true, emit 'set_buildbody' signal; false, don't emit 'set_buildbody' signal
#
# Example:
#   set_buildbody(false, false)
#
func set_buildbody(buildbody : bool = !BuildBody, update : bool = true, emit : bool = true) -> void:
	BuildBody = buildbody
	
	if update and is_inside_tree(): update_body()
	if emit: emit_signal('set_buildbody', buildbody)


signal set_dimensions(dimensions, clipped)
# Dimensions of VoxelObject; can't be modified outside of given dimensions and won't render voxels outside given dimensions
export var Dimensions : Vector3 = Vector3(16, 16, 16) setget set_dimensions
# Setter for Dimensions
# dimensions   :   Vector3   -   value to set Dimensions
# clip         :   bool      -   true, call for clip; false, doens't call for clip
# update       :   bool      -   true, call for update; false, doens't call for update
# emit         :   bool      -   true, emit 'set_buildbody' signal; false, don't emit 'set_buildbody' signal
#
# Example:
#   set_buildbody(false, false)
#
func set_dimensions(dimensions : Vector3, clip : bool = true, update : bool = true, emit : bool = true) -> void:
	Dimensions = dimensions
	
	if clip: clip_Voxels(update, emit)
	elif update and is_inside_tree(): update()
	if emit: emit_signal('set_dimensions', dimensions, clip)


signal set_voxels(voxels)
# Contains all Voxels; Dictionary<Vector3 : Dictionary>
var Voxels : Dictionary = {} setget set_voxels
func set_voxels(voxels : Dictionary, update : bool = true, emit : bool = true) -> void:
	Voxels = voxels.duplicate(true)
	
	clip_Voxels(update, emit)
	
	if emit: emit_signal('set_voxels', Voxels)

signal cleared_voxels
func clear_voxels(update : bool = true, emit : bool = true) -> void:
	Voxels.clear()
	
	if update and is_inside_tree(): update()
	if emit: emit_signal('cleared_voxels')

signal centered_voxels(options)
func center_voxels(options : Dictionary = {}, update : bool = true, emit : bool = true) -> void:
	var min_pos = Dimensions
	var max_pos = -Dimensions
	
	for voxel_grid in Voxels:
		if voxel_grid.x < min_pos.x: min_pos.x = voxel_grid.x
		if voxel_grid.y < min_pos.y: min_pos.y = voxel_grid.y
		if voxel_grid.z < min_pos.z: min_pos.z = voxel_grid.z
		
		if voxel_grid.x > max_pos.x: max_pos.x = voxel_grid.x
		if voxel_grid.y > max_pos.y: max_pos.y = voxel_grid.y
		if voxel_grid.z > max_pos.z: max_pos.z = voxel_grid.z
	
	var dimensions = Vector3(abs(min_pos.x - max_pos.x) + 1, abs(min_pos.y - max_pos.y) + 1, abs(min_pos.z - max_pos.z) + 1)
	
	var center_point = (min_pos + dimensions / 2).floor()
	
	if options.get('above_axis'): center_point.y += dimensions.y / 2 * -1
	
	var voxels = {}
	
	for voxel_grid in Voxels:
		voxels[(voxel_grid + (center_point * -1)).floor()] = get_voxel(voxel_grid)
	
	set_voxels(voxels, update, emit)
	
	if emit: emit_signal('centered_voxels', options)

signal cliped_voxels
func clip_Voxels(update : bool = false, emit : bool = true) -> void:
	for voxel_grid in Voxels:
		if not Voxel.grid_within_dimensions(voxel_grid, Dimensions):
			erase_voxel(voxel_grid, false, false)
	
	if update and is_inside_tree(): update()
	if emit: emit_signal('cliped_voxels', update)

func get_voxel(grid : Vector3) -> Dictionary:
	var voxel = Voxels.get(grid)
	
	if typeof(voxel) == TYPE_INT: voxel = VoxelSetUsed.get_voxel(voxel)
	
	return voxel

func get_voxel_xyz(x : int, y : int, z : int) -> Dictionary: return get_voxel(Vector3(x, y, z))

signal set_voxel(grid, voxel, update)
func set_voxel(grid : Vector3, voxel, update : bool = false, emit : bool = true) -> bool:
	if !Voxel.grid_within_dimensions(grid, Dimensions) or (!Engine.editor_hint and Permanent and Voxels.has(grid) and Voxel.get_editor(get_voxel(grid))):
		return false
	
	Voxels[grid] = voxel
	
	if update and is_inside_tree(): update()
	if emit: emit_signal('set_voxel', grid, voxel, update)
	
	return true

signal erased_voxel(grid, voxel, update)
func erase_voxel(grid : Vector3, update : bool = false, emit : bool = true) -> bool:
	if !Voxels.has(grid) or (!Engine.editor_hint and Permanent and Voxel.get_editor(get_voxel(grid))):
		return false
	
	var voxel = get_voxel(grid)
	
	Voxels.erase(grid)
	
	if update and is_inside_tree(): update()
	if emit: emit_signal('erased_voxel', grid, voxel, update)
	
	return true


signal set_voxelsetused(voxelsetused)
onready var VoxelSetUsed : VoxelSet setget set_voxelsetused
func set_voxelsetused(voxelsetused : VoxelSet, emit : bool = true) -> void:
	VoxelSetUsed = voxelsetused
	
	if emit: emit_signal('set_voxelsetused', voxelsetused)

export(NodePath) var VoxelSetPath : NodePath = NodePath('/root/CoreVoxelSet') setget set_voxelsetpath
# Sets the path to VoxelSetUsed, and the VoxelSetUsed in itself
# voxelsetpath   :   NodePath   -   path to VoxelSet to be set as VoxelSetUsed
#
# Example:
#   set_voxelsetpath([NodePath])
#
func set_voxelsetpath(voxelsetpath : NodePath, emit : bool = true) -> void:
	if is_inside_tree() and has_node(voxelsetpath) and get_node(voxelsetpath) is VoxelSet:
		set_voxelsetused(get_node(voxelsetpath), emit)
		VoxelSetPath = voxelsetpath



# Core
func _init():
	Voxels = get_meta('Voxels') if has_meta('Voxels') else {}

func _ready():
	set_voxelsetpath(VoxelSetPath)
	Voxels = get_meta('Voxels') if has_meta('Voxels') else {}


# Copy a VoxelObject
# voxelobject   :   VoxelObject   :   VoxelObject to copy
#
# Example:
#   copy([VoxelObject])
#
func copy(voxelobject : VoxelObject, update : bool = true) -> void:
	set_lock(voxelobject.Lock)
	set_permanent(voxelobject.Permanent)
	
	set_mirror_x(voxelobject.Mirror_X)
	set_mirror_y(voxelobject.Mirror_Y)
	set_mirror_z(voxelobject.Mirror_Z)
	
	set_buildgreedy(voxelobject.BuildGreedy)
	set_buildbody(voxelobject.BuildBody)
	
	set_dimensions(voxelobject.Dimensions)
	
	set_voxels(voxelobject.Voxels)
	set_voxelsetused(voxelobject.VoxelSetUsed)
	
	if update: update()


signal update
# Updates the mesh
# buildbody : bool - whether or not to buildbody
# emit : bool - true, emit signal 'udpate'; false, don't emit signal 'update'
#
# Example:
#   update(false, false)
#
func update(buildbody : bool = BuildBody, emit : bool = true) -> void:
	# If there are any voxels start building mesh
	if Voxels.size() > 0:
		# Create and setup SurfaceTool
		var ST = SurfaceTool.new()
		ST.begin(Mesh.PRIMITIVE_TRIANGLES)
		var material = SpatialMaterial.new()
		material.roughness = 1
		material.vertex_color_is_srgb = true
		material.vertex_color_use_as_albedo = true
		ST.set_material(material)
		
		# Arrays which will contain used voxel's faces
		var rights = []
		var lefts = []
		var ups = []
		var downs = []
		var forwards = []
		var backs = []
		
		# Iterate over each voxel
		for voxel_grid in Voxels:
			# If voxel isn't within dimensions don't build it
			if !Voxel.grid_within_dimensions(voxel_grid, Dimensions): continue
			
			# If another voxel is located to the right of this voxel don't build this voxel's right side
			if !Voxels.has(voxel_grid + Vector3.RIGHT):
				# If we're building greedy and this voxels right side hasn't been built then build greedy; else if we aren't building greedy then just build this voxel's right face
				if BuildGreedy and !rights.has(voxel_grid):
					# Since we're about to build this voxel's right side add it to used voxels
					rights.append(voxel_grid)
					
					
					# Declare the origin of greedy building
					var g1 = voxel_grid
					var g2 = voxel_grid
					var g3 = voxel_grid
					var g4 = voxel_grid
					
					var voxels = get_voxels_towards(voxel_grid, Vector3.BACK, 1, 0, 0, true, { 'exclude': rights, 'unblocked': [Vector3.RIGHT], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })
					
					g2 += Vector3.BACK * voxels.size()
					g4 += Vector3.BACK * voxels.size()
					
					rights += voxels
					
					voxels = get_voxels_towards(voxel_grid, Vector3.FORWARD, 1, 0, 0, true, { 'exclude': rights, 'unblocked': [Vector3.RIGHT], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

					g1 += Vector3.FORWARD * voxels.size()
					g3 += Vector3.FORWARD * voxels.size()

					rights += voxels
					
					var length = 1 + abs(g1.z - g2.z)
					
					voxels.clear()
					while true:
						voxels = get_voxels_towards(g3 + Vector3.UP, Vector3.BACK, 0, length, length, false, { 'exclude': rights, 'unblocked': [Vector3.RIGHT], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g3 += Vector3.UP
							g4 += Vector3.UP 
							rights += voxels
						else:
							break
					
					voxels.clear()
					while true:
						voxels = get_voxels_towards(g1 + Vector3.DOWN, Vector3.BACK, 0, length, length, false, { 'exclude': rights, 'unblocked': [Vector3.RIGHT], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g1 += Vector3.DOWN
							g2 += Vector3.DOWN
							rights += voxels
						else:
							break
					
					generate_right(ST, get_voxel(voxel_grid), g1, g2, g3, g4)
				elif !BuildGreedy: generate_right(ST, get_voxel(voxel_grid), voxel_grid)
			
			if !Voxels.has(voxel_grid + Vector3.LEFT):
				if BuildGreedy and !lefts.has(voxel_grid):
					lefts.append(voxel_grid)
					
					var g1 = voxel_grid
					var g2 = voxel_grid
					var g3 = voxel_grid
					var g4 = voxel_grid
					
					var voxels = get_voxels_towards(voxel_grid, Vector3.BACK, 1, 0, 0, true, { 'exclude': lefts, 'unblocked': [Vector3.LEFT], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })
					
					g3 += Vector3.BACK * voxels.size()
					g4 += Vector3.BACK * voxels.size()
					
					lefts += voxels
					
					voxels = get_voxels_towards(voxel_grid, Vector3.FORWARD, 1, 0, 0, true, { 'exclude': lefts, 'unblocked': [Vector3.LEFT], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

					g1 += Vector3.FORWARD * voxels.size()
					g2 += Vector3.FORWARD * voxels.size()

					lefts += voxels
					
					var length = 1 + abs(g1.z - g3.z)

					voxels.clear()
					while true:
						voxels = get_voxels_towards(g2 + Vector3.UP, Vector3.BACK, 0, length, length, false, { 'exclude': lefts, 'unblocked': [Vector3.LEFT], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g2 += Vector3.UP
							g4 += Vector3.UP 
							lefts += voxels
						else:
							break

					voxels.clear()
					while true:
						voxels = get_voxels_towards(g1 + Vector3.DOWN , Vector3.BACK, 0, length, length, false, { 'exclude': lefts, 'unblocked': [Vector3.LEFT], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g1 += Vector3.DOWN
							g3 += Vector3.DOWN
							lefts += voxels
						else:
							break
					
					generate_left(ST, get_voxel(voxel_grid), g1, g2, g3, g4)
				elif !BuildGreedy: generate_left(ST, get_voxel(voxel_grid), voxel_grid)
			
			if !Voxels.has(voxel_grid + Vector3.UP):
				if BuildGreedy and !ups.has(voxel_grid):
					ups.append(voxel_grid)
					
					var g1 = voxel_grid
					var g2 = voxel_grid
					var g3 = voxel_grid
					var g4 = voxel_grid
					
					var voxels = get_voxels_towards(voxel_grid, Vector3.BACK, 1, 0, 0, true, { 'exclude': ups, 'unblocked': [Vector3.UP], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })
					
					g3 += Vector3.BACK * voxels.size()
					g4 += Vector3.BACK * voxels.size()
					
					ups += voxels
					
					voxels = get_voxels_towards(voxel_grid, Vector3.FORWARD, 1, 0, 0, true, { 'exclude': ups, 'unblocked': [Vector3.UP], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

					g1 += Vector3.FORWARD * voxels.size()
					g2 += Vector3.FORWARD * voxels.size()

					ups += voxels
					
					var length = 1 + abs(g1.z - g3.z)

					voxels.clear()
					while true:
						voxels = get_voxels_towards(g2 + Vector3.RIGHT , Vector3.BACK, 0, length, length, false, { 'exclude': ups, 'unblocked': [Vector3.UP], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g2 += Vector3.RIGHT
							g4 += Vector3.RIGHT 
							ups += voxels
						else:
							break

					voxels.clear()
					while true:
						voxels = get_voxels_towards(g1 + Vector3.LEFT, Vector3.BACK, 0, length, length, false, { 'exclude': ups, 'unblocked': [Vector3.UP], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g1 += Vector3.LEFT
							g3 += Vector3.LEFT
							ups += voxels
						else:
							break
					
					generate_up(ST, get_voxel(voxel_grid), g1, g2, g3, g4)
				elif !BuildGreedy: generate_up(ST, get_voxel(voxel_grid), voxel_grid)
			
			if !Voxels.has(voxel_grid + Vector3.DOWN):
				if BuildGreedy and !downs.has(voxel_grid):
					downs.append(voxel_grid)
					
					var g1 = voxel_grid
					var g2 = voxel_grid
					var g3 = voxel_grid
					var g4 = voxel_grid
					
					var voxels = get_voxels_towards(voxel_grid, Vector3.BACK, 1, 0, 0, true, { 'exclude': downs, 'unblocked': [Vector3.DOWN], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })
					
					g2 += Vector3.BACK * voxels.size()
					g4 += Vector3.BACK * voxels.size()
					
					downs += voxels
					
					voxels = get_voxels_towards(voxel_grid, Vector3.FORWARD, 1, 0, 0, true, { 'exclude': downs, 'unblocked': [Vector3.DOWN], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

					g1 += Vector3.FORWARD * voxels.size()
					g3 += Vector3.FORWARD * voxels.size()

					downs += voxels
					
					var length = 1 + abs(g1.z - g2.z)

					voxels.clear()
					while true:
						voxels = get_voxels_towards(g3 + Vector3.RIGHT, Vector3.BACK, 0, length, length, false, { 'exclude': downs, 'unblocked': [Vector3.DOWN], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g3 += Vector3.RIGHT
							g4 += Vector3.RIGHT 
							downs += voxels
						else:
							break

					voxels.clear()
					while true:
						voxels = get_voxels_towards(g1 + Vector3.LEFT, Vector3.BACK, 0, length, length, false, { 'exclude': downs, 'unblocked': [Vector3.DOWN], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g1 += Vector3.LEFT
							g2 += Vector3.LEFT
							downs += voxels
						else:
							break
					
					generate_down(ST, get_voxel(voxel_grid), g1, g2, g3, g4)
				elif !BuildGreedy: generate_down(ST, get_voxel(voxel_grid), voxel_grid)
			
			if !Voxels.has(voxel_grid + Vector3.BACK):
				if BuildGreedy and !backs.has(voxel_grid):
					backs.append(voxel_grid)
					
					var g1 = voxel_grid
					var g2 = voxel_grid
					var g3 = voxel_grid
					var g4 = voxel_grid
					
					var voxels = get_voxels_towards(voxel_grid, Vector3.RIGHT, 1, 0, 0, true, { 'exclude': backs, 'unblocked': [Vector3.BACK], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })
					
					g3 += Vector3.RIGHT * voxels.size()
					g4 += Vector3.RIGHT * voxels.size()
					
					backs += voxels
					
					voxels = get_voxels_towards(voxel_grid, Vector3.LEFT, 1, 0, 0, true, { 'exclude': backs, 'unblocked': [Vector3.BACK], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

					g1 += Vector3.LEFT * voxels.size()
					g2 += Vector3.LEFT * voxels.size()

					backs += voxels
					
					var length = 1 + abs(g1.x - g3.x)

					voxels.clear()
					while true:
						voxels = get_voxels_towards(g2 + Vector3.UP, Vector3.RIGHT, 0, length, length, false, { 'exclude': backs, 'unblocked': [Vector3.BACK], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g2 += Vector3.UP
							g4 += Vector3.UP 
							backs += voxels
						else:
							break

					voxels.clear()
					while true:
						voxels = get_voxels_towards(g1 + Vector3.DOWN , Vector3.RIGHT, 0, length, length, false, { 'exclude': backs, 'unblocked': [Vector3.BACK], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g1 += Vector3.DOWN
							g3 += Vector3.DOWN
							backs += voxels
						else:
							break
					generate_back(ST, get_voxel(voxel_grid), g1, g2, g3, g4)
				elif !BuildGreedy: generate_back(ST, get_voxel(voxel_grid), voxel_grid)
			
			if !Voxels.has(voxel_grid + Vector3.FORWARD):
				if BuildGreedy and !forwards.has(voxel_grid):
					forwards.append(voxel_grid)
					
					var g1 = voxel_grid
					var g2 = voxel_grid
					var g3 = voxel_grid
					var g4 = voxel_grid
					
					var voxels = get_voxels_towards(voxel_grid, Vector3.RIGHT, 1, 0, 0, true, { 'exclude': forwards, 'unblocked': [Vector3.FORWARD], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })
					
					g2 += Vector3.RIGHT * voxels.size()
					g4 += Vector3.RIGHT * voxels.size()
					
					forwards += voxels
					
					voxels = get_voxels_towards(voxel_grid, Vector3.LEFT, 1, 0, 0, true, { 'exclude': forwards, 'unblocked': [Vector3.FORWARD], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

					g1 += Vector3.LEFT * voxels.size()
					g3 += Vector3.LEFT * voxels.size()

					forwards += voxels
					
					var length = 1 + abs(g1.x - g2.x)

					voxels.clear()
					while true:
						voxels = get_voxels_towards(g3 + Vector3.UP, Vector3.RIGHT, 0, length, length, false, { 'exclude': forwards, 'unblocked': [Vector3.FORWARD], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g3 += Vector3.UP
							g4 += Vector3.UP 
							forwards += voxels
						else:
							break

					voxels.clear()
					while true:
						voxels = get_voxels_towards(g1 + Vector3.DOWN, Vector3.RIGHT, 0, length, length, false, { 'exclude': forwards, 'unblocked': [Vector3.FORWARD], 'exact_color': Voxel.get_color(get_voxel(g1)), 'return': 'grid' })

						if voxels.size() > 0:
							g1 += Vector3.DOWN
							g2 += Vector3.DOWN
							forwards += voxels
						else:
							break
					
					generate_forward(ST, get_voxel(voxel_grid), g1, g2, g3, g4)
				elif !BuildGreedy: generate_forward(ST, get_voxel(voxel_grid), voxel_grid)
		
#		print('FACES: ' + str(vertex_count / 2) + ' | VERTICES: ' + str(vertex_count))
		
		ST.index()
		mesh = ST.commit()
	else:
		mesh = null
	
	
	update_body(buildbody, emit)
	
	if emit: emit_signal('update')
	
	set_meta('Voxels', Voxels)

signal update_body(temp)
# Updates the StaticBody
# temp : bool - overrides BuildBody
# emit : bool - true, emit signal 'update_body'; false, don't emit signal 'update_body'
#
# Example:
#   update_body(true, false)
#
func update_body(temp : bool = false, emit : bool = true) -> void:
	var _StaticBody
	if has_node('StaticBody'):
		_StaticBody = get_node('StaticBody')
	
	if (temp or BuildBody) and mesh and Voxels.size() > 0:
		var _CollisionShape
		if !_StaticBody:
			_StaticBody = StaticBody.new()
			_StaticBody.set_name('StaticBody')
		
		if _StaticBody.has_node('CollisionShape'):
			_CollisionShape = _StaticBody.get_node('CollisionShape')
		else:
			_CollisionShape = CollisionShape.new()
			_CollisionShape.set_name('CollisionShape')
		
			_StaticBody.add_child(_CollisionShape)
		
		_CollisionShape.shape = mesh.create_trimesh_shape()
		
		if !has_node('StaticBody'):
			add_child(_StaticBody)
		
		if BuildBody and !_StaticBody.owner:
			_StaticBody.set_owner(get_tree().get_edited_scene_root())
		if BuildBody and !_CollisionShape.owner:
			_CollisionShape.set_owner(get_tree().get_edited_scene_root())
	elif (!(temp or BuildBody) or Voxels.size() <= 0) and _StaticBody:
		remove_child(_StaticBody)
		_StaticBody.queue_free()
	
	if emit: emit_signal('update_body', temp)


# Retrieves a Voxel to given direction and distance from given origin
# origin      :   Vector3           :   origin positin
# direction   :   Vector3           :   direction
# offset      :   int               :   distance
# options     :   Dictionary        :   optinal flags
# @returns    :   Dictionary/Null   :   Dictionary, if voxel is found; null, no voxel found
#
# Example:
#   get_voxel_towards(Vector3(4, 32, -7), Vector3(1, 0, 0), 100, { ... }) -> Dictionary[Voxel]
#
func get_voxel_towards(origin : Vector3, direction : Vector3, offset : int = 1, options : Dictionary = {}):
	var voxel = origin + direction * offset
	
	if options.has('pool'):
		if typeof(options['pool']) == TYPE_ARRAY and !options['pool'].has(voxel): return null
		elif typeof(options['pool']) == TYPE_DICTIONARY and !options['pool'].has(voxel): return null
	elif !get_voxel(voxel): return null
	
	if options.has('exact_color') and options['exact_color'] != Voxel.get_color(get_voxel(voxel)):
		return null
	
	if options.has('exclude') and options['exclude'].has(voxel):
		return null
	
	if options.has('blocked'):
		for block in options['blocked']:
			if !get_voxel_towards(voxel, block, 1):
				return null
	
	if options.has('unblocked'):
		for unblock in options['unblocked']:
			if get_voxel_towards(voxel, unblock, 1):
				return null
	
	return voxel if options.get('return') == 'grid' else get_voxel(voxel)

# Retrieves a Voxel to given direction and distance from given origin
# origin       :   Vector3           :   origin positin
# direction    :   Vector3           :   direction
# offset       :   int               :   distance
# minimum      :   int               :   minimum amount of voxels to retrieve
# maximum      :   int               :   maximum amount of voxels to retrieve
# extensinve   :   bool              :   retrieve within range given
# options      :   Dictionary        :   optinal flags
# @returns     :   Array<Dictionary>/Null   :   Array<Dictionary>, array of voxels if found; null, no voxel found
#
# Example:
#   get_voxels_towards(Vector3(4, 32, -7), Vector3(1, 0, 0), 100, 3, 7, false, { ... }) -> Array<Voxel>
#
func get_voxels_towards(origin : Vector3, direction : Vector3, offset : int = 1, minimum : int = 0, maximum : int = 0, extensive : bool = false, options : Dictionary = {}) -> Array:
	var results = []
	
	while true:
		var voxel = get_voxel_towards(origin, direction, offset + results.size(), options)
		
		if voxel: results.append(voxel)
		else: break
		
		if !extensive and results.size() == maximum: break
	
	if (minimum > 0 and results.size() < minimum) or (extensive and maximum > 0 and results.size() > maximum): results.clear()
	
	return results


func generate_right(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2=null, g3=null, g4=null) -> void:
	st.add_normal(Vector3.RIGHT)
	st.add_color(Voxel.get_color_right(voxel))
	
	st.add_vertex(Voxel.grid_to_pos(g1 + Vector3.RIGHT))
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))

func generate_left(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2=null, g3=null, g4=null) -> void:
	st.add_normal(Vector3.LEFT)
	st.add_color(Voxel.get_color_left(voxel))
	
	st.add_vertex(Voxel.grid_to_pos(g1))
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.UP))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.UP))
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.UP + Vector3.BACK))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.BACK))

func generate_up(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2=null, g3=null, g4=null) -> void:
	st.add_normal(Vector3.UP)
	st.add_color(Voxel.get_color_up(voxel))
	
	st.add_vertex(Voxel.grid_to_pos(g1 + Vector3.UP))
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.UP))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.UP + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.UP))
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.UP + Vector3.BACK))

func generate_down(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2=null, g3=null, g4=null) -> void:
	st.add_normal(Vector3.DOWN)
	st.add_color(Voxel.get_color_down(voxel))
	
	st.add_vertex(Voxel.grid_to_pos(g1))
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT))

func generate_back(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2=null, g3=null, g4=null) -> void:
	st.add_normal(Vector3.BACK)
	st.add_color(Voxel.get_color_back(voxel))
	
	st.add_vertex(Voxel.grid_to_pos(g1 + Vector3.BACK))
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.UP + Vector3.BACK))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.UP + Vector3.BACK))
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.BACK))

func generate_forward(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2=null, g3=null, g4=null) -> void:
	st.add_normal(Vector3.FORWARD)
	st.add_color(Voxel.get_color_forward(voxel))
	
	st.add_vertex(Voxel.grid_to_pos(g1))
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT))
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.RIGHT + Vector3.UP))
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))
