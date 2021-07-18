tool
extends EditorImportPlugin
# Import files as VoxelObjects


## Enums
enum Presets {
	DEFAULT,
	CHARACTER,
	CENTERED,
	TERRAIN
}



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
		Presets.CHARACTER:
			return "Character"
		Presets.CENTERED:
			return "Centered"
		Presets.TERRAIN:
			return "Terrain"
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
			"name": "origin_x",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": "DONT CHANGE,CENTER,LEFT,RIGHT",
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "origin_y",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": "DONT CHANGE,CENTER,BOTTOM,TOP",
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "origin_z",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": "DONT CHANGE,CENTER,FRONT,BACK",
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "voxel_size",
			"default_value": 0.5,
			"property_hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01,1,0.01,or_greater",
			"usage": PROPERTY_USAGE_EDITOR
		}
	]
	
	match preset:
		Presets.DEFAULT:
			pass
		Presets.CHARACTER:
			preset_options[3].default_value = 1
			preset_options[4].default_value = 2
			preset_options[5].default_value = 1
			preset_options[6].default_value = 0.2
		Presets.CENTERED:
			preset_options[3].default_value = 1
			preset_options[4].default_value = 1
			preset_options[5].default_value = 1
		Presets.TERRAIN:
			preset_options[2].default_value = VoxelMesh.MeshModes.NAIVE
			preset_options[3].default_value = 3
			preset_options[4].default_value = 2
			preset_options[5].default_value = 2
			preset_options[6].default_value = 1
	
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
		
		# voxel size
		var voxel_size = options.get("voxel_size", 0.5)
		voxel_object.set_voxel_size(voxel_size)
		
		# origin shift
		var origin_x = options.get("origin_x", 0)
		var origin_y = options.get("origin_y", 0)
		var origin_z = options.get("origin_z", 0)
		
		var origin = Vector3(
			_get_frac_for_origin(origin_x),
			_get_frac_for_origin(origin_y),
			_get_frac_for_origin(origin_z)
		)
		
		# mult the offset with 0 for axis to be kept
		var offset_mult = Vector3(
			clamp(origin_x, 0, 1),
			clamp(origin_y, 0, 1),
			clamp(origin_z, 0, 1)
		)
		
		var offset = voxel_object.vec_to_center(origin)
		offset = offset * offset_mult
		
		voxel_object.move(offset)
		
		voxel_object.update_mesh()
		
		var scene = PackedScene.new()
		error = scene.pack(voxel_object)
		if error == OK:
			error = ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], scene)
	voxel_object.free()
	return error


# gets the fraction needed to offset the origin
# returns -1, for "no change"
func _get_frac_for_origin(option_val: int) -> float:
	match option_val:
		0: return -1.0
		1: return 0.5
		2: return 1.0
		3: return 0.0
		_: return -1.0
