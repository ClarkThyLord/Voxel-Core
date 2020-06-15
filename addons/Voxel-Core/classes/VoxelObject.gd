tool
extends MeshInstance



#
# VoxelObject, makeshift abstract class for all voxel visualization objects.
#



# Declarations
signal set_voxel_set(voxel_set)


var loaded_hint := false
var EditHint := false setget set_edit_hint
func set_edit_hint(edit_hint : bool, update := loaded_hint and is_inside_tree()) -> void:
	EditHint = edit_hint
	
	if update: update_mesh(false)


enum MeshModes {
	NAIVE,
	GREEDY
#	MARCHING_CUBES
#	TRANSVOXEL
}
export(MeshModes) var MeshMode := MeshModes.NAIVE setget set_voxel_mesh
func set_voxel_mesh(mesh_mode : int, update := loaded_hint and is_inside_tree()) -> void:
	MeshMode = mesh_mode
	
	if update and not EditHint: update_mesh(false)

export(bool) var UVMapping := false setget set_uv_mapping
func set_uv_mapping(uv_mapping : bool, update := loaded_hint and is_inside_tree()) -> void:
	UVMapping = uv_mapping
	
	if update: update_mesh(false)

export(bool) var EmbedStaticBody := false setget set_embed_static_body
func set_embed_static_body(embed_static_body : bool, update := loaded_hint and is_inside_tree()) -> void:
	EmbedStaticBody = embed_static_body
	
	if update: update_static_body()


export(Resource) var Voxel_Set = preload("res://addons/Voxel-Core/defaults/VoxelSet.tres") setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := loaded_hint and is_inside_tree()) -> void:
	if voxel_set is VoxelSet:
		Voxel_Set = voxel_set
		
		if update: update_mesh(false)
		emit_signal("set_voxel_set", Voxel_Set)
	elif typeof(voxel_set) == TYPE_NIL:
		set_voxel_set(preload("res://addons/Voxel-Core/defaults/VoxelSet.tres"), update)



# Core
func _save() -> void:
	pass

func _load() -> void:
	loaded_hint = true
	update_mesh(false)


#func _init() -> void: call_deferred("_load")
#func _ready() -> void: call_deferred("_load")


func set_voxel(grid : Vector3, voxel) -> void:
	match typeof(voxel):
		TYPE_INT, TYPE_DICTIONARY:
			pass
		_:
			printerr("invalid voxel set")

func set_rvoxel(grid : Vector3, voxel) -> void:
	match typeof(voxel):
		TYPE_INT, TYPE_STRING:
			voxel = Voxel_Set.get_voxel(voxel)
	set_voxel(grid, voxel)

func set_voxels(voxels : Dictionary) -> void:
	erase_voxels()
	for grid in voxels:
		set_voxel(grid, voxels[grid])

func get_voxel(grid : Vector3) -> Dictionary:
	var voxel = get_rvoxel(grid)
	match typeof(voxel):
		TYPE_INT, TYPE_STRING:
			voxel = Voxel_Set.get_voxel(voxel)
	return voxel

func get_rvoxel(grid : Vector3):
	return null

func get_voxels() -> Array:
	return []

func erase_voxel(grid : Vector3) -> void:
	pass

func erase_voxels() -> void:
	for grid in get_voxels():
		erase_voxel(grid)


func naive_volume(volume : Array, vt := VoxelTool.new()) -> ArrayMesh:
	vt.start(UVMapping, Voxel_Set)
	
	for position in volume:
		for direction in Voxel.Directions:
			if typeof(get_rvoxel(position + direction)) == TYPE_NIL:
				vt.add_face(get_voxel(position), direction, position)
	
	return vt.end()

func greed_volume(volume : Array, vt := VoxelTool.new()) -> ArrayMesh:
	vt.start(UVMapping, Voxel_Set)
	
	var growth := 0
	var p1 : Vector3
	var p2 : Vector3
	var current : Vector3
	
	var faces = Voxel.Directions.duplicate()
	for face in faces:
		faces[face] = []
		for position in volume:
			if typeof(get_rvoxel(position + face)) == TYPE_NIL:
				faces[face].append(position)
	
	for face in faces:
		while not faces[face].empty():
			var bottom_right : Vector3 = faces[face].pop_front()
			var bottom_left : Vector3 = bottom_right
			var top_right : Vector3 = bottom_right
			var top_left : Vector3 = bottom_right
			var voxel : Dictionary = get_voxel(bottom_right)
			
			
			if not (UVMapping and Voxel.get_texture_side(voxel, face) == -Vector2.ONE):
				var width := 1
				
				while true:
					var index = faces[face].find(top_left + Voxel.Directions[face][0])
					if index > -1 and Voxel.get_color_side(get_voxel(faces[face][index]), face) == Voxel.get_color_side(voxel, face):
						width += 1
						faces[face].remove(index)
						top_left += Voxel.Directions[face][0]
						bottom_left += Voxel.Directions[face][0]
					else: break
				
				while true:
					var index = faces[face].find(top_right + Voxel.Directions[face][1])
					if index > -1 and Voxel.get_color_side(get_voxel(faces[face][index]), face) == Voxel.get_color_side(voxel, face):
						width += 1
						faces[face].remove(index)
						top_right += Voxel.Directions[face][1]
						bottom_right += Voxel.Directions[face][1]
					else: break
				
				while true:
					var temp := []
					var _break = false
					var temp_1 := top_right
					var temp_2 := top_left
					var index = faces[face].find(temp_1 + Voxel.Directions[face][3])
					if index > -1 and Voxel.get_color_side(get_voxel(faces[face][index]), face) == Voxel.get_color_side(voxel, face):
						temp.append(index)
						temp_1 += Voxel.Directions[face][3]
						temp_2 += Voxel.Directions[face][3]
						while true:
							index = faces[face].find(temp_1 + Voxel.Directions[face][0])
							if index > -1 and Voxel.get_color_side(get_voxel(faces[face][index]), face) == Voxel.get_color_side(voxel, face):
								temp.append(index)
								temp_1 += Voxel.Directions[face][0]
								temp_2 += Voxel.Directions[face][0]
							else: break
						if temp.size() == width:
							top_left += Voxel.Directions[face][3]
							top_right += Voxel.Directions[face][3]
							for index in temp:
								faces[face].remove(index)
						else:
							_break = true
					else: break
					if _break: break
				
				while true:
					var temp := []
					var _break = false
					var temp_1 := bottom_right
					var temp_2 := bottom_left
					var index = faces[face].find(temp_1 + Voxel.Directions[face][2])
					if index > -1 and Voxel.get_color_side(get_voxel(faces[face][index]), face) == Voxel.get_color_side(voxel, face):
						temp.append(index)
						temp_1 += Voxel.Directions[face][2]
						temp_2 += Voxel.Directions[face][2]
						while true:
							index = faces[face].find(temp_1 + Voxel.Directions[face][0])
							if index > -1 and Voxel.get_color_side(get_voxel(faces[face][index]), face) == Voxel.get_color_side(voxel, face):
								temp.append(index)
								temp_1 += Voxel.Directions[face][0]
								temp_2 += Voxel.Directions[face][0]
							else: break
						if temp.size() == width:
							bottom_right += Voxel.Directions[face][2]
							bottom_left += Voxel.Directions[face][2]
							for index in temp:
								faces[face].remove(index)
						else:
							_break = true
					else: break
					if _break: break
			
			vt.add_face(
				voxel,
				face,
				bottom_right,
				bottom_left,
				top_right,
				top_left
			)
	
	return vt.end()


func update_mesh(save := true) -> void:
	if save: _save()
	update_static_body()

func update_static_body() -> void:
	pass
