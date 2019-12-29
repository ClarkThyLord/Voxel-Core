tool
extends EditorImportPlugin



# Refrences
const VoxelObject = preload('res://addons/Voxel-Core/src/VoxelObject.gd')



# Core
func get_visible_name():
	return 'VoxelObject'

func get_importer_name():
	return 'VoxelCore.Texture.VoxelObject'

func get_recognized_extensions():
	return ['png', 'jpg']

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
	var preset_options = [
		{
			'name': 'Name',
			'default_value': '',
			'usage': PROPERTY_USAGE_EDITOR
		},
		{
			'name': 'MeshType',
			'default_value': 0,
			'property_hint': PROPERTY_HINT_ENUM,
			'hint_string': PoolStringArray(VoxelMesh.MeshTypes.keys()).join(','),
			'usage': PROPERTY_USAGE_EDITOR
		},
		{
			'name': 'Center',
			'default_value': 0,
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
				'default_value': 1,
				'property_hint': PROPERTY_HINT_ENUM,
				'hint_string': 'DETECT,VOXELMESH',
				'usage': PROPERTY_USAGE_EDITOR
			}
		]
		_:
			preset_options += []
	
	return preset_options

func get_option_visibility(option, options):
	return true


func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var image := Image.new()
	var err = image.load(source_file)
	if err != OK:
		printerr("Could not load `", source_file, "`")
		return err
	
	var voxels = Voxel.image_to_voxels(image)
	if typeof(voxels) == TYPE_DICTIONARY and voxels.size() > 0:
		var voxelobject : VoxelObject
		var voxelobjecttype : int = options.get('VoxelObject', 0)
		
		if voxelobjecttype == 0:
			voxelobjecttype = 1
		
		match voxelobjecttype:
			1:
				voxelobject = VoxelMesh.new()
				print('IMPORTED ', source_file.get_file(), ' AS VoxelObject : VoxelMesh')
		
		voxelobject.set_name(options['Name'] if options['Name'] != '' else source_file.get_file().replace('.' + source_file.get_extension(), ''))
		
		if options.get('Center', 1) > 0: voxels = Voxel.center(voxels, options.get('Center', 1) == 2)
		voxelobject.set_voxels(voxels, false)
		voxelobject.set_mesh_type(options.get('MeshType', 1), false, false)
		voxelobject.update()
		
		var scene = PackedScene.new()
		if scene.pack(voxelobject) == OK:
			var result = ResourceSaver.save('%s.%s' % [save_path, get_save_extension()], scene)
			
			voxelobject.queue_free()
			return result
		else:
			voxelobject.queue_free()
			printerr('Couldn\'t save resource!')
			return FAILED
	printerr('TEXTURE EMPTY')
	return FAILED
