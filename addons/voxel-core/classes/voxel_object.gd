tool
extends MeshInstance
# Makeshift interface class inhereted by all voxel visualization objects.



## Signals
# Emitted when VoxelSet is changed
signal set_voxel_set(voxel_set)



## Enums
# Defines the modes in which Mesh can be constructed
enum MeshModes {
	# Naive meshing, simple culling of voxel faces; http://web.archive.org/web/20200428085802/https://0fps.net/2012/06/30/meshing-in-a-minecraft-game/
	NAIVE,
	# Greedy meshing, culls and merges similar voxel faces; http://web.archive.org/web/20201112011204/https://www.gedge.ca/dev/2014/08/17/greedy-voxel-meshing
	GREEDY,
	# Marching Cubes meshing, https://en.wikipedia.org/wiki/Marching_cubes
	#MARCHING_CUBES,
	# Transvoxel meshing, http://web.archive.org/web/20201112033736/http://transvoxel.org/
	#TRANSVOXEL,
}



## Exported Variables
# The meshing mode by which Mesh is generated
export(MeshModes) var mesh_mode := MeshModes.NAIVE setget set_mesh_mode

# Flag indicating that UV Mapping should be applied when generating meshes if applicable
export var uv_map := false setget set_uv_map

# Flag indicating the persitant attachment and maintenance of a StaticBody
export var static_body := false setget set_static_body

# Size of each voxel in object
export var voxel_size := 0.5 setget set_voxel_size

# The VoxelSet for this VoxelObject
export(Resource) var voxel_set = null setget set_voxel_set



## Public Variables
# Flag indicating that edits to voxel data will be frequent
# NOTE: When true will only allow naive meshing
var edit_hint := 0 setget set_edit_hint


# Public Methods
# Sets the EditHint flag, calls update_mesh if needed and not told otherwise
func set_edit_hint(value : int, update := is_inside_tree()) -> void:
	edit_hint = value
	
	if update:
		update_mesh()


# Sets the mesh_mode, calls update_mesh if needed and not told otherwise
func set_mesh_mode(value : int, update := is_inside_tree()) -> void:
	mesh_mode = value
	
	if update:
		update_mesh()


# Sets the uv_map, calls update_mesh if needed and not told otherwise
func set_uv_map(value : bool, update := is_inside_tree()) -> void:
	uv_map = value
	
	if update:
		update_mesh()


# Sets the size of each voxel, calls update_mesh if needed and not told otherwise
func set_voxel_size(value : float, update := is_inside_tree()) -> void:
	voxel_size = value
	
	if update:
		update_mesh()


# Sets static_body, calls update_static_body if needed and not told otherwise
func set_static_body(value : bool, update := is_inside_tree()) -> void:
	static_body = value
	
	if update:
		update_static_body()


# Sets voxel_set, calls update_mesh if needed and not told otherwise
func set_voxel_set(value : Resource, update := is_inside_tree()) -> void:
	if not (typeof(value) == TYPE_NIL or value is VoxelSet):
		printerr("Invalid Resource given expected VoxelSet")
		return
	
	if is_instance_valid(voxel_set):
		if voxel_set.is_connected("requested_refresh", self, "update_mesh"):
			voxel_set.disconnect("requested_refresh", self, "update_mesh")
	
	voxel_set = value
	if is_instance_valid(voxel_set):
		if not voxel_set.is_connected("requested_refresh", self, "update_mesh"):
			voxel_set.connect("requested_refresh", self, "update_mesh")
	
	if update:
		update_mesh()
	emit_signal("set_voxel_set", voxel_set)


# Return true if no voxels are present
func empty() -> bool:
	return true


# Sets given voxel id at the given grid position
func set_voxel(grid : Vector3, voxel_id : int) -> void:
	pass


# Replace current voxel data with given voxel data
# voxels : Dictionary<Vector3, int> : voxels to set
func set_voxels(voxels : Dictionary) -> void:
	erase_voxels()
	for grid in voxels:
		set_voxel(grid, voxels[grid])


# Returns voxel id at given grid position if present; otherwise returns -1
func get_voxel_id(grid : Vector3) -> int:
	return -1


# Returns voxel Dictionary representing voxel id at given grid position
func get_voxel(grid : Vector3) -> Dictionary:
	return voxel_set.get_voxel(get_voxel_id(grid))


# Returns Array of all voxel grid positions
# return   :   Array<Vector3>   :   Array of Vector3 each represents a grid position of a voxel
func get_voxels() -> Array:
	return []


# Returns Dictionary of all voxel grid positions with their voxel id
# return   :   Dictionary<Vector3, int>   :   Dictionary with Vector3 each representing a grid position of a voxel with a VoxelSet id
func get_voxel_ids() -> Dictionary:
	return {}


# Erase voxel id at given grid position
func erase_voxel(grid : Vector3) -> void:
	pass


# Erase all voxels
func erase_voxels() -> void:
	for grid in get_voxels():
		erase_voxel(grid)


# Returns 3D axis-aligned bounding box
# volume   :   Array<Vector3>   :   Array of grid positions from which to calculate bounds
# return   :   Dictionary       :   bounding box, contains: { position : Vector3, size: Vector3, end: Vector3 }
func get_box(volume := get_voxels()) -> Dictionary:
	var box := {
		"position": Vector3.ZERO,
		"size": Vector3.ZERO,
		"end": Vector3.ZERO,
	}
	
	if not volume.empty():
		box["position"] = Vector3.INF
		box["size"] = -Vector3.INF
		
		for voxel_grid in volume:
			if voxel_grid.x < box["position"].x:
				box["position"].x = voxel_grid.x
			if voxel_grid.y < box["position"].y:
				box["position"].y = voxel_grid.y
			if voxel_grid.z < box["position"].z:
				box["position"].z = voxel_grid.z
			
			if voxel_grid.x > box["size"].x:
				box["size"].x = voxel_grid.x
			if voxel_grid.y > box["size"].y:
				box["size"].y = voxel_grid.y
			if voxel_grid.z > box["size"].z:
				box["size"].z = voxel_grid.z
		
		box["size"] = (box["size"] - box["position"]).abs() + Vector3.ONE
		box["end"] = box["position"] + box["size"]
	
	return box


# Returns 3D axis-aligned bounding box, transformed to global coordinates
# volume   :   Array<Vector3>   :   Array of grid positions from which to calculate bounds
# return   :   Dictionary       :   bounding box, contains: { position : Vector3, size: Vector3, end: Vector3 }
func get_box_transformed(volume := get_voxels()) -> Dictionary:
	var box := get_box(volume)
	
	box.position = box.position * voxel_size
	box.end = box.end * voxel_size
	
	box.position = global_transform.xform(box.position)
	box.end = global_transform.xform(box.end)
	box.size = box.end - box.position
	
	return box


# Moves voxels in given volume by given translation
# translation   :   Vector3          :   translation to move voxels by
# volume        :   Array<Vector3>   :   Array of grid positions representing voxels to move
func move(translation := Vector3(), volume := get_voxels()) -> void:
	var translated := {}
	for voxel_grid in volume:
		translated[voxel_grid + translation] = get_voxel_id(voxel_grid)
		erase_voxel(voxel_grid)
	for voxel_grid in translated:
		set_voxel(voxel_grid, translated[voxel_grid])


# Centers voxels in given volume with respect to axis origin with the given alignment
# alignment   :   Vector3          :   Alignment to center voxels by
# volume      :   Array<Vector3>   :   Array of grid positions representing voxels to center
func center(alignment := Vector3(0.5, 0.5, 0.5), volume := get_voxels()) -> void:
	move(vec_to_center(alignment, volume), volume)


# Flips voxels in given volume over set axis
func flip(x : bool, y : bool, z : bool, volume := get_voxels()) -> void:
	var flipped := {}
	for voxel_grid in volume:
		flipped[Vector3(
			(voxel_grid.x + (1 if z else 0)) * (-1 if z else 1),
			(voxel_grid.y + (1 if y else 0)) * (-1 if y else 1),
			(voxel_grid.z + (1 if x else 0)) * (-1 if x else 1)
		)] = get_voxel_id(voxel_grid)
		erase_voxel(voxel_grid)
	for voxel_grid in flipped:
		set_voxel(voxel_grid, flipped[voxel_grid])


# Returns the translation necessary to center given volume by
# alignment   :   Vector3          :   Alignment to center voxels by
# volume      :   Array<Vector3>   :   Array of grid positions representing voxels to center
# return      :   Vector3          :   Translation necessary to center
func vec_to_center(alignment := Vector3(0.5, 0.5, 0.5), volume := get_voxels()) -> Vector3:
	var box := get_box(volume)
	alignment = Vector3(
		clamp(alignment.x, 0.0, 1.0),
		clamp(alignment.y, 0.0, 1.0),
		clamp(alignment.z, 0.0, 1.0)
	)
	return -box["position"] - (box["size"] * alignment).floor()


# A Fast Voxel Traversal Algorithm for Ray Tracing, by John Amanatides
# Algorithm paper: https://web.archive.org/web/20201108160724/http://www.cse.chalmers.se/edu/year/2010/course/TDA361/grid.pdf
# from           :   Vector3                      :   World position from which to start raycast
# direction      :   Vector3                      :   Direction of raycast
# max_distance   :   int                          :   Maximum distance of ray cast
# stop           :   FuncRef                      :   Calls on function, that receives "hit" and returns bool, as raycast is projected, if it returns true raycast is returned
# return         :   Dictionary<String, Vector3>  :   If voxel is "hit", returns Dictionary with grid position and face normal; else empty
func intersect_ray(
		from : Vector3,
		direction : Vector3,
		max_distance := 64,
		stop : FuncRef = null) -> Dictionary:
	var hit := {
		"normal": Vector3(),
	}
	var grid := Voxel.world_to_grid(from, voxel_size)
	var step := Vector3(
			1 if direction.x > 0 else -1,
			1 if direction.y > 0 else -1,
			1 if direction.z > 0 else -1)
	var t_delta := direction.inverse().abs()
	var dist := from.distance_to(Voxel.world_to_snapped(from, voxel_size))
	var t_max := t_delta * dist
	var step_index := -1
	
	var t = 0.0
	var valid := false
	while t < max_distance:
		hit["position"] = grid
		hit["normal"].x = -step.x if step_index == 0 else 0
		hit["normal"].y = -step.y if step_index == 1 else 0
		hit["normal"].z = -step.z if step_index == 2 else 0
		if get_voxel_id(grid) > -1 or (is_instance_valid(stop) and stop.call_func(hit)):
			valid = true
			break
		
		match t_max.min_axis():
			Vector3.AXIS_X:
				grid.x += step.x
				t = t_max.x
				t_max.x += t_delta.x
				step_index = 0
			Vector3.AXIS_Y:
				grid.y += step.y
				t = t_max.y
				t_max.y += t_delta.y
				step_index = 1
			Vector3.AXIS_Z:
				grid.z += step.z
				t = t_max.z
				t_max.z += t_delta.z
				step_index = 2
	if not valid:
		hit.clear()
	return hit


# Returns Array of all voxel grid positions connected to given target
# target     :   Vector3          :   Grid position at which to start flood select
# selected   :   Array            :   Array to add selected voxel grid positions to
# return     :   Array<Vector3>   :   Array of all voxel grid positions connected to given target
func select_flood(target : Vector3, selected := []) -> Array:
	selected.append(get_voxel_id(target))
	
	for direction in Voxel.Faces:
		var next = target + direction
		if get_voxel_id(next) == get_voxel_id(selected[0]):
			if not selected.has(next):
				select_flood(next, selected)
	
	return selected


# Returns Array of all voxel grid positions connected to given target that aren't obstructed at the given face normal
# target        :   Vector3          :   Grid position at which to start flood select
# face_normal   :   Vector3          :   Normal of face to check for obstruction
# selected      :   Array            :   Array to add selected voxel grid positions to
# return        :   Array<Vector3>   :   Array of all voxel grid positions connected to given target
func select_face(target : Vector3, face_normal : Vector3, selected := []) -> Array:
	selected.append(target)
	
	for direction in Voxel.Faces[face_normal]:
		var next = target + direction
		if get_voxel_id(next) > -1:
			if get_voxel_id(next + face_normal) == -1:
				if not selected.has(next):
					select_face(next, face_normal, selected)
	
	return selected


# Returns Array of all voxel grid positions connected to given target that are similar and aren't obstructed at the given face normal
# target        :   Vector3          :   Grid position at which to start flood select
# face_normal   :   Vector3          :   Normal of face to check for obstruction
# selected      :   Array            :   Array to add selected voxel grid positions to
# return        :   Array<Vector3>   :   Array of all voxel grid positions connected to given target
func select_face_similar(target : Vector3, face_normal : Vector3, selected := []) -> Array:
	selected.append(target)
	
	for direction in Voxel.Faces[face_normal]:
		var next = target + direction
		if get_voxel_id(next) == get_voxel_id(selected[0]):
			if get_voxel_id(next + face_normal) == -1:
				if not selected.has(next):
					select_face_similar(next, face_normal, selected)
	
	return selected


# Loads and sets voxels and replaces VoxelSet with given file
# NOTE: Reference Reader.gd for valid file imports
# source_file     :   String   :   Path to file to be loaded
# new_voxel_set   :   bool     :   If true new VoxelSet is created, else overwrite current one
# return int      :   int      :   Error code
func load_file(source_file : String, new_voxel_set := true) -> int:
	var read := Reader.read_file(source_file)
	var error : int = read.get("error", FAILED)
	if error == OK:
		if read.has("palette"):
			if new_voxel_set or not is_instance_valid(voxel_set):
				set_voxel_set(VoxelSet.new(), false)
			voxel_set.set_voxels(read["palette"])
		
		if read.has("voxels"):
			set_voxels(read["voxels"])
	return error


# Makes a naive mesh out of volume of voxels given
# volume   :   Array<Vector3>    :   Array of grid positions representing volume of voxels from which to buid ArrayMesh
# vt       :   VoxelTool         :   VoxelTool with which ArrayMesh will be built
# return   :   ArrayMesh         :   Naive voxel mesh
func naive_volume(volume : Array, vt : VoxelTool = null) -> ArrayMesh:
	if not is_instance_valid(voxel_set):
		return null
	
	if not vt:
		vt = VoxelTool.new()
		vt.set_voxel_size(voxel_size)
	
	vt.begin(voxel_set, uv_map)
	
	for position in volume:
		for direction in Voxel.Faces:
			if get_voxel_id(position + direction) == -1:
				vt.add_face(get_voxel(position), direction, position)
	
	return vt.commit()


# Greedy meshing
# volume   :   Array<Vector3>   :   Array of grid positions representing volume of voxels from which to buid ArrayMesh
# vt       :   VoxelTool        :   VoxelTool with which ArrayMesh will be built
# return   :   ArrayMesh        :   Greedy voxel mesh
func greed_volume(volume : Array, vt : VoxelTool = null) -> ArrayMesh:
	if not is_instance_valid(voxel_set):
		return null
	
	if not vt:
		vt = VoxelTool.new()
		vt.set_voxel_size(voxel_size)
	
	vt.begin(voxel_set, uv_map)
	
	var faces = Voxel.Faces.duplicate()
	for face in faces:
		faces[face] = []
		for position in volume:
			if get_voxel_id(position + face) == -1:
				faces[face].append(position)
	
	for face in faces:
		while not faces[face].empty():
			var bottom_right : Vector3 = faces[face].pop_front()
			var bottom_left : Vector3 = bottom_right
			var top_right : Vector3 = bottom_right
			var top_left : Vector3 = bottom_right
			var voxel : Dictionary = get_voxel(bottom_right)
			
			
			if not uv_map or Voxel.get_face_uv(voxel, face) == -Vector2.ONE:
				var width := 1
				
				while true:
					var index = faces[face].find(top_right + Voxel.Faces[face][1])
					if index > -1:
						var _voxel = get_voxel(faces[face][index])
						if Voxel.get_face_color(_voxel, face) == Voxel.get_face_color(voxel, face) and (not uv_map or Voxel.get_face_uv(_voxel, face) == -Vector2.ONE):
							width += 1
							faces[face].remove(index)
							top_right += Voxel.Faces[face][1]
							bottom_right += Voxel.Faces[face][1]
						else:
							break
					else:
						break
				
				while true:
					var index = faces[face].find(top_left + Voxel.Faces[face][0])
					if index > -1:
						var _voxel = get_voxel(faces[face][index])
						if Voxel.get_face_color(_voxel, face) == Voxel.get_face_color(voxel, face) and (not uv_map or Voxel.get_face_uv(_voxel, face) == -Vector2.ONE):
							width += 1
							faces[face].remove(index)
							top_left += Voxel.Faces[face][0]
							bottom_left += Voxel.Faces[face][0]
						else:
							break
					else:
						break
				
				while true:
					var used := []
					var current := top_right
					var index = faces[face].find(current + Voxel.Faces[face][3])
					if index > -1:
						var _voxel = get_voxel(faces[face][index])
						if Voxel.get_face_color(_voxel, face) == Voxel.get_face_color(voxel, face) and (not uv_map or Voxel.get_face_uv(_voxel, face) == -Vector2.ONE):
							current += Voxel.Faces[face][3]
							used.append(current)
							while true:
								index = faces[face].find(current + Voxel.Faces[face][0])
								if index > -1:
									_voxel = get_voxel(faces[face][index])
									if Voxel.get_face_color(_voxel, face) == Voxel.get_face_color(voxel, face) and (not uv_map or Voxel.get_face_uv(_voxel, face) == -Vector2.ONE):
										current += Voxel.Faces[face][0]
										used.append(current)
									else:
										break
								else:
									break
							if used.size() == width:
								top_right += Voxel.Faces[face][3]
								top_left += Voxel.Faces[face][3]
								for use in used:
									faces[face].erase(use)
							else:
								break
						else:
							break
					else:
						break
				
				while true:
					var used := []
					var current := bottom_right
					var index = faces[face].find(current + Voxel.Faces[face][2])
					if index > -1:
						var _voxel = get_voxel(faces[face][index])
						if Voxel.get_face_color(_voxel, face) == Voxel.get_face_color(voxel, face) and (not uv_map or Voxel.get_face_uv(_voxel, face) == -Vector2.ONE):
							current += Voxel.Faces[face][2]
							used.append(current)
							while true:
								index = faces[face].find(current + Voxel.Faces[face][0])
								if index > -1:
									_voxel = get_voxel(faces[face][index])
									if Voxel.get_face_color(_voxel, face) == Voxel.get_face_color(voxel, face) and (not uv_map or Voxel.get_face_uv(_voxel, face) == -Vector2.ONE):
										current += Voxel.Faces[face][0]
										used.append(current)
									else:
										break
								else:
									break
							if used.size() == width:
								bottom_right += Voxel.Faces[face][2]
								bottom_left += Voxel.Faces[face][2]
								for use in used:
									faces[face].erase(use)
							else:
								break
						else:
							break
					else:
						break
			
			vt.add_face(voxel,face,
					bottom_right, bottom_left, top_right, top_left)
	
	return vt.commit()


# Updates Mesh and calls on save and update_static_body if needed
# save   :   bool   :   Save voxels on update
func update_mesh() -> void:
	update_static_body()


# Sets and updates StaticMesh if demanded
func update_static_body() -> void:
	pass
