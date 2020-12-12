tool
extends Button



# Declarations
export var VoxelColor := Color.black setget set_voxel_color
func set_voxel_color(voxel_color : Color) -> void:
	VoxelColor = voxel_color
	
	$VoxelColor.color = VoxelColor
	property_list_changed_notify()

export var VoxelTexture : Texture = null setget set_voxel_texture
func set_voxel_texture(voxel_texture : Texture) -> void:
	VoxelTexture = voxel_texture
	
	$VoxelColor/VoxelTexture.texture = VoxelTexture
	property_list_changed_notify()

export var VoxelID : int setget set_voxel_id
func set_voxel_id(voxel_id : int, update := true) -> void:
	VoxelID = voxel_id
	if update: update_view()

export var VoxelFace := Vector3.ZERO setget set_voxel_face
func set_voxel_face(voxel_face : Vector3, update := true) -> void:
	VoxelFace = voxel_face
	if update: update_view()

export(Resource) var VoxelSetRef = null setget set_voxel_set
func set_voxel_set(voxel_set : Resource, update := true) -> void:
	if not typeof(voxel_set) == TYPE_NIL and not voxel_set is VoxelSet:
		printerr("Invalid Resource given expected VoxelSet")
		return
	
	VoxelSetRef = voxel_set
	if update: update_view()



# Core
func _ready():
	set_voxel_color(VoxelColor)
	set_voxel_texture(VoxelTexture)


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
	
	set_voxel_color(Voxel.get_color_side(voxel, face))
	
	if not typeof(VoxelSetRef.Tiles) == TYPE_NIL:
		var uv := Voxel.get_texture_side(voxel, face)
		if uv == -Vector2.ONE:
			set_voxel_texture(null)
		else:
			var img_texture := ImageTexture.new()
			img_texture.create_from_image(VoxelSetRef.Tiles.get_data().get_rect(Rect2(
				Vector2.ONE * uv * VoxelSetRef.TileSize,
				Vector2.ONE * VoxelSetRef.TileSize
			)))
			set_voxel_texture(img_texture)
