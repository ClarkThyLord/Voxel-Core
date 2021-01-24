class_name VoxReader, "res://addons/voxel-core/assets/logos/MagicaVoxel.png"
extends Reference
# MagicaVoxel file reader



# Constants
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



# Public Methods
# Reads vox file, returns voxel content and voxel palette
static func read(vox_file : File) -> Dictionary:
	var result := {
		"error": OK,
		"voxels": {},
		"palette": [],
	}
	
	var magic := vox_file.get_buffer(4).get_string_from_ascii()
	var magic_version := vox_file.get_32()
	if magic == "VOX " and magic_version == 150:
		var nodes := {}
		while vox_file.get_position() < vox_file.get_len():
			var chunk_name = vox_file.get_buffer(4).get_string_from_ascii()
			var chunk_size = vox_file.get_32()
			var chunk_children = vox_file.get_32()
			
			match chunk_name:
				"XYZI":
					for i in range(0, vox_file.get_32()):
						var x := vox_file.get_8()
						var z := -vox_file.get_8()
						var y := vox_file.get_8()
						result["voxels"][Vector3(
								x, y, z).floor()] = vox_file.get_8() - 1
				"RGBA":
					for i in range(0,256):
						var color := Color(
								float(vox_file.get_8() / 255.0),
								float(vox_file.get_8() / 255.0),
								float(vox_file.get_8() / 255.0),
								float(vox_file.get_8() / 255.0))
						color.a = 1.0
						result["palette"].append(color)
				_:
					vox_file.get_buffer(chunk_size)
		
		if result["palette"].empty():
			result["palette"] = magicavoxel_default_palette.duplicate()
	else:
		result["error"] = ERR_FILE_UNRECOGNIZED
	
	for index in range(result["palette"].size()):
		result["palette"][index] = Voxel.colored(result["palette"][index])
	
	return result


static func read_file(vox_path : String) -> Dictionary:
	var result := { "error": OK }
	var vox_file := File.new()
	var error = vox_file.open(vox_path, File.READ)
	if error == OK:
		result = read(vox_file)
	if vox_file.is_open():
		vox_file.close()
	return result
