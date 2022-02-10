@tool
extends EditorImportPlugin



## Enums
enum Presets { DEFAULT }



## Built-In Virtual Methods
func _get_visible_name() -> String:
	return "VoxelSet"


func _get_importer_name() -> String:
	return "VoxelCore.VoxelSet"


func _get_recognized_extensions() -> Array:
	return [
		"png", "jpg",
		"vox",
		"gpl",
	]


func _get_resource_type() -> String:
	return "Resource"


func _get_save_extension() -> String:
	return "tres"


func _get_preset_count() -> int:
	return Presets.size()


func _get_preset_name(preset : int) -> String:
	match preset:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"


func _get_import_options(preset : int) -> Array:
	var preset_options = [
		
	]
	
	return preset_options


func _get_option_visibility(option : String, options : Dictionary) -> bool:
	return true


func _import(source_file : String, save_path : String, options : Dictionary, r_platform_variants : Array, r_gen_files : Array) -> int:
	var voxel_set := VoxelSet.new()
	var error = voxel_set.load_file(source_file)
	if error == OK:
		voxel_set.request_refresh()
		error = ResourceSaver.save("%s.%s" % [save_path, _get_save_extension()], voxel_set)
	return error
