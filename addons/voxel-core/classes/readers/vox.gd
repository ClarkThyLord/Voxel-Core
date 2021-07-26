class_name VoxReader, "res://addons/voxel-core/assets/logos/MagicaVoxel.png"
extends Reference
# MagicaVoxel file reader



## Enums
enum NodeTypes {
	TRANSFORM,
	GROUP,
	SHAPE,
}



## Constants
const MagicaVoxelPalette := [
	Color("00000000"), Color("ffffffff"), Color("ffccffff"), Color("ff99ffff"),
	Color("ff66ffff"), Color("ff33ffff"), Color("ff00ffff"), Color("ffffccff"),
	Color("ffccccff"), Color("ff99ccff"), Color("ff66ccff"), Color("ff33ccff"),
	Color("ff00ccff"), Color("ffff99ff"), Color("ffcc99ff"), Color("ff9999ff"),
	Color("ff6699ff"), Color("ff3399ff"), Color("ff0099ff"), Color("ffff66ff"),
	Color("ffcc66ff"), Color("ff9966ff"), Color("ff6666ff"), Color("ff3366ff"),
	Color("ff0066ff"), Color("ffff33ff"), Color("ffcc33ff"), Color("ff9933ff"),
	Color("ff6633ff"), Color("ff3333ff"), Color("ff0033ff"), Color("ffff00ff"),
	Color("ffcc00ff"), Color("ff9900ff"), Color("ff6600ff"), Color("ff3300ff"),
	Color("ff0000ff"), Color("ffffffcc"), Color("ffccffcc"), Color("ff99ffcc"),
	Color("ff66ffcc"), Color("ff33ffcc"), Color("ff00ffcc"), Color("ffffcccc"),
	Color("ffcccccc"), Color("ff99cccc"), Color("ff66cccc"), Color("ff33cccc"),
	Color("ff00cccc"), Color("ffff99cc"), Color("ffcc99cc"), Color("ff9999cc"),
	Color("ff6699cc"), Color("ff3399cc"), Color("ff0099cc"), Color("ffff66cc"),
	Color("ffcc66cc"), Color("ff9966cc"), Color("ff6666cc"), Color("ff3366cc"),
	Color("ff0066cc"), Color("ffff33cc"), Color("ffcc33cc"), Color("ff9933cc"),
	Color("ff6633cc"), Color("ff3333cc"), Color("ff0033cc"), Color("ffff00cc"),
	Color("ffcc00cc"), Color("ff9900cc"), Color("ff6600cc"), Color("ff3300cc"),
	Color("ff0000cc"), Color("ffffff99"), Color("ffccff99"), Color("ff99ff99"),
	Color("ff66ff99"), Color("ff33ff99"), Color("ff00ff99"), Color("ffffcc99"),
	Color("ffcccc99"), Color("ff99cc99"), Color("ff66cc99"), Color("ff33cc99"),
	Color("ff00cc99"), Color("ffff9999"), Color("ffcc9999"), Color("ff999999"),
	Color("ff669999"), Color("ff339999"), Color("ff009999"), Color("ffff6699"),
	Color("ffcc6699"), Color("ff996699"), Color("ff666699"), Color("ff336699"),
	Color("ff006699"), Color("ffff3399"), Color("ffcc3399"), Color("ff993399"),
	Color("ff663399"), Color("ff333399"), Color("ff003399"), Color("ffff0099"),
	Color("ffcc0099"), Color("ff990099"), Color("ff660099"), Color("ff330099"),
	Color("ff000099"), Color("ffffff66"), Color("ffccff66"), Color("ff99ff66"),
	Color("ff66ff66"), Color("ff33ff66"), Color("ff00ff66"), Color("ffffcc66"),
	Color("ffcccc66"), Color("ff99cc66"), Color("ff66cc66"), Color("ff33cc66"),
	Color("ff00cc66"), Color("ffff9966"), Color("ffcc9966"), Color("ff999966"),
	Color("ff669966"), Color("ff339966"), Color("ff009966"), Color("ffff6666"),
	Color("ffcc6666"), Color("ff996666"), Color("ff666666"), Color("ff336666"),
	Color("ff006666"), Color("ffff3366"), Color("ffcc3366"), Color("ff993366"),
	Color("ff663366"), Color("ff333366"), Color("ff003366"), Color("ffff0066"),
	Color("ffcc0066"), Color("ff990066"), Color("ff660066"), Color("ff330066"),
	Color("ff000066"), Color("ffffff33"), Color("ffccff33"), Color("ff99ff33"),
	Color("ff66ff33"), Color("ff33ff33"), Color("ff00ff33"), Color("ffffcc33"),
	Color("ffcccc33"), Color("ff99cc33"), Color("ff66cc33"), Color("ff33cc33"),
	Color("ff00cc33"), Color("ffff9933"), Color("ffcc9933"), Color("ff999933"),
	Color("ff669933"), Color("ff339933"), Color("ff009933"), Color("ffff6633"),
	Color("ffcc6633"), Color("ff996633"), Color("ff666633"), Color("ff336633"),
	Color("ff006633"), Color("ffff3333"), Color("ffcc3333"), Color("ff993333"),
	Color("ff663333"), Color("ff333333"), Color("ff003333"), Color("ffff0033"),
	Color("ffcc0033"), Color("ff990033"), Color("ff660033"), Color("ff330033"),
	Color("ff000033"), Color("ffffff00"), Color("ffccff00"), Color("ff99ff00"),
	Color("ff66ff00"), Color("ff33ff00"), Color("ff00ff00"), Color("ffffcc00"),
	Color("ffcccc00"), Color("ff99cc00"), Color("ff66cc00"), Color("ff33cc00"),
	Color("ff00cc00"), Color("ffff9900"), Color("ffcc9900"), Color("ff999900"),
	Color("ff669900"), Color("ff339900"), Color("ff009900"), Color("ffff6600"),
	Color("ffcc6600"), Color("ff996600"), Color("ff666600"), Color("ff336600"),
	Color("ff006600"), Color("ffff3300"), Color("ffcc3300"), Color("ff993300"),
	Color("ff663300"), Color("ff333300"), Color("ff003300"), Color("ffff0000"),
	Color("ffcc0000"), Color("ff990000"), Color("ff660000"), Color("ff330000"),
	Color("ff0000ee"), Color("ff0000dd"), Color("ff0000bb"), Color("ff0000aa"),
	Color("ff000088"), Color("ff000077"), Color("ff000055"), Color("ff000044"),
	Color("ff000022"), Color("ff000011"), Color("ff00ee00"), Color("ff00dd00"),
	Color("ff00bb00"), Color("ff00aa00"), Color("ff008800"), Color("ff007700"),
	Color("ff005500"), Color("ff004400"), Color("ff002200"), Color("ff001100"),
	Color("ffee0000"), Color("ffdd0000"), Color("ffbb0000"), Color("ffaa0000"),
	Color("ff880000"), Color("ff770000"), Color("ff550000"), Color("ff440000"),
	Color("ff220000"), Color("ff110000"), Color("ffeeeeee"), Color("ffdddddd"),
	Color("ffbbbbbb"), Color("ffaaaaaa"), Color("ff888888"), Color("ff777777"),
	Color("ff555555"), Color("ff444444"), Color("ff222222"), Color("ff111111"),
]



## Public Methods
# Reads a vox file into a dict:
# "error": OK if no Errors occured
# "tree": Dict tree structure containing the vox files scenes contents
# "palette": Vox files Palette in form of an Array of Colors
static func read(file : File) -> Dictionary:
	var result := {
		"error": OK,
		"tree": {},
		"voxels": [],
		"palette": MagicaVoxelPalette.duplicate(),
	}
	
	var header: String = file.get_buffer(4).get_string_from_ascii()
	var version := file.get_32()
	
	if not header == "VOX " or not version == 150:
		result["error"] = ERR_FILE_UNRECOGNIZED
		return result
	
	# stores all models in the file
	var _models := []
	
	# holds all info nodes in the file, indexed by node_id
	var _nodes := {}
	
	# stores the size information of a size chunk,
	# to be consumed by the next node
	var _size := Vector3()
	
	while file.get_position() < file.get_len():
		# common fields, present in all chunks
		var chunk_id: String = file.get_buffer(4).get_string_from_ascii()
		var chunk_size := file.get_32()
		var _chunk_child_size := file.get_32()
		
		match chunk_id:
			# empty "main" chunk
			"MAIN":
				pass
			
			# size info about next model
			"SIZE":
				_size.x = file.get_32()
				_size.z = file.get_32()
				_size.y = file.get_32()
			
			# model data
			"XYZI":
				var model := { 
					"size": _size,
					"voxels": {}
				}
				
				var num_voxels = file.get_32()
				
				for i in num_voxels:
					var x: = _size.x - file.get_8() - 1
					var z := file.get_8()
					var y := file.get_8()
					var id := file.get_8() - 1
					
					model.voxels[Vector3(x, y, z)] = id
				
				_models.append(model)
			
			# palette, replaces default palette
			"RGBA":
				for i in range(0, 256):
					var color := Color8(
						file.get_8(),
						file.get_8(),
						file.get_8(),
						file.get_8()
					)
					
					result.palette[i] = color
			
			# node info. contains transform, and name info
			"nTRN":
				var node_id := file.get_32()
				var info_dict := _read_vox_dict(file)
				
				# get the nodes info
				var name := ""
				var hidden := false
				
				if info_dict.has("_name"):
					name = info_dict["_name"].get_string_from_utf8()
				
				if info_dict.has("hidden"):
					var hidden_string : String = info_dict["_hidden"].get_string_from_utf8()
					hidden = true if hidden_string == "1" else false
				
				# various other info
				var child_id := file.get_32()
				var _reserved_id := file.get_32()
				var _layer_id := file.get_32()
				var _frames := file.get_32()
				
				# get the nodes transforms
				var transform_dict := _read_vox_dict(file)
								
				var rotation = null
				var translation = null
				
				if transform_dict.has("_r"):
					rotation = transform_dict["_r"]
				
				if transform_dict.has("_t"):
					translation = transform_dict["_t"]
				
				var transform = _unpack_transfom(rotation, translation)
				
				_nodes[node_id] = {
					"type": NodeTypes.TRANSFORM,
					"name": name,
					"hidden": hidden,
					"child_id": child_id,
					"transform": transform,
				}
			
			# group. can hold shapes, and/or other groups
			"nGRP":
				var node_id := file.get_32()
				
				# unused
				var _node_dict := _read_vox_dict(file)
				
				var child_count := file.get_32()
				var child_ids := PoolIntArray()
				
				child_ids.resize(child_count)
				
				for i in child_count:
					child_ids[i] = file.get_32()
				
				_nodes[node_id] = {
					"type": NodeTypes.GROUP,
					"child_ids": child_ids
				}
			
			# shape. instance of a model
			"nSHP":
				var node_id := file.get_32()
				
				# unused
				var _node_dict := _read_vox_dict(file)
				var _model_count := file.get_32()
				
				var model_id := file.get_32()
				
				# unused
				var _model_dict := _read_vox_dict(file)
				
				_nodes[node_id] = {
					"type": NodeTypes.SHAPE,
					"model_id": model_id
				}
			
			"IMAP":
				continue
			
			"LAYR":
				continue
			
			"MATL":
				continue
			
			"MATT":
				continue
			
			"rOBJ":
				continue
			
			_:
				_skip_unimplemented(file, chunk_size)
	
	# construct node tree from parsed file
	if _nodes.size() > 0:
		result["tree"] = _make_tree_from_nodes(
				_nodes.keys().front(), _nodes, _models)
	else:
		result["tree"] = {
			"type": "SHAPE",
			"model": _models.front()
		}
	
	for i in result["palette"].size():
		result["palette"][i] = Voxel.colored(result["palette"][i])
	
	return result


static func read_file(vox_path : String, merge_voxels := true) -> Dictionary:
	var result := { "error": OK }
	var vox_file := File.new()
	
	result["error"] = vox_file.open(vox_path, File.READ)
	
	if result["error"] == OK:
		result = read(vox_file)
		
		if merge_voxels:
			result["voxels"] = _merge_voxels(result["tree"])
			result.erase("tree")
		else:
			result.erase("voxels")
	
	if vox_file.is_open():
		vox_file.close()
	
	return result



## Private Methods
# Reads a key-value dictionary from a vox file
static func _read_vox_dict(file: File) -> Dictionary:
	# Dictionary containing data read from vox file
	var dict := {}
	
	# number of key-value pairs to read from dict in file
	var pairs_to_read := file.get_32()
	
	for i in pairs_to_read:
		# size of key_string in bytes
		var key_size := file.get_32()
		var key := file.get_buffer(key_size).get_string_from_ascii()
		
		var value_size := file.get_32()
		var value := file.get_buffer(value_size)
		
		dict[key] = value
	
	return dict


static func _skip_unimplemented(file : File, chunk_size : int):
	var _val = file.get_buffer(chunk_size)


static func _unpack_transfom(rotation, translation) -> Transform:
	var rotX := Vector3(1, 0, 0)
	var rotY := Vector3(0, 1, 0)
	var rotZ := Vector3(0, 0, 1)
	
	var origin := Vector3(0, 0, 0)
	
	if rotation != null:
		# extract bits from pool array
		var rotation_bits := int(rotation.get_string_from_ascii())
		
		# a untransformed rotation matrix
		var rot_matrix := [
			Vector3(1, 0, 0),
			Vector3(0, 1, 0),
			Vector3(0, 0, 1)
		]
		
		# unpack the rotation bits
		var rot0_idx := rotation_bits & 3
		var rot1_idx := (rotation_bits >> 2) & 3
		
		var row0 = rot_matrix[rot0_idx]
		var row1 = rot_matrix[rot1_idx]
		
		# by process of elimination, find rot2
		rot_matrix.erase(row0)
		rot_matrix.erase(row1)
		
		var row2 = rot_matrix.front()
		
		# unpack signs
		if rotation_bits & (1 << 4):
			row0 = -row0
		if rotation_bits & (1 << 5):
			row1 = -row1
		if rotation_bits & (1 << 6):
			row2 = -row2
		
		# correct rotation for godot
		var eulerRot = Basis(row0, row1, row2).get_euler()
		var correctedBasis = Basis(
			Vector3(
				eulerRot.x,
				-eulerRot.z,
				-eulerRot.y
			)
		)
		
		rotX = correctedBasis.x
		rotY = correctedBasis.y
		rotZ = correctedBasis.z
	
	
	if translation != null:
		# extract string
		var translation_string: String = translation.get_string_from_ascii()
		
		var translation_array := translation_string.split_floats(" ")
		origin = Vector3(
			-translation_array[0],
			translation_array[2],
			translation_array[1]
		)
	
	return Transform(rotX, rotY, rotZ, origin)


# transforms the node dict into a tree structure,
# containing only groups and models
static func _make_tree_from_nodes(node_id: int, nodes: Dictionary, models: Array):
	var node = nodes[node_id]
	var transform_node = {}
	
	if node.type == NodeTypes.TRANSFORM and node.child_id:
		transform_node = node
		node = nodes[node.child_id]
	
	var tree_node 
	
	if transform_node:
		tree_node = {
			"type": "NONE",
			"name": transform_node["name"],
			"transform": transform_node["transform"],
		}
	else:
		tree_node = {}
	
	if node.type == NodeTypes.GROUP:
		tree_node["children"] = []
		tree_node.type = "GROUP"
		
		for id in node.child_ids:
			tree_node.children.append(_make_tree_from_nodes(
				id,
				nodes,
				models
			))
		
	elif node.type == NodeTypes.SHAPE:
		tree_node["model"] = models[node.model_id]
		tree_node.type = "SHAPE"
	
	return tree_node


# merge voxels of a previously generated tree into a single model
static func _merge_voxels(tree: Dictionary) -> Dictionary:
	var voxels := {}
	
	if tree.has("model"):
		voxels = tree.model.voxels
	
	# get all child voxels
	if tree.has("children"):
		for child in tree.children:
			# recursivly get voxels of child dicts
			var child_voxels := _merge_voxels(child)
			
			# merge voxels into own
			for key in child_voxels.keys():
				voxels[key] = child_voxels[key]
	
	# transform voxels
	if tree.has("transform"):
		var transformed_voxels := {}
		var transform: Transform = tree.transform
		
		# magica voxel positions are calculated from the models center
		# offset the transform to account for this
		if tree.has("model"):
			var center : Vector3 = tree.model.size / 2
			center = Vector3(ceil(center.x), floor(center.y), floor(center.z))
			
			transform = transform.translated(-center)
		
		for key in voxels.keys():
			# offset by 0.5 during transform, to get correct rotations
			var t_key = key + Vector3(0.5, 0.5, 0.5)
			t_key = transform.xform(t_key)
			t_key -= Vector3(0.5, 0.5, 0.5)
			
			transformed_voxels[t_key] = voxels[key]
		
		voxels = transformed_voxels
	
	return voxels
