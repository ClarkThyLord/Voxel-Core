@tool
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
func _get_preset_name(preset : int) -> String:
	var preset_keys = Presets.keys()
	var preset_names = []
	
	for key in preset_keys:
		preset_names.append(key.capitalize())
	
	if preset >= preset_names.size():
		return "Unkown"
	else:
		return preset_names[preset]


func _get_import_options(path: String, preset: int) -> Array:
	return get_shared_options(preset)

func _get_priority() -> float:
	return 0.8

func _get_preset_count() -> int:
	return Presets.size()


func _get_import_order() -> int:
	return ResourceImporter.IMPORT_ORDER_DEFAULT


func _get_option_visibility(path: String, option_name : String, options : Dictionary) -> bool:
	return true


## Base Class Methods
# Helper method since join() no longer exists on arrays
func join(arr: Array, delim: String):
	var res = ""
	for a in arr:
		res += a + delim

# All "hint_string" keys where changed to be inferred arrays because of GDscript 2
func get_shared_options(preset : int) -> Array:
	var preset_options = [
		{
			"name": "mesh_mode",
			"default_value": VoxelMesh.MeshModes.GREEDY,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(PackedStringArray(VoxelMesh.MeshModes.keys())),
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "origin_x",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(PackedStringArray(OriginX.keys())),
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "origin_y",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(PackedStringArray(OriginY.keys())),
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "origin_z",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(PackedStringArray(OriginZ.keys())),
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
