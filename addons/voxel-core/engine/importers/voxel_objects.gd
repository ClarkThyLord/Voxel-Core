tool
extends EditorImportPlugin
# Import files as VoxelObjects


## Enums
enum Presets { DEFAULT }



## Built-In Virtual Methods
func get_visible_name() -> String:
	return "VoxelObject"


func get_importer_name() -> String:
	return "VoxelCore.VoxelObject"


func get_recognized_extensions() -> Array:
	return [
		"png", "jpg",
		"vox",
		#"qb",
		#"qbt",
		#"vxm",
	]


func get_resource_type() -> String:
	return "PackedScene"


func get_save_extension() -> String:
	return "tscn"


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
			"name": "name",
			"default_value": "",
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "voxel_object",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": "DETECT,VOXEL_MESH",
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "mesh_mode",
			"default_value": VoxelMesh.MeshModes.NAIVE,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(VoxelMesh.MeshModes.keys()).join(","),
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "center",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": "NONE,CENTER,CENTER_ABOVE_AXIS",
			"usage": PROPERTY_USAGE_EDITOR,
		},
	]
	
	return preset_options


func get_option_visibility(option : String, options : Dictionary) -> bool:
	return true


func import(source_file : String, save_path : String, options : Dictionary, r_platform_variants : Array, r_gen_files : Array) -> int:
	var voxel_object
	match options.get("voxel_object", 0):
		_: voxel_object = VoxelMesh.new()
	var error = voxel_object.load_file(source_file)
	if error == OK:
		voxel_object.set_name(source_file.get_file().replace("." + source_file.get_extension(), "") if options["name"].empty() else options["name"])
		voxel_object.set_mesh_mode(options.get("mesh_mode", VoxelMesh.MeshModes.NAIVE))
		
		var center = options.get("center", 0)
		if center > 0:
			match center:
				1:
					center = Vector3(0.5, 0.5, 0.5)
				2:
					center = Vector3(0.5, 1.0, 0.5)
			voxel_object.center(center)
		
		voxel_object.update_mesh()
		
		var scene = PackedScene.new()
		error = scene.pack(voxel_object)
		if error == OK:
			error = ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], scene)
	voxel_object.free()
	return error
