tool
extends EditorImportPlugin



# Core
func get_visible_name() -> String:
	return "VoxelObject"

func get_importer_name() -> String:
	return "VoxelCore.VoxelObject"

func get_recognized_extensions() -> Array:
	return [
		"png", "jpg",
		"vox",
#		"qb",
#		"qbt",
#		"vxm"
	]

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
			"name": "VoxelSet",
			"default_value": true,
			"usage": PROPERTY_USAGE_EDITOR
		},
		{
			"name": "MeshMode",
			"default_value": VoxelMesh.MeshModes.NAIVE,
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
					"default_value": 0,
					"property_hint": PROPERTY_HINT_ENUM,
					"hint_string": "DETECT,VOXELMESH",
					"usage": PROPERTY_USAGE_EDITOR
				}
			]
	
	return preset_options

func get_option_visibility(option : String, options : Dictionary) -> bool:
	return true


func import(source_file : String, save_path : String, options : Dictionary, r_platform_variants : Array, r_gen_files : Array) -> int:
	var voxelobject
	match options.get("VoxelObject", 0):
		_: voxelobject = VoxelMesh.new()
	var error = voxelobject.load_file(source_file)
	if error == OK:
		voxelobject.set_name(source_file.get_file().replace("." + source_file.get_extension(), "") if options["Name"].empty() else options["Name"])
		voxelobject.set_voxel_mesh(options.get("MeshMode", VoxelMesh.MeshModes.NAIVE))
		voxelobject.update_mesh()
		var scene = PackedScene.new()
		error = scene.pack(voxelobject)
		if error == OK:
			error = ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], scene)
	voxelobject.queue_free()
	return error
