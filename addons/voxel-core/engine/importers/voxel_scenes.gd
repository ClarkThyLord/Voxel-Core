tool
extends VoxelImporter
# Import vox files as scenes, maintaining seperate objects and offsets



## Built-In Virtual Methods
func get_visible_name() -> String:
	return "MagicaVoxelScene"


func get_importer_name() -> String:
	return "VoxelCore.MagicaVoxelScene"


func get_recognized_extensions() -> Array:
	return ["vox"]


func get_resource_type() -> String:
	return "PackedScene"


func get_save_extension() -> String:
	return "tscn"


func get_import_options(preset : int) -> Array:
	var preset_options = [
		{
			"name": "root_name",
			"default_value": "",
			"property_hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
			"hint_string": "use file name",
			"usage": PROPERTY_USAGE_EDITOR,
		}
	]
	
	preset_options.append_array( get_shared_options(preset))
	
	return preset_options


func import(source_file : String, save_path : String, options : Dictionary, r_platform_variants : Array, r_gen_files : Array) -> int:
	# read file without merging voxels
	var read := VoxReader.read_file(source_file, false)
	var error = read.get("error", FAILED)
	
	if error == OK:
		var tree = read["tree"]
		var voxel_set = VoxelSet.new()
		voxel_set.set_voxels(read["palette"])
		
		var root_node = Spatial.new()
		var voxel_size = options.get("voxel_size", 0.5)
		
		# name root node
		var root_name = options.get("root_name", root_node.name)
		
		if root_name.validate_node_name() != "":
			root_node.name = root_name.validate_node_name() 
		elif tree.has("name") and tree.name.validate_node_name() != "":
			root_node.name =  tree.name.validate_node_name()
		else:
			root_node.name = source_file.get_file().replace("." + source_file.get_extension(), "")
		
		# build scene
		var scene_aabb := AABB()
		
		if tree.has("children"):
			for child in tree.children:
				var child_aabb = _build_scene(child, voxel_set, root_node, root_node,
					options.get("mesh_mode", VoxelMesh.MeshModes.GREEDY),
					voxel_size
				)
				
				scene_aabb = scene_aabb.merge(child_aabb)
		else:
			scene_aabb = _build_scene(tree, voxel_set, root_node, root_node,
				options.get("mesh_mode", VoxelMesh.MeshModes.GREEDY),
				voxel_size
			)
		
		# offset origin
		var origin := get_origin_offset(options)
		
		_shift_origin(root_node, scene_aabb, origin, voxel_size)
		
		# save scene
		var scene := PackedScene.new()
		error = scene.pack(root_node)
		
		if error == OK:
			error = ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], scene)
		
		root_node.queue_free()
	
	return error



## Private Methods
# recursively builds scene from dict tree
func _build_scene(tree : Dictionary, voxel_set : VoxelSet, root_node : Spatial, parent_node : Spatial, mesh_mode, voxel_size) -> AABB:
	var node: Spatial
	var combined_aabb := AABB()
	
	if tree.type == "GROUP":
		node = Spatial.new()
		node.name = "Group"
	elif tree.type == "SHAPE":
		node = MeshInstance.new()
		node.name = "Shape"
		
		var voxel_mesh = VoxelMesh.new()
		voxel_mesh.voxel_set = voxel_set
		voxel_mesh.set_mesh_mode(mesh_mode)
		voxel_mesh.set_voxel_size(voxel_size)
		
		for voxel_pos in tree.model.voxels:
			voxel_mesh.set_voxel(voxel_pos, tree.model.voxels[voxel_pos])
		
		# center voxels
		var center = tree.model.size / 2
		center = Vector3(ceil(center.x), floor(center.y), floor(center.z))
		
		voxel_mesh.move(-center)
		voxel_mesh.update_mesh()
		
		node.mesh = voxel_mesh.mesh
		
		if tree.has("name"):
			node.mesh.set_name(tree.name)
		
		node.name = "Shape"
		
		voxel_mesh.free()
	
	if tree.has("name") and not tree.name.validate_node_name() == "":
		node.name = tree.name.validate_node_name()
	
	parent_node.add_child(node)
	node.owner = root_node
	
	if tree.has("transform"):
		node.transform = tree.transform
		node.translation = node.translation * voxel_size
	
	if node is MeshInstance:
		combined_aabb = node.get_aabb()
		combined_aabb.position += node.translation
	
	if tree.has("children"):
		for child in tree.children:
			var child_aabb = _build_scene(child, voxel_set, root_node, node, mesh_mode, voxel_size)
			child_aabb.position += node.translation
			combined_aabb = combined_aabb.merge(child_aabb)
	
	return combined_aabb


func _merge_aabb(aabb_a, aabb_b) -> Dictionary:
	if not aabb_a:
		return aabb_b
	elif not aabb_b:
		return aabb_a
	
	var aabb := {
		"position": Vector3.ZERO,
		"size": Vector3.ZERO,
		"end": Vector3.ZERO
	}
	
	for i in 3:
		aabb.position[i] = min(aabb_a.position[i], aabb_b.position[i])
		aabb.end[i] = max(aabb_a.end[i], aabb_b.end[i])
		
		aabb.size[i] = aabb.end[i] - aabb.position[i]
	
	return aabb


# Shifts a spatials origin, by moving all its children
# origin in fraction. -1 for no change
func _shift_origin(node : Spatial, node_aabb : AABB, new_origin : Vector3, voxel_size : float) -> Spatial:
	if new_origin == Vector3(-1.0, -1.0, -1.0):
		return node
	
	var offset := Vector3(0,0,0)
	
	# loop each axis
	for i in 3:
		# offset along axis
		var dir = new_origin[i]
		
		if dir == -1: continue
		
		var offset_dir = lerp(
			node_aabb.position[i],
			node_aabb.end[i],
			dir
		)
		
		# set offset for axis relative to nodes global position
		offset[i] = offset_dir - node.translation[i]
	
	# move all children
	for child in node.get_children():
		child.translation -= offset
	
	return node
