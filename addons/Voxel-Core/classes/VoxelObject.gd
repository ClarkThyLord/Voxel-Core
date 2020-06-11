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


func greed_volume(volume : Array, vt := VoxelTool.new()) -> ArrayMesh:
	print('greeding')
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
#	print("faces : ", faces)
	
	for face in faces:
		while not faces[face].empty():
			p1 = faces[face].pop_front()
			p2 = p1
			current = p1
			var voxel = get_voxel(p1)
			
			while true:
				var index = faces[face].find(current + Voxel.Directions[face][1])
				if index > -1:
					p2 += Voxel.Directions[face][1]
					faces[face].remove(index)
				else: break
			
#			while true:
#				var expand = false
#				var index = faces[face].find(current + Voxel.Directions[face][3])
#				if index > -1:
#					while true:
#						var index = faces[face].find(current + Voxel.Directions[face][1])
#						if index > -1:
#							p2.x += 1
#							faces[face].remove(index)
#						else: break
#				else: break
			
#			for direction in Voxel.Directions[face]:
#				var index = faces[face].find(current + direction)
#				if index > -1:
#					pass
#				if direction > Vector3.ZERO:
#					p1 += direction
#				else:
#					p2 += direction
			
			vt.add_face(
				voxel,
				face,
				p2,
				Vector3(
					p1.x,
					p2.y,
					p1.z
				),
				Vector3(
					p2.x,
					p1.y,
					p2.z
				),
				p1
			)
	
	print('greeded')
#	var face
#	var voxel
#	var bottom_right : Vector3
#	var bottom_left : Vector3
#	var top_right : Vector3
#	var top_left : Vector3
#
#	vt.start(UVMapping, Voxel_Set)
#
#	# top_right.x += 
#	# bottom_right.x += 
#
#	# bottom_left.y += 
#	# bottom_right.y += 
#
#	# top_left.x -= 
#	# bottom_left.x -= 
#
#	# top_left.y -= 
#	# top_right.y -= 
#
#	for direction in Voxel.Directions:
#		var faces := voxels.duplicate()
#		while not faces.empty():
#			voxel = get_voxel(bottom_right)
#			bottom_right = faces.pop_front()
#			bottom_left = bottom_right
#			top_right = bottom_right
#			top_left = bottom_right
#
#			if UVMapping and not Voxel.get_texture_side(voxel, direction) == -Vector2.ONE:
#				vt.add_face(voxel, direction, bottom_right)
#			else:
#				face = get_rvoxel(bottom_right)
#				if typeof(face) == TYPE_DICTIONARY:
#					face = Voxel.get_color_side(voxel, direction)
	return vt.end()


func update_mesh(save := true) -> void:
	if save: _save()
	update_static_body()

func update_static_body() -> void:
	pass
