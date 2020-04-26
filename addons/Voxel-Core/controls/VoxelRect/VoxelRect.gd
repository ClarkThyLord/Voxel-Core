tool
extends ColorRect



# Refrences
onready var VoxelTextureRef := get_node("VoxelTexture")



# Declarations
var Represents := [null, null] setget set_represents
func set_represents(represents : Array) -> void: pass


export(Color) var VoxelColor := Color.white setget set_voxel_color
func set_voxel_color(voxel_color : Color) -> void:
	VoxelColor = voxel_color
	
	color = VoxelColor

export(Texture) var VoxelTexture : Texture setget set_voxel_texture
func set_voxel_texture(voxel_texture : Texture) -> void:
	VoxelTexture = voxel_texture
	
	if VoxelTextureRef:
		VoxelTextureRef.texture = VoxelTexture



# Core
func _ready():
	set_voxel_color(VoxelColor)
	set_voxel_texture(VoxelTexture)


func setup_voxel(voxel : int, voxelset : VoxelSet) -> void:
	setup_rvoxel(
		voxelset.get_voxel(voxel),
		voxelset
	)
	Represents[0] = voxel

func setup_rvoxel(voxel : Dictionary, voxelset : VoxelSet = null) -> void:
	Represents[0] = voxel
	Represents[1] = voxelset
	set_voxel_color(Voxel.get_color(voxel))
	var uv := Voxel.get_texture(voxel)
	if not uv == -Vector2.ONE and voxelset and voxelset.Tiles:
		var img_texture := ImageTexture.new()
		img_texture.create_from_image(voxelset.Tiles.get_data().get_rect(Rect2(
			Vector2.ONE * uv * voxelset.TileSize,
			Vector2.ONE * voxelset.TileSize
		)))
		set_voxel_texture(img_texture)
