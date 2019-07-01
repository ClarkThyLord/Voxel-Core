tool
extends EditorImportPlugin



# Core
func get_visible_name():
	return 'VoxelMesh'

func get_importer_name():
	return 'VoxelCore.Vox.Mesh'

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
					'name': 'Greedy',
					'default_value': true
				},
				{
					'name': 'Center',
					'default_value': 1,
					'property_hint': PROPERTY_HINT_ENUM,
					'hint_string': 'NONE,CENTER,CENTER_ABOVE_AXIS',
					'usage': PROPERTY_USAGE_EDITOR
				}
			]
		_:
			return []

func get_option_visibility(option, options):
	return true


func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var voxels = MagicaVoxelReader.read(source_file)
	if typeof(voxels) == TYPE_DICTIONARY:
		print('IMPORTED ' + source_file.get_file() + ' AS Mesh')
		
		var voxelmesh := VoxelMesh.new()
		
		voxelmesh.set_voxels(voxels, false, false)
		voxelmesh.set_greedy(options.get('Greedy', true), false, false)
		
		if options.get('Center', 0) > 0: voxelmesh.center({'above_axis': options.get('Center', 1) == 2})
		
		voxelmesh.update()
		
		var result = ResourceSaver.save('%s.%s' % [save_path, get_save_extension()], voxelmesh.mesh)
		
		voxelmesh.queue_free()
		
		return result
