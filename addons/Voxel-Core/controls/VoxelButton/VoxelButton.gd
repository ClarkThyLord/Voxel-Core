tool
extends Button



# Declarations
var VoxelSetID : int setget set_voxel_set_id
func set_voxel_set_id(voxel_set_id : int) -> void:
	VoxelSetID = voxel_set_id
	update_preview(voxel_set_id)

var VoxelSetRef : VoxelSet setget set_voxel_set_ref
func set_voxel_set_ref(voxel_set : VoxelSet) -> void:
	VoxelSetRef = voxel_set
	set_voxel_set_id(VoxelSetID)


export(Color) var VoxelColor := Color.white setget set_voxel_color
func set_voxel_color(voxel_color : Color) -> void:
	VoxelColor = voxel_color
	
	$VoxelColor.color = VoxelColor

export(Texture) var VoxelTexture : Texture setget set_voxel_texture
func set_voxel_texture(voxel_texture : Texture) -> void:
	VoxelTexture = voxel_texture
	
	$VoxelColor/VoxelTexture.texture = VoxelTexture



# Core
func _ready():
	set_voxel_color(VoxelColor)
	set_voxel_texture(VoxelTexture)


func update_preview(voxel_set_id := VoxelSetID, face := Vector3.ZERO) -> void:
	if typeof(VoxelSetRef) == TYPE_NIL:
		printerr("VoxelSetRef is null")
		return
	
	var voxel := {}
	voxel = VoxelSetRef.get_voxel(voxel_set_id)
	
	hint_tooltip = str(voxel_set_id)
	var name := VoxelSetRef.id_to_name(voxel_set_id)
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
