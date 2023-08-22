@tool
@icon("res://addons/voxel-core/classes/voxel_set/voxel_set.svg")
class_name VoxelSet
extends Resource
## Stores a collection of voxels, textures, materials used by voxel 
## visualization objects; part of Voxel-Core.
##
## A VoxelSet is a collection of voxels, along with textures and materials that 
## can be referenced by voxels.
##
## [codeblock]
## # Create a new VoxelSet resource
## var voxel_set : VoxelSet = VoxelSet.new()
##
## # Assign the VoxelSet a texture atlas
## voxel_set.texture_atlas = preload("res://texture_atlas.png")
## 
## # Add materials to the VoxelSet
## var material_id : int = voxel_set.add_material(preload("res://material.tres"))
##
## # Create a new Voxel
## var voxel : Voxel = Voxel.new()
## # Name the Voxel
## voxel.name = "dirt grass"
## # Set the Voxel's faces color
## voxel.color = Color.BROWN
## voxel.color_top = Color.GREEN
## # Set the Voxel's faces texture uvs
## voxel.texture_uv = Vector2(0, 0)
## voxel.texture_uv_top = Vector2(1, 0)
## # Set the Voxel's material
## voxel.texture_uv = material_id
##
## # Add Voxel to VoxelSet
## var voxel_id : int = voxel_set.add_voxel(voxel)
## [/codeblock]



# Exported Variables
@export_group("Textures")
## Texture atlas containing sub-textures referenced by voxels; texture is 
## assigned to all applicable [member materials] as 
## [member BaseMaterial3D.albedo_texture].
@export
var texture_atlas : Texture2D = null :
	get = get_texture_atlas,
	set = set_texture_atlas

## The tile size, in pixels, corresponds to the encompassing rectangle of the 
## tile shape within [member texture_atlas].
@export
var tile_size : Vector2i = Vector2i(32, 32) :
	get = get_tile_size,
	set = set_tile_size

@export_group("Materials")
## Material applied to all voxels by default, can't be [code]null[/code].
@export
var default_material : BaseMaterial3D = StandardMaterial3D.new() :
	get = get_default_material,
	set = set_default_material

## Collection of materials; referenced by voxels via their index.
@export
var materials : Array[BaseMaterial3D] = [] :
	get = get_materials,
	set = set_materials



# Private Variables
# Last assigned voxel id.
var _last_id : int = -1

# Collection of [Voxel]s; where keys are voxel ids and values are [Voxel]s.
var _voxels : Dictionary = {}

var _voxel_id_to_name : Dictionary = {}

var _voxel_name_to_id : Dictionary = {}



# Built-In Virtual Methods
func _get(property : StringName):
	match str(property):
		"last_id":
			return _last_id
		"voxels":
			return _voxels
		"voxel_id_to_name":
			return _voxel_id_to_name
		"voxel_name_to_id":
			return _voxel_name_to_id
	return null


func _set(property : StringName, value):
	match str(property):
		"last_id":
			_last_id = value
			return true
		"voxels":
			_voxels = value
			return true
		"voxel_id_to_name":
			_voxel_id_to_name = value
			return true
		"voxel_name_to_id":
			_voxel_name_to_id = value
			return true
	return false


func _get_property_list():
	return [
		{
			"name": "last_id",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_STORAGE,
		},
		{
			"name": "voxels",
			"type": TYPE_DICTIONARY,
			"usage": PROPERTY_USAGE_STORAGE,
		},
		{
			"name": "voxel_id_to_name",
			"type": TYPE_DICTIONARY,
			"usage": PROPERTY_USAGE_STORAGE,
		},
		{
			"name": "voxel_name_to_id",
			"type": TYPE_DICTIONARY,
			"usage": PROPERTY_USAGE_STORAGE,
		},
	]



# Public Static Methods
static func is_valid_voxel_id(voxel_id : int) -> bool:
	return voxel_id >= 0


static func is_valid_material_index(material_index : int) -> bool:
	return material_index >= 0



# Public Methods
## This method must be called whenever the state of this resource has changed 
## (such as modification of materials).
func emit_changed() -> void:
	format_materials()
	super.emit_changed()


## Returns [member texture_atlas].
func get_texture_atlas() -> Texture2D:
	return texture_atlas


## Sets [member texture_atlas], calls on [method emit_changed] if in editor.
func set_texture_atlas(new_texture_atlas : Texture2D) -> void:
	texture_atlas = new_texture_atlas
	
	if Engine.is_editor_hint():
		emit_changed()


## Returns [member tile_size].
func get_tile_size() -> Vector2i:
	return tile_size


## Sets [member tile_size], calls on [method emit_changed] if in editor.
func set_tile_size(new_tile_size : Vector2i) -> void:
	tile_size = new_tile_size.abs()
	
	if Engine.is_editor_hint():
		emit_changed()


## Returns [member default_material].
func get_default_material() -> StandardMaterial3D:
	return default_material


## Sets [member default_material], calls on [method emit_changed] if in editor.
## NOTE: A default material must always be set.
func set_default_material(new_default_material) -> void:
	if not is_instance_valid(new_default_material):
		return
	default_material = new_default_material
	
	if Engine.is_editor_hint():
		emit_changed()


## Returns [member materials].
func get_materials() -> Array:
	return materials


## Sets [member materials], call on [method emit_changed] if in editor.
func set_materials(new_materials : Array[BaseMaterial3D]) -> void:
	materials = new_materials
	
	if Engine.is_editor_hint():
		emit_changed()


## Adds given [BaseMaterial3D] to [member materials] and returns 
## assigned material index.
func add_material(new_material : BaseMaterial3D) -> int:
	materials.append(new_material)
	return materials.size() - 1


## Returns material by index from [member materials], if invalid index
## returns [member default_material].
func get_material_by_index(material_index : int) -> BaseMaterial3D:
	if material_index >= materials.size():
		push_error("Material index `%s` out of range" % material_index)
		return default_material
	return default_material if material_index == -1 else materials[material_index]


## Replaces material at given index in [member materials] by given
## material.
func set_material_by_index(material_index : int, new_material : BaseMaterial3D) -> void:
	if material_index <= -1 or material_index >= materials.size():
		push_error("Material index `%s` out of range" % material_index)
		return
	materials[material_index] = new_material


## Removes material at given index in [member materials] and calls on 
## [method emit_changed] if in editor.
func remove_material_by_index(material_index : int) -> void:
	if material_index <= -1 or material_index >= materials.size():
		push_error("Material index `%s` out of range" % material_index)
		return
	materials.remove_at(material_index)
	
	if Engine.is_editor_hint():
		emit_changed()


## Returns [code]true[/code] if voxel with given [code]voxel_id[/code] is
## present in VoxelSet, otherwise [code]false[/code].
func has_voxel_id(voxel_id : int) -> bool:
	return _voxels.has(voxel_id)


## Returns array populated by all used voxel ids.
func get_voxel_ids() -> Array:
	return _voxels.keys()


## Returns array populated by all used [member Voxel.name](s).
func get_voxel_names() -> Array[String]:
	var names : Array[String] = []
	for voxel_id in _voxels:
		if not _voxels[voxel_id].name.is_empty():
			names.append(_voxels[voxel_id].name)
	return names


## Returns dictionary populated with keys being all used voxel ids and values 
## being all respectively used [member Voxel.name](s).
func get_voxel_ids_and_names() -> Dictionary:
	var ids_and_names : Dictionary = {}
	for voxel_id in _voxels:
		ids_and_names[voxel_id] = _voxels[voxel_id].name
	return ids_and_names


## Returns [Voxel] associated to given [code]voxel_id[/code], if not found 
## returns [code]null[/code].
func get_voxel(voxel_id : int) -> Voxel:
	return _voxels.get(voxel_id, null)


## Returns dictionary populated by all used voxels.
func get_voxels() -> Dictionary:
	return _voxels.duplicate(true)


## Adds [Voxel] to VoxelSet and returns [code]voxel_id[/code] assigned.
func add_voxel(voxel : Voxel) -> int:
	_last_id += 1
	if _voxels.has(_last_id):
		return add_voxel(voxel)
	_voxels[_last_id] = voxel
	return _last_id


## Assigns given [code]voxel[/code] to the given [code]voxel_id[/code] in
## VoxelSet.
## NOTE: Use this only if you really know what you are doing!
func set_voxel(voxel_id : int, voxel : Voxel) -> void:
	if not is_valid_voxel_id(voxel_id):
		push_error("Invalid voxel id provided '%s'" % voxel_id)
		return
	
	_voxels[voxel_id] = voxel


## Replaces all voxels used by VoxelSet.
## NOTE: Use this only if you really know what you are doing!
func set_voxels(voxels : Dictionary) -> void:
	_voxels = voxels


## Replaces voxel associated with given [code]voxel_id[/code] with the given 
## [code]voxel[/code] in VoxelSet.
func update_voxel(voxel_id : int, voxel : Voxel) -> void:
	if not _voxels.has(voxel_id):
		push_error("No voxel with voxel_id `%s` in VoxelSet" % voxel_id)
		return
	_voxels[voxel_id] = voxel


## Removes voxel with given [code]voxel_id[/code] from VoxelSet.
func remove_voxel(voxel_id : int) -> void:
	_voxels.erase(voxel_id)


## Removes all voxels from VoxelSet.
func remove_voxels() -> void:
	_voxels.clear()


func duplicate_voxel(voxel_id : int) -> int:
	if not _voxels.has(voxel_id):
		push_error("No voxel with voxel_id `%s` in VoxelSet" % voxel_id)
		return -1
	var voxel : Voxel = get_voxel(voxel_id).duplicate()
	return add_voxel(voxel)


## Returns [code]voxel_id[/code] of voxel in VoxelSet matching given 
## [code]voxel_name[/code], returns [code]-1[/code] if no voxel matching name
## is found.
func get_voxel_id_by_name(voxel_name : String) -> int:
	for voxel_id in _voxels:
		if _voxels[voxel_id].name == voxel_name:
			return voxel_id
	return -1


## Returns [Voxel] of VoxelSet matching given [code]voxel_name[/code], returns 
## [code]null[/code] if no voxel matching name is found.
func get_voxel_by_name(voxel_name : String) -> Voxel:
	for voxel_id in _voxels:
		if _voxels[voxel_id].name == voxel_name:
			return _voxels[voxel_id]
	push_error("No voxel with voxel_name `%s` in VoxelSet" % voxel_name)
	return null


## Replaces voxel associated with given [code]voxel_name[/code] with the given 
## [code]voxel[/code] in VoxelSet.
func update_voxel_by_name(voxel_name : String, voxel : Voxel) -> void:
	for voxel_id in _voxels:
		if _voxels[voxel_id].name == voxel_name:
			_voxels[voxel_id] = voxel
			return
	push_error("No voxel with voxel_name `%s` in VoxelSet" % voxel_name)


## Removes voxel that matches given [code]voxel_name[/code] in VoxelSet.
func remove_voxel_by_name(voxel_name : String) -> void:
	for voxel_id in _voxels.keys():
		if _voxels[voxel_id].name == voxel_name:
			_voxels.erase(voxel_id)
			return
	push_error("No voxel with voxel_name `%s` in VoxelSet" % voxel_name)


## Returns the number of voxels within VoxelSet.
func get_voxel_count() -> int:
	return _voxels.size()


## Helper function used to correctly format given [code]material[/code] to
## conform with VoxelSet.
func format_material(material : BaseMaterial3D) -> void:
	material.vertex_color_use_as_albedo = true
	material.albedo_texture = texture_atlas


## Helper function used to correctly format all attached [member material]s.
func format_materials() -> void:
	format_material(default_material)
	for index in materials:
		format_material(index)


func get_voxel_preview(voxel_id : int) -> Image:
	var voxel_preview : Image = Image.create(
			32, 32, true, Image.FORMAT_RGBA8)
	
	voxel_preview.fill(Color.WHITE)
	
	return voxel_preview


func get_voxel_face_preview(voxel_face : Vector3i) -> Image:
	return null
