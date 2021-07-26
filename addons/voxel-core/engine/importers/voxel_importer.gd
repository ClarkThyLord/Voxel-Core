tool
extends EditorImportPlugin
class_name VoxelImporter
# Base Class for 3d voxel importers



## Enums
enum Presets {
	DEFAULT,
	CHARACTER,
	CENTERED,
	TERRAIN,
}

enum OriginX {
	DONT_CHANGE = -10,
	CENTER = 05,
	RIGHT = 10,
	LEFT = 00,
}

enum OriginY {
	DONT_CHANGE = -10,
	CENTER = 05,
	TOP = 10,
	BOTTOM = 00,
}

enum OriginZ {
	DONT_CHANGE = -10,
	CENTER = 05,
	BACK = 10,
	FRONT = 00,
}



## Built-In Virtual Methods
func get_preset_name(preset : int) -> String:
	var preset_keys = Presets.keys()
	var preset_names = []
	
	for key in preset_keys:
		preset_names.append(key.capitalize())
	
	if preset >= preset_names.size():
		return "Unkown"
	else:
		return preset_names[preset]


func get_import_options(preset: int) -> Array:
	return get_shared_options(preset)


func get_preset_count() -> int:
	return Presets.size()


func get_option_visibility(option : String, options : Dictionary) -> bool:
	return true


## Base Class Methods
func get_shared_options(preset : int) -> Array:
	var preset_options = [
		{
			"name": "mesh_mode",
			"default_value": VoxelMesh.MeshModes.GREEDY,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(VoxelMesh.MeshModes.keys()).join(","),
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "origin_x",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(OriginX.keys()).join(","),
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "origin_y",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(OriginY.keys()).join(","),
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "origin_z",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(OriginZ.keys()).join(","),
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "voxel_size",
			"default_value": 0.5,
			"property_hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01, 1, 0.01, or_greater",
			"usage": PROPERTY_USAGE_EDITOR
		},
	]
	
	match preset:
		Presets.DEFAULT:
			pass
		
		Presets.CHARACTER:
			preset_options[1].default_value = 1
			preset_options[2].default_value = 3
			preset_options[3].default_value = 1
			preset_options[4].default_value = 0.2
		
		Presets.CENTERED:
			preset_options[1].default_value = 1
			preset_options[2].default_value = 1
			preset_options[3].default_value = 1
		
		Presets.TERRAIN:
			preset_options[0].default_value = VoxelMesh.MeshModes.NAIVE
			preset_options[1].default_value = 2
			preset_options[2].default_value = 3
			preset_options[3].default_value = 3
			preset_options[4].default_value = 1
	
	return preset_options


# From the provided options, gets the fractional center Vector
# Possible return values for each axis:
# 0.0 : shift axis to near edge
# 0.5 : centre axis
# 1.0 : shift axis to far egde
# -1.0 : no change
func get_origin_offset(options : Dictionary) -> Vector3:
	return Vector3(
		OriginX.values()[ options.get("origin_x", 0) ] / 10.0,
		OriginY.values()[ options.get("origin_y", 0) ] / 10.0,
		OriginZ.values()[ options.get("origin_z", 0) ] / 10.0
	)
