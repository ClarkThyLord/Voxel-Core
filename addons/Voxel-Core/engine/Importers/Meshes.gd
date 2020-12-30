tool
extends EditorImportPlugin
# Import files as Mesh Resource, not to be confused with VoxelObjects



## Enums
enum Presets { DEFAULT }



## Built-In Virtual Methods
func get_visible_name() -> String:
	return "MeshOfVoxels"


func get_importer_name() -> String:
	return "VoxelCore.MeshOfVoxels"


func get_recognized_extensions() -> Array:
	return [
		"png", "jpg",
		"vox",
		#"qb",
		#"qbt",
		#"vxm",
	]


func get_resource_type() -> String:
	return "Mesh"


func get_save_extension() -> String:
	return "mesh"


func get_preset_count() -> int:
	return Presets.size()


func get_preset_name(preset : int) -> String:
	match preset:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"


func get_import_options(preset : int) -> Array:
	var preset_options = [
		{
			"name": "MeshMode",
			"default_value": VoxelMesh.MeshModes.GREEDY,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(VoxelMesh.MeshModes.keys()).join(","),
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "Center",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": "NONE,CENTER,CENTER_ABOVE_AXIS",
			"usage": PROPERTY_USAGE_EDITOR,
		}
	]
	
	match preset:
		Presets.DEFAULT:
			pass
	
	return preset_options


func get_option_visibility(option : String, options : Dictionary) -> bool:
	return true


func import(source_file : String, save_path : String, options : Dictionary, r_platform_variants : Array, r_gen_files : Array) -> int:
	var read := Reader.read_file(source_file)
	var error = read.get("error", FAILED)
	if error == OK:
		var voxel_obj = VoxelMesh.new()
		voxel_obj.voxel_set = VoxelSet.new()
		
		voxel_obj.set_mesh_mode(options.get("MeshMode", VoxelMesh.MeshModes.GREEDY))
		voxel_obj.voxel_set.set_voxels(read["palette"])
		for voxel_position in read["voxels"]:
			voxel_obj.set_voxel(voxel_position, read["voxels"][voxel_position])
		voxel_obj.update_mesh()
		
		error = ResourceSaver.save(
			'%s.%s' % [save_path, get_save_extension()],
			voxel_obj.mesh)
		
		voxel_obj.free()
	return error
