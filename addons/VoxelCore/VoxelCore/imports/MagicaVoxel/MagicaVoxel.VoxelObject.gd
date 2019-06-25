tool
extends EditorImportPlugin



# Refrences
var voxelobject = VoxelObject.new()



# Core
func get_visible_name():
	return 'VoxelObject'

func get_importer_name():
	return 'VoxelCore.Vox.VoxelObject'

func get_recognized_extensions():
	return ['vox']

func get_resource_type():
	return 'PackedScene'

func get_save_extension():
	return 'tscn'


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
					'name': 'Name',
					'default_value': '',
					'usage': PROPERTY_USAGE_EDITOR
				},
				{
					'name': 'Greedy',
					'default_value': true,
					'usage': PROPERTY_USAGE_EDITOR
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
	var result = MagicaVoxelReader.read_vox(source_file)
	if typeof(result) == TYPE_DICTIONARY:
		print('IMPORTED ' + source_file.get_file() + ' as Mesh ~ Dimensions: ' + str(result.dimensions) + ' Voxel(s): ' + str(result['voxels'].size()))
		
		voxelobject.set_name(options['Name'] if options['Name'] != '' else source_file.get_file().replace('.' + source_file.get_extension(), ''))
		
		voxelobject.set_dimensions(result['dimensions'], false ,false, false)
		voxelobject.set_voxels(result['voxels'], false, false)
		voxelobject.set_buildgreedy(options.get('Greedy', true), false, false)
		if options.get('Center', 1) > 0: voxelobject.center_voxels({ 'above_axis': options.get('Center', 1) == 1 }, false, false)
		voxelobject.update()
		
		var scene = PackedScene.new()
		if scene.pack(voxelobject) == OK:
			var full_path = '%s.%s' % [save_path, get_save_extension()]
			return ResourceSaver.save(full_path, scene)
		else: printerr('Couldn\'t save resource!')
