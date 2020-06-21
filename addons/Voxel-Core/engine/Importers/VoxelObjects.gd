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
	var data := {}
	var error = FAILED
	match source_file.get_extension():
		"vox":
			data = Vox.read(source_file)
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
			return ERR_FILE_UNRECOGNIZED
	error = data.get("error", FAILED)
	if error == OK:
		var voxelobject := VoxelMesh.new()
		voxelobject.set_name(source_file.get_file().replace("." + source_file.get_extension(), "") if options["Name"].empty() else options["Name"])
		for model in data["models"]:
			for position in model:
				voxelobject.set_voxel(position, Voxel.colored(data["palette"][model[position] - 1]))
		voxelobject.update_mesh()
		var scene = PackedScene.new()
		error = scene.pack(voxelobject)
		if error == OK:
			error = ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], scene)
		voxelobject.queue_free()
	return error
