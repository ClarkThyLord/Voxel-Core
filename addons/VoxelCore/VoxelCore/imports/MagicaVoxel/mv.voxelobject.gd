tool
extends EditorImportPlugin



# Refrences
const VoxelObject = preload('res://addons/VoxelCore/src/VoxelObject.gd')



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


enum Presets { DEFAULT, VOXELMESH, VOXELMULTIMESH }

func get_preset_count():
	return Presets.size()

func get_preset_name(preset):
	match preset:
		Presets.DEFAULT:
			return 'Default'
		Presets.VOXELMESH:
			return 'VoxelMesh'
		Presets.VOXELMULTIMESH:
			return 'VoxelMultiMesh'
		_:
			return 'Unknown'

func get_import_options(preset):
	var preset_options = [
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
	
	match preset:
		Presets.DEFAULT:
			preset_options += [
				{
					'name': 'VoxelObject',
					'default_value': 0,
					'property_hint': PROPERTY_HINT_ENUM,
					'hint_string': 'Detect,VoxelMesh,VoxelMultiMesh',
					'usage': PROPERTY_USAGE_EDITOR
				}
			]
		Presets.VOXELMESH:
			preset_options += [
				{
					'name': 'VoxelObject',
					'default_value': 1,
					'property_hint': PROPERTY_HINT_ENUM,
					'hint_string': 'Detect,VoxelMesh,VoxelMultiMesh',
					'usage': PROPERTY_USAGE_EDITOR
				}
			]
		Presets.VOXELMULTIMESH:
			preset_options += [
				{
					'name': 'VoxelObject',
					'default_value': 2,
					'property_hint': PROPERTY_HINT_ENUM,
					'hint_string': 'Detect,VoxelMesh,VoxelMultiMesh',
					'usage': PROPERTY_USAGE_EDITOR
				}
			]
		_:
			preset_options += []
	
	return preset_options

func get_option_visibility(option, options):
	return true


func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var voxels = MagicaVoxelReader.read(source_file)
	if typeof(voxels) == TYPE_DICTIONARY:
		var voxelobject : VoxelObject
		var VoxelObject_type : int = options.get('VoxelObject', 0)
		
		if VoxelObject_type == 0:
			if voxels.size() > 1000: VoxelObject_type = 2
			else: VoxelObject_type = 1
		
		match VoxelObject_type:
			1:
				VoxelObject_type = 1
				voxelobject = VoxelMesh.new()
			2: 
				VoxelObject_type = 2
				voxelobject = VoxelMultiMesh.new()
		
		print('IMPORTED ' + source_file.get_file() + ' AS VoxelObject : ' + str(Presets.keys()[VoxelObject_type]).capitalize())
		
		voxelobject.set_name(options['Name'] if options['Name'] != '' else source_file.get_file().replace('.' + source_file.get_extension(), ''))
		
		voxelobject.set_greedy(options.get('Greedy', true), false, false)
		voxelobject.set_voxels(voxels, false, false)
		
		if options.get('Center', 0) > 0: voxelobject.center({'above_axis': options.get('Center', 1) == 2})
		
		voxelobject.update()
		
		var scene = PackedScene.new()
		if scene.pack(voxelobject) == OK:
			var result = ResourceSaver.save('%s.%s' % [save_path, get_save_extension()], scene)
			
			voxelobject.queue_free()
			
			return result
		else:
			voxelobject.queue_free()
			printerr('Couldn\'t save resource!')
