tool
extends EditorImportPlugin



# Core
func get_visible_name() -> String:
	return "VoxelObject"

func get_importer_name() -> String:
	return "VoxelCore.VoxelObject"

func get_recognized_extensions() -> Array:
	return ["vox", "qb", "qbt", "png", "vxm", "jpg"]

func get_resource_type() -> String:
	return "PackedScene"

func get_save_extension() -> String:
	return "tscn"


enum Presets { DEFAULT }

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
			"name": "Name",
			"default_value": "",
			"usage": PROPERTY_USAGE_EDITOR
		},
		{
			"name": "MeshType",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(VoxelMesh.MeshModes.keys()).join(","),
			"usage": PROPERTY_USAGE_EDITOR
		},
		{
			"name": "Center",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": "NONE,CENTER,CENTER_ABOVE_AXIS",
			"usage": PROPERTY_USAGE_EDITOR
		}
	]
	
	match preset:
		Presets.DEFAULT:
			preset_options += [
				{
					"name": "VoxelObject",
					"default_value": 1,
					"property_hint": PROPERTY_HINT_ENUM,
					"hint_string": "DETECT,VOXELMESH",
					"usage": PROPERTY_USAGE_EDITOR
				}
			]
	
	return preset_options

func get_option_visibility(option : String, options : Dictionary) -> bool:
	return true


func import(source_file : String, save_path : String, options : Dictionary, r_platform_variants : Array, r_gen_files : Array) -> int:
	match source_file.get_extension():
		"vox":
			Vox.read(source_file)
		"qb":
			continue
		"qbt":
			continue
		"png":
			continue
		"vxm":
			continue
		"jpg":
			continue
		_:
			printerr(get_importer_name(), " : ERR_FILE_UNRECOGNIZED")
			return ERR_FILE_UNRECOGNIZED
	
	
	printerr(get_importer_name(), " : FAILED")
	return FAILED
	
#	var file := File.new()
#	var error = file.open(source_file, File.READ)
#	if error != OK:
#		printerr("Could not open `", source_file, "`")
#		if file.is_open(): file.close()
#		return error
#
#	var voxels = Voxel.vox_to_voxels(file)
#	if typeof(voxels) == TYPE_DICTIONARY and voxels.size() > 0:
#		var voxelobject
#		var voxelobjecttype : int = options.get("VoxelObject", 0)
#
#		if voxelobjecttype == 0:
#			voxelobjecttype = 1
#
#		match voxelobjecttype:
#			1:
#				voxelobject = VoxelMesh.new()
#				print("IMPORTED ", source_file.get_file(), " AS VoxelObject : VoxelMesh")
#
#		voxelobject.set_name(options["Name"] if options["Name"] != "" else source_file.get_file().replace("." + source_file.get_extension(), ""))
#
#		if options.get("Center", 1) > 0: voxels = Voxel.center(voxels, options.get("Center", 1) == 2)
#		voxelobject.set_voxels(voxels, false)
#		voxelobject.set_mesh_type(options.get("MeshType", 1), false, false)
#		voxelobject.update()
#
#		var scene = PackedScene.new()
#		if scene.pack(voxelobject) == OK:
#			var result = ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], scene)
#
#			voxelobject.queue_free()
#			return result
#		else:
#			voxelobject.queue_free()
#			printerr("Couldn\"t save resource!")
#			return FAILED
#	printerr("VOX FILE EMPTY")
#	return FAILED
