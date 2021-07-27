tool
extends VoxelImporter
# Import files as static Mesh Resource, not to be confused with VoxelObjects



## Built-In Virtual Methods
func get_visible_name() -> String:
	return "MeshOfVoxels"


func get_importer_name() -> String:
	return "VoxelCore.MeshOfVoxels"


func get_recognized_extensions() -> Array:
	return [
		"png", "jpg",
		"vox",
		#"qb",
		#"qbt",
		#"vxm",
	]


func get_resource_type() -> String:
	return "Mesh"


func get_save_extension() -> String:
	return "mesh"


func import(source_file : String, save_path : String, options : Dictionary, r_platform_variants : Array, r_gen_files : Array) -> int:
	var read := Reader.read_file(source_file)
	var error = read.get("error", FAILED)
	if error == OK:
		var voxel_mesh = VoxelMesh.new()
		voxel_mesh.voxel_set = VoxelSet.new()
		
		voxel_mesh.set_mesh_mode(options.get("mesh_mode", VoxelMesh.MeshModes.GREEDY))
		voxel_mesh.voxel_set.set_voxels(read["palette"])
		for voxel_position in read["voxels"]:
			voxel_mesh.set_voxel(voxel_position, read["voxels"][voxel_position])
		
		# voxel size
		var voxel_size = options.get("voxel_size", 0.5)
		voxel_mesh.set_voxel_size(voxel_size)
		
		# origin shift
		var origin = get_origin_offset(options)
		
		# mult the offset with 0 for axis to be kept
		var offset_mult = Vector3(
			clamp(origin.x + 1, 0, 1),
			clamp(origin.y + 1, 0, 1),
			clamp(origin.z + 1, 0, 1)
		)
		
		var offset = voxel_mesh.vec_to_center(origin)
		offset = offset * offset_mult
		
		voxel_mesh.move(offset)
		
		voxel_mesh.update_mesh()
		
		error = ResourceSaver.save(
			'%s.%s' % [save_path, get_save_extension()],
			voxel_mesh.mesh)
		
		voxel_mesh.free()
	return error
