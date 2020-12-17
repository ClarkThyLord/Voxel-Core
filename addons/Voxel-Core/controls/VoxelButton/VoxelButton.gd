tool
extends Button
# Shows the visual representation of a voxel's face



## Declarations
# Color of voxel
export var VoxelColor := Color.black setget set_voxel_color
# Sets VoxelColor
func set_voxel_color(voxel_color : Color) -> void:
	VoxelColor = voxel_color
	
	$VoxelColor.color = VoxelColor
	property_list_changed_notify()

# Texture of voxel
export var VoxelTexture : Texture = null setget set_voxel_texture
# Sets VoxelTexture
func set_voxel_texture(voxel_texture : Texture) -> void:
	VoxelTexture = voxel_texture
	
	$VoxelColor/VoxelTexture.texture = VoxelTexture
	property_list_changed_notify()

# ID of voxel to represented
export var VoxelID : int setget set_voxel_id
# Sets VoxelID, and calls on update_view by default
func set_voxel_id(voxel_id : int, update := true) -> void:
	VoxelID = voxel_id
	if update: update_view()

# Voxel's face to represent
export var VoxelFace := Vector3.ZERO setget set_voxel_face
# Sets VoxelFace, and calls on update_view by default
func set_voxel_face(voxel_face : Vector3, update := true) -> void:
	VoxelFace = voxel_face
	if update: update_view()

# VoxelSet being used
export(Resource) var VoxelSetRef = null setget set_voxel_set
# Sets VoxelSetRef, and calls on update_view by default
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if not typeof(voxel_set) == TYPE_NIL and not voxel_set is VoxelSet:
		printerr("Invalid Resource given expected VoxelSet")
		return
	
	VoxelSetRef = voxel_set
	if update: update_view()



## Core
func _ready():
	set_voxel_color(VoxelColor)
	set_voxel_texture(VoxelTexture)


# Quick setup of VoxelSetRef, VoxelID and VoxelFace; calls on update_view
func setup(voxel_set : VoxelSet, voxel_set_id : int, voxel_face := Vector3.ZERO) -> void:
	VoxelSetRef = voxel_set
	VoxelID = voxel_set_id
	VoxelFace = voxel_face
	update_view()


# Sets up the voxel to visualize the face of the voxel id given
func update_view(voxel_id := VoxelID, face := VoxelFace) -> void:
	if typeof(VoxelSetRef) == TYPE_NIL:
		printerr("VoxelSetRef is not set")
		return
	
	var voxel := {}
	voxel = VoxelSetRef.get_voxel(voxel_id)
	
	hint_tooltip = str(voxel_id)
	var name = VoxelSetRef.id_to_name(voxel_id)
	if not name.empty():
		hint_tooltip += "|" + name
	
	set_voxel_color(Voxel.get_face_color(voxel, face))
	
	if not typeof(VoxelSetRef.Tiles) == TYPE_NIL:
		var uv := Voxel.get_face_texture(voxel, face)
		if uv == -Vector2.ONE:
			set_voxel_texture(null)
		else:
			var img_texture := ImageTexture.new()
			img_texture.create_from_image(VoxelSetRef.Tiles.get_data().get_rect(Rect2(
				Vector2.ONE * uv * VoxelSetRef.TileSize,
				Vector2.ONE * VoxelSetRef.TileSize
			)))
			set_voxel_texture(img_texture)
