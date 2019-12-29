tool
extends EditorImportPlugin



# Core
func get_visible_name():
	return 'Mesh'

func get_importer_name():
	return 'VoxelCore.Texture.Mesh'

func get_recognized_extensions():
	return ['png', 'jpg']

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
				},
				{
					'name': 'Center',
					'default_value': 0,
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
	var image := Image.new()
	var err = image.load(source_file)
	if err != OK:
		printerr("Could not load `", source_file, "`")
		return err
	
	var voxels = Voxel.image_to_voxels(image)
	if typeof(voxels) == TYPE_DICTIONARY and voxels.size() > 0:
		print('IMPORTED ', source_file.get_file(), ' AS Mesh')
		
		var voxelmesh := VoxelMesh.new()
		if options.get('Center', 1) > 0: voxels = Voxel.center(voxels, options.get('Center', 1) == 2)
		voxelmesh.set_voxels(voxels, false)
		voxelmesh.set_mesh_type(options.get('MeshType', 1), false, false)
		voxelmesh.update()
		
		var result = ResourceSaver.save('%s.%s' % [save_path, get_save_extension()], voxelmesh.mesh)
		
		voxelmesh.queue_free()
		return result
	printerr('TEXTURE EMPTY')
	return FAILED
