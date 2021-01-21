tool
extends Button
# Button representing a voxel's face



## Exported Variables
# Color of voxel
export var voxel_color := Color.black setget set_voxel_color

# Texture of voxel
export var voxel_texture : Texture = null setget set_voxel_texture

# ID of voxel to represented
export(int, -1, 100000) var voxel_id := -1 setget set_voxel_id

# Voxel's face to represent
export var voxel_face := Vector3.ZERO setget set_voxel_face

# VoxelSet being used
export(Resource) var voxel_set = null setget set_voxel_set



## Built-In Virtual Methods
func _ready():
	set_voxel_color(voxel_color)
	set_voxel_texture(voxel_texture)



## Public Methods
# Sets voxel_color
func set_voxel_color(value : Color) -> void:
	voxel_color = value
	
	$VoxelColor.color = voxel_color
	property_list_changed_notify()


# Sets voxel_texture
func set_voxel_texture(value : Texture) -> void:
	voxel_texture = value
	
	$VoxelColor/VoxelTexture.texture = voxel_texture
	property_list_changed_notify()


# Sets voxel_id, and calls on update_view by default
func set_voxel_id(value : int, update := true) -> void:
	if value < -1:
		return
	
	voxel_id = value
	
	if update:
		update_view()


# Sets voxel_face, and calls on update_view by default
func set_voxel_face(value : Vector3, update := true) -> void:
	voxel_face = value
	if update:
		update_view()


# Sets voxel_set, and calls on update_view by default
func set_voxel_set(value : Resource, update := true) -> void:
	if not (typeof(value) == TYPE_NIL or value is VoxelSet):
		printerr("Invalid Resource given expected VoxelSet")
		return
	
	voxel_set = value
	if update:
		update_view()


# Quick setup of voxel_set, voxel_id and voxel_face; calls on update_view
func setup(voxel_set : VoxelSet, voxel_id : int, voxel_face := Vector3.ZERO) -> void:
	set_voxel_set(voxel_set, false)
	set_voxel_id(voxel_id, false)
	set_voxel_face(voxel_face, false)
	update_view()


# Sets up the voxel to visualize the face of the voxel id given
func update_view() -> void:
	if typeof(voxel_set) == TYPE_NIL:
		return
	
	var voxel : Dictionary = voxel_set.get_voxel(voxel_id)
	
	hint_tooltip = str(voxel_id)
	var name = voxel_set.id_to_name(voxel_id)
	if not name.empty():
		hint_tooltip += "|" + name
	
	set_voxel_color(Voxel.get_face_color(voxel, voxel_face))
	
	if not typeof(voxel_set.tiles) == TYPE_NIL:
		var uv := Voxel.get_face_uv(voxel, voxel_face)
		if uv == -Vector2.ONE:
			set_voxel_texture(null)
		else:
			var img_texture := ImageTexture.new()
			img_texture.create_from_image(
					voxel_set.tiles.get_data().get_rect(Rect2(
							Vector2.ONE * uv * voxel_set.tile_size,
							Vector2.ONE * voxel_set.tile_size)))
			set_voxel_texture(img_texture)
