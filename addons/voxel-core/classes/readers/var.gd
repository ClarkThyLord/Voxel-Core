class_name VarReader
extends Reference
# Var file reader



## Public Methods
# Reads var file, returns it's Variant content
static func read(var_file : File) -> Dictionary:
	var result := {
		"error": OK,
		"variant": var_file.get_var(),
	}
	
	return result


static func read_file(var_path : String) -> Dictionary:
	var result := { "error": OK }
	var var_file := File.new()
	result["error"] = var_file.open(var_path, File.READ)
	if result["error"] == OK:
		result = read(var_file)
	if var_file.is_open():
		var_file.close()
	return result
