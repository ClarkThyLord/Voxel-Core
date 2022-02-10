@tool
extends VoxelImporter
# Import files as VoxelObjects


## Built-In Virtual Methods
func _get_visible_name() -> String:
	return "VoxelObject"


func _get_importer_name() -> String:
	return "VoxelCore.VoxelObject"


func _get_recognized_extensions() -> Array:
	return [
		"png", "jpg",
		"vox",
		#"qb",
		#"qbt",
		#"vxm",
	]


func _get_resource_type() -> String:
	return "PackedScene"


func _get_save_extension() -> String:
	return "tscn"


func _get_import_options(path: String, preset : int) -> Array:
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
		}
	]
	
	preset_options.append_array(get_shared_options(preset))
	
	return preset_options


func _import(source_file : String, save_path : String, options : Dictionary, r_platform_variants : Array, r_gen_files : Array) -> int:
	var voxel_object
	match options.get("voxel_object", 0):
		_: voxel_object = VoxelMesh.new()
	var error = voxel_object.load_file(source_file)
	if error == OK:
		print("Object check 1")
		voxel_object.set_name(source_file.get_file().replace("." + source_file.get_extension(), "") if options["name"].is_empty() else options["name"])
		voxel_object.set_mesh_mode(options.get("mesh_mode", VoxelMesh.MeshModes.NAIVE))
		
		var voxel_size = options.get("voxel_size", 0.5)
		voxel_object.set_voxel_size(voxel_size)
		
		# origin shift	
		var origin = get_origin_offset(options)
		
		# mult the offset with 0 for axis to be kept
		var offset_mult = Vector3(
			clamp(origin.x + 1, 0, 1),
			clamp(origin.y + 1, 0, 1),
			clamp(origin.z + 1, 0, 1)
		)
		print("Object check 2")
		var offset = voxel_object.vec_to_center(origin)
		offset = offset * offset_mult
		
		voxel_object.move(offset)
		
		voxel_object.update_mesh()
		print("Object check3")
		var scene = PackedScene.new()
		error = scene.pack(voxel_object)
		if error == OK:
			error = ResourceSaver.save("%s.%s" % [save_path, _get_save_extension()], scene)
		print("Object check 4")
	voxel_object.free()
	return error
