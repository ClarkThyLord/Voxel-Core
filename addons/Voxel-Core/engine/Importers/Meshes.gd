tool
extends EditorImportPlugin



# Declarations
var VoxelObject := VoxelMesh.new()



# Core
func exit() -> void:
	VoxelObject.free()


func get_visible_name() -> String:
	return "VoxelMesh"

func get_importer_name() -> String:
	return "VoxelCore.VoxelMesh"

func get_recognized_extensions() -> Array:
	return [
		"png", "jpg",
		"vox",
#		"qb",
#		"qbt",
#		"vxm"
	]

func get_resource_type() -> String:
	return "Mesh"

func get_save_extension() -> String:
	return "mesh"


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
		Presets.DEFAULT: pass
#			preset_options += []
	
	return preset_options

func get_option_visibility(option : String, options : Dictionary) -> bool:
	return true


func import(source_file : String, save_path : String, options : Dictionary, r_platform_variants : Array, r_gen_files : Array) -> int:
	var read := {}
	var error = FAILED
	
	match source_file.get_extension():
		"png", "jpg": read = ImageReader.read_file(source_file)
		"vox": read = VoxReader.read_file(source_file)
		"qb":
			continue
		"qbt":
			continue
		"vxm":
			continue
		_:
			return ERR_FILE_UNRECOGNIZED
	
	error = read.get("error", FAILED)
	if error == OK:
		VoxelObject.set_voxel_mesh(options.get("MeshMode", VoxelMesh.MeshModes.NAIVE))
		
		VoxelObject.erase_voxels()
		for voxel_position in read["voxels"]:
			VoxelObject.set_voxel(
				voxel_position,
				read["palette"][read["voxels"][voxel_position]]
			)
		
		VoxelObject.update_mesh()
		
		error = ResourceSaver.save(
			'%s.%s' % [save_path, get_save_extension()],
			VoxelObject.mesh
		)
	return error
