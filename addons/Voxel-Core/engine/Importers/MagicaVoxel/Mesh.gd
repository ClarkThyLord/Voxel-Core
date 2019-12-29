tool
extends EditorImportPlugin



# Core
func get_visible_name():
	return 'Mesh'

func get_importer_name():
	return 'VoxelCore.MagicaVoxel.Mesh'

func get_recognized_extensions():
	return ['vox']

func get_resource_type():
	return 'Mesh'

func get_save_extension():
	return 'mesh'


enum Presets { DEFAULT }

func get_preset_count():
	return Presets.size()

func get_preset_name(preset):
	match preset:
		Presets.DEFAULT:
			return 'Default'
		_:
			return 'Unknown'

func get_import_options(preset):
	match preset:
		Presets.DEFAULT:
			return [
				{
					'name': 'MeshType',
					'default_value': 1,
					'property_hint': PROPERTY_HINT_ENUM,
					'hint_string': PoolStringArray(VoxelMesh.MeshTypes.keys()).join(','),
					'usage': PROPERTY_USAGE_EDITOR
				}
			]
		_:
			return []

func get_option_visibility(option, options):
	return true


func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var file := File.new()
	var error = file.open(source_file, File.READ)
	if error != OK:
		printerr("Could not open `", source_file, "`")
		if file.is_open(): file.close()
		return error
	
	var voxels = Voxel.vox_to_voxels(file)
	if typeof(voxels) == TYPE_DICTIONARY and voxels.size() > 0:
		print('IMPORTED ', source_file.get_file(), ' AS Mesh')
		
		var voxelmesh := VoxelMesh.new()
		voxelmesh.set_voxels(voxels, false)
		voxelmesh.set_mesh_type(options.get('MeshType', 1), false, false)
		voxelmesh.update()
		
		var result = ResourceSaver.save('%s.%s' % [save_path, get_save_extension()], voxelmesh.mesh)
		
		voxelmesh.queue_free()
		return result
	printerr('VOX FILE EMPTY')
	return FAILED
