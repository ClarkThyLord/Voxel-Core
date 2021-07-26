class_name GPLReader
extends Reference
# GIMP palette file reader



## Public Methods
# Reads GPL file, and returns voxel palette
static func read(gpl_file : File) -> Dictionary:
	var result := {
		"error": OK,
		"voxels": {},
		"palette": [],
	}
	
	if gpl_file.get_line() == "GIMP Palette":
		while not gpl_file.eof_reached():
			var line = gpl_file.get_line()
			if typeof(line) == TYPE_STRING and not line.empty() and (line[0].is_valid_integer() or line[0] == " "):
				var tokens = line.split("\t")
				var name = ""
				var color = tokens[0].split_floats(" ")
				color = Color(color[0] / 255, color[1] / 255, color[2] / 255)
				if tokens.size() > 1:
					name = tokens[1]
					var end = name.find("(")
					name = name.substr(0, end)
				
				if not result["palette"].has(color):
					var voxel := Voxel.colored(color)
					result["palette"].append(voxel)
					if not name.empty():
						Voxel.set_name(voxel, name.strip_edges())
	else:
		result["error"] = ERR_FILE_UNRECOGNIZED
	
	return result


static func read_file(gpl_path : String) -> Dictionary:
	var result := { "error": OK }
	var file := File.new()
	result["error"] = file.open(gpl_path, File.READ)
	if result["error"] == OK:
		result = read(file)
	if file.is_open():
		file.close()
	return result
