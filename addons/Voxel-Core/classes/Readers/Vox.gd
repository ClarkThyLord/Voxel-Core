extends Reference
class_name Vox, "res://addons/Voxel-Core/assets/logos/MagicaVoxel.png"



# Declarations
class Model:
	var size : Vector3
	var voxels := {}

class nTRN:
	var node_id : int
	var attributes := {}
	var children := []
	var rotation : Basis
	var translation : Vector3
	
	
	func vox_dict(file : File) -> Dictionary:
		var dictionary := {}
		for pair in range(file.get_32()):
			dictionary[file.get_buffer(file.get_32()).get_string_from_ascii()] = file.get_buffer(file.get_32()).get_string_from_ascii()
		return dictionary
	
	
	func string_to_vector3(string: String) -> Vector3:
		var floats = string.split_floats(' ')
		if floats[0] == 0: floats[0] = 1
		if floats[1] == 0: floats[1] = 1
		if floats[2] == 0: floats[2] = 1
		return Vector3(floats[0], floats[2], -floats[1])
	
	func byte_to_basis(byte: int) -> Basis:
		var x_ind = ((byte >> 0) & 0x03)
		var y_ind = ((byte >> 2) & 0x03)
		var indexes = [0, 1, 2]
		indexes.erase(x_ind)
		indexes.erase(y_ind)
		var z_ind = indexes[0]
		var x_sign = 1 if ((byte >> 4) & 0x01) == 0 else -1
		var y_sign = 1 if ((byte >> 5) & 0x01) == 0 else -1
		var z_sign = 1 if ((byte >> 6) & 0x01) == 0 else -1
		var result = Basis()
		result.x[0] = x_sign if x_ind == 0 else 0
		result.x[1] = x_sign if x_ind == 1 else 0
		result.x[2] = x_sign if x_ind == 2 else 0
	
		result.y[0] = y_sign if y_ind == 0 else 0
		result.y[1] = y_sign if y_ind == 1 else 0
		result.y[2] = y_sign if y_ind == 2 else 0
	
		result.z[0] = z_sign if z_ind == 0 else 0
		result.z[1] = z_sign if z_ind == 1 else 0
		result.z[2] = z_sign if z_ind == 2 else 0
		return result
	
	
	func _init(file : File) -> void:
		node_id = file.get_32()
		attributes = vox_dict(file)
		children.append(file.get_32())
		file.get_buffer(8)
		for frame in range(file.get_32()):
			var frame_attributes = vox_dict(file)
			if frame_attributes.has("_t"):
				translation = string_to_vector3(frame_attributes["_t"])
			if frame_attributes.has("_r"):
				rotation = byte_to_basis(int(frame_attributes["_r"]))

class nGRP:
	var node_id : int
	var attributes := {}
	var children := []
	
	
	func vox_dict(file : File) -> Dictionary:
		var dictionary := {}
		for pair in range(file.get_32()):
			dictionary[file.get_buffer(file.get_32()).get_string_from_ascii()] = file.get_buffer(file.get_32()).get_string_from_ascii()
		return dictionary
	
	
	func _init(file : File) -> void:
		node_id = file.get_32()
		attributes = vox_dict(file)
		for child in range(file.get_32()):
			children.append(file.get_32())

class nSHP:
	var node_id : int
	var attributes := {}
	var models := []
	
	
	func vox_dict(file : File) -> Dictionary:
		var dictionary := {}
		for pair in range(file.get_32()):
			dictionary[file.get_buffer(file.get_32()).get_string_from_ascii()] = file.get_buffer(file.get_32()).get_string_from_ascii()
		return dictionary
	
	
	func _init(file : File) -> void:
		node_id = file.get_32()
		attributes = vox_dict(file)
		for model in range(file.get_32()):
			models.append(file.get_32())
			vox_dict(file)


const magicavoxel_default_palette := [
	Color("00000000"), Color("ffffffff"), Color("ffccffff"), Color("ff99ffff"), Color("ff66ffff"), Color("ff33ffff"), Color("ff00ffff"), Color("ffffccff"), Color("ffccccff"), Color("ff99ccff"), Color("ff66ccff"), Color("ff33ccff"), Color("ff00ccff"), Color("ffff99ff"), Color("ffcc99ff"), Color("ff9999ff"),
	Color("ff6699ff"), Color("ff3399ff"), Color("ff0099ff"), Color("ffff66ff"), Color("ffcc66ff"), Color("ff9966ff"), Color("ff6666ff"), Color("ff3366ff"), Color("ff0066ff"), Color("ffff33ff"), Color("ffcc33ff"), Color("ff9933ff"), Color("ff6633ff"), Color("ff3333ff"), Color("ff0033ff"), Color("ffff00ff"),
	Color("ffcc00ff"), Color("ff9900ff"), Color("ff6600ff"), Color("ff3300ff"), Color("ff0000ff"), Color("ffffffcc"), Color("ffccffcc"), Color("ff99ffcc"), Color("ff66ffcc"), Color("ff33ffcc"), Color("ff00ffcc"), Color("ffffcccc"), Color("ffcccccc"), Color("ff99cccc"), Color("ff66cccc"), Color("ff33cccc"),
	Color("ff00cccc"), Color("ffff99cc"), Color("ffcc99cc"), Color("ff9999cc"), Color("ff6699cc"), Color("ff3399cc"), Color("ff0099cc"), Color("ffff66cc"), Color("ffcc66cc"), Color("ff9966cc"), Color("ff6666cc"), Color("ff3366cc"), Color("ff0066cc"), Color("ffff33cc"), Color("ffcc33cc"), Color("ff9933cc"),
	Color("ff6633cc"), Color("ff3333cc"), Color("ff0033cc"), Color("ffff00cc"), Color("ffcc00cc"), Color("ff9900cc"), Color("ff6600cc"), Color("ff3300cc"), Color("ff0000cc"), Color("ffffff99"), Color("ffccff99"), Color("ff99ff99"), Color("ff66ff99"), Color("ff33ff99"), Color("ff00ff99"), Color("ffffcc99"),
	Color("ffcccc99"), Color("ff99cc99"), Color("ff66cc99"), Color("ff33cc99"), Color("ff00cc99"), Color("ffff9999"), Color("ffcc9999"), Color("ff999999"), Color("ff669999"), Color("ff339999"), Color("ff009999"), Color("ffff6699"), Color("ffcc6699"), Color("ff996699"), Color("ff666699"), Color("ff336699"),
	Color("ff006699"), Color("ffff3399"), Color("ffcc3399"), Color("ff993399"), Color("ff663399"), Color("ff333399"), Color("ff003399"), Color("ffff0099"), Color("ffcc0099"), Color("ff990099"), Color("ff660099"), Color("ff330099"), Color("ff000099"), Color("ffffff66"), Color("ffccff66"), Color("ff99ff66"),
	Color("ff66ff66"), Color("ff33ff66"), Color("ff00ff66"), Color("ffffcc66"), Color("ffcccc66"), Color("ff99cc66"), Color("ff66cc66"), Color("ff33cc66"), Color("ff00cc66"), Color("ffff9966"), Color("ffcc9966"), Color("ff999966"), Color("ff669966"), Color("ff339966"), Color("ff009966"), Color("ffff6666"),
	Color("ffcc6666"), Color("ff996666"), Color("ff666666"), Color("ff336666"), Color("ff006666"), Color("ffff3366"), Color("ffcc3366"), Color("ff993366"), Color("ff663366"), Color("ff333366"), Color("ff003366"), Color("ffff0066"), Color("ffcc0066"), Color("ff990066"), Color("ff660066"), Color("ff330066"),
	Color("ff000066"), Color("ffffff33"), Color("ffccff33"), Color("ff99ff33"), Color("ff66ff33"), Color("ff33ff33"), Color("ff00ff33"), Color("ffffcc33"), Color("ffcccc33"), Color("ff99cc33"), Color("ff66cc33"), Color("ff33cc33"), Color("ff00cc33"), Color("ffff9933"), Color("ffcc9933"), Color("ff999933"),
	Color("ff669933"), Color("ff339933"), Color("ff009933"), Color("ffff6633"), Color("ffcc6633"), Color("ff996633"), Color("ff666633"), Color("ff336633"), Color("ff006633"), Color("ffff3333"), Color("ffcc3333"), Color("ff993333"), Color("ff663333"), Color("ff333333"), Color("ff003333"), Color("ffff0033"),
	Color("ffcc0033"), Color("ff990033"), Color("ff660033"), Color("ff330033"), Color("ff000033"), Color("ffffff00"), Color("ffccff00"), Color("ff99ff00"), Color("ff66ff00"), Color("ff33ff00"), Color("ff00ff00"), Color("ffffcc00"), Color("ffcccc00"), Color("ff99cc00"), Color("ff66cc00"), Color("ff33cc00"),
	Color("ff00cc00"), Color("ffff9900"), Color("ffcc9900"), Color("ff999900"), Color("ff669900"), Color("ff339900"), Color("ff009900"), Color("ffff6600"), Color("ffcc6600"), Color("ff996600"), Color("ff666600"), Color("ff336600"), Color("ff006600"), Color("ffff3300"), Color("ffcc3300"), Color("ff993300"),
	Color("ff663300"), Color("ff333300"), Color("ff003300"), Color("ffff0000"), Color("ffcc0000"), Color("ff990000"), Color("ff660000"), Color("ff330000"), Color("ff0000ee"), Color("ff0000dd"), Color("ff0000bb"), Color("ff0000aa"), Color("ff000088"), Color("ff000077"), Color("ff000055"), Color("ff000044"),
	Color("ff000022"), Color("ff000011"), Color("ff00ee00"), Color("ff00dd00"), Color("ff00bb00"), Color("ff00aa00"), Color("ff008800"), Color("ff007700"), Color("ff005500"), Color("ff004400"), Color("ff002200"), Color("ff001100"), Color("ffee0000"), Color("ffdd0000"), Color("ffbb0000"), Color("ffaa0000"),
	Color("ff880000"), Color("ff770000"), Color("ff550000"), Color("ff440000"), Color("ff220000"), Color("ff110000"), Color("ffeeeeee"), Color("ffdddddd"), Color("ffbbbbbb"), Color("ffaaaaaa"), Color("ff888888"), Color("ff777777"), Color("ff555555"), Color("ff444444"), Color("ff222222"), Color("ff111111")
]


# Core
static func compile_translation(
		node := 0,
		nodes := {},
		models := [],
		rotations := [Basis()],
		translation := Vector3()
	) -> void:
	print("At node #", node, ", translation ", translation)
	if nodes[node] is nTRN:
		print('nTRN : ', nodes[node].translation, ' -> ', nodes[node].children, " <---")
		var _rotations = rotations.duplicate()
		_rotations.append(nodes[node].rotation)
		for child in nodes[node].children:
			compile_translation(
				child,
				nodes,
				models,
				_rotations,
				translation + nodes[node].translation
			)
	elif nodes[node] is nGRP:
		print('nGRP -> ', nodes[node].children)
		for child in nodes[node].children:
			compile_translation(
				child,
				nodes,
				models,
				rotations,
				translation
			)
	elif nodes[node] is nSHP:
		print('nSHP -> ', nodes[node].models, " <===")
		for model in nodes[node].models:
			var transformed_model := {}
			for position in models[model].voxels:
				var _position = position + (translation - (models[model].size / 2).floor())
				for rotation in rotations:
					_position = rotation.xform(_position)
				transformed_model[_position] = models[model].voxels[position]
			models[model] = transformed_model

static func read(file_path : String) -> Dictionary:
	var result := {
		"error": OK,
		"palette": [],
		"models": []
	}
	
	var file := File.new()
	var error = file.open(file_path, File.READ)
	if error == OK:
		var magic := file.get_buffer(4).get_string_from_ascii()
		var magic_version := file.get_32()
		if magic == "VOX " and magic_version == 150:
			var nodes := {}
			while file.get_position() < file.get_len():
				var chunk_name = file.get_buffer(4).get_string_from_ascii()
				var chunk_size = file.get_32()
				var chunk_children = file.get_32()
				
				match chunk_name:
					"SIZE":
						var x := file.get_32()
						var z := -file.get_32()
						var y := file.get_32()
						
						var model := Model.new()
						model.size = Vector3(x, y, z)
						result["models"].append(model)
					"XYZI":
						for i in range(0, file.get_32()):
							var x := file.get_8()
							var z := -file.get_8()
							var y := file.get_8()
							result["models"].back().voxels[Vector3(
								x,
								y,
								z
							).floor()] = file.get_8()
					"RGBA":
						for i in range(0,256):
							result["palette"].append(Color(
								float(file.get_8() / 255.0),
								float(file.get_8() / 255.0),
								float(file.get_8() / 255.0),
								float(file.get_8() / 255.0)
							))
					"nTRN":
						var node := nTRN.new(file)
						nodes[node.node_id] = node
					"nGRP":
						var node := nGRP.new(file)
						nodes[node.node_id] = node
					"nSHP":
						var node := nSHP.new(file)
						nodes[node.node_id] = node
					_: file.get_buffer(chunk_size)
			if nodes.empty():
				for model in range(result["models"].size()):
					result["models"][model] = result["models"][model].voxels
			else:
				compile_translation(0, nodes, result["models"])
		else:
			result["error"] = ERR_FILE_UNRECOGNIZED
	else:
		result["error"] = ERR_FILE_CANT_READ
	
	if file.is_open():
		file.close()
	if result["error"] == OK:
		if result["palette"].empty():
			result["palette"] = magicavoxel_default_palette
	
	return result
