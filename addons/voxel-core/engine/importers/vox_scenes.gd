tool
extends EditorImportPlugin
# Import vox files as scenes, maintaining seperate objects and offsets

enum Presets {
	DEFAULT,
	CHARACTER,
	CENTERED,
	TERRAIN
}

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


func get_preset_count() -> int:
	return Presets.size()


func get_preset_name(preset : int) -> String:
	match preset:
		Presets.DEFAULT:
			return "Default"
		Presets.CHARACTER:
			return "Character"
		Presets.CENTERED:
			return "Centered"
		Presets.TERRAIN:
			return "Terrain"
		_:
			return "Unknown"


func get_import_options(preset : int) -> Array:
	var preset_options = [
		{
			"name": "root_name",
			"default_value": "",
			"property_hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
			"hint_string": "use file name",
			"usage": PROPERTY_USAGE_EDITOR
		},
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
			"hint_string": "DONT CHANGE,CENTER,LEFT,RIGHT",
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "origin_y",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": "DONT CHANGE,CENTER,BOTTOM,TOP",
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "origin_z",
			"default_value": 0,
			"property_hint": PROPERTY_HINT_ENUM,
			"hint_string": "DONT CHANGE,CENTER,FRONT,BACK",
			"usage": PROPERTY_USAGE_EDITOR,
		},
		{
			"name": "voxel_size",
			"default_value": 0.5,
			"property_hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01,1,0.01,or_greater",
			"usage": PROPERTY_USAGE_EDITOR
		}
	]
	
	match preset:
		Presets.DEFAULT:
			pass
		Presets.CHARACTER:
			preset_options[2].default_value = 1
			preset_options[3].default_value = 2
			preset_options[4].default_value = 1
			preset_options[5].default_value = 0.2
		Presets.CENTERED:
			preset_options[2].default_value = 1
			preset_options[3].default_value = 1
			preset_options[4].default_value = 1
		Presets.TERRAIN:
			preset_options[1].default_value = VoxelMesh.MeshModes.NAIVE
			preset_options[2].default_value = 3
			preset_options[3].default_value = 2
			preset_options[4].default_value = 2
			preset_options[5].default_value = 1
	
	return preset_options


func get_option_visibility(option : String, options : Dictionary) -> bool:
	return true


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
		var origin_x := _get_frac_for_origin(options.get("origin_x", 0))
		var origin_y := _get_frac_for_origin(options.get("origin_y", 0))
		var origin_z := _get_frac_for_origin(options.get("origin_z", 0))
		
		_shift_origin(root_node, scene_aabb, Vector3(origin_x, origin_y, origin_z), voxel_size)
		
		# save scene
		var scene := PackedScene.new()
		error = scene.pack(root_node)
		
		if error == OK:
			error = ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], scene)
		
		root_node.queue_free()
	
	return error


# recursivly builds scene from dict tree
func _build_scene(tree: Dictionary, voxel_set: VoxelSet, root_node: Spatial, parent_node: Spatial, mesh_mode, voxel_size) -> AABB:
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
		voxel_mesh.move(-(tree.model.size / 2).floor())
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


# gets the fraction needed to offset the origin
# returns -1, for "no change"
func _get_frac_for_origin(option_val: int) -> float:
	match option_val:
		0: return -1.0
		1: return 0.5
		2: return 0.0
		3: return 1.0
		_: return -1.0


# Shifts a spatials origin, by moving all its children
# origin in fraction. -1 for no change
func _shift_origin(node: Spatial, node_aabb: AABB, new_origin: Vector3, voxel_size: float) -> Spatial:
	if new_origin == Vector3(-1.0, -1.0, -1.0):
		return node
	
	var offset := Vector3(0,0,0)
	
	print("combined aabb: ", node_aabb)
	
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
