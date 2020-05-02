tool
extends Button



# Declarations
var Represents := [null, null] setget set_represents
func set_represents(represents : Array) -> void: pass


enum Faces {
	MAIN,
	RIGHT,
	LEFT,
	TOP,
	BOTTOM,
	FRONT,
	BACK
}
func face_to_normal(face : int) -> Vector3:
	var normal : Vector3
	match face:
		Faces.RIGHT: normal = Vector3.RIGHT
		Faces.LEFT: normal = Vector3.LEFT
		Faces.TOP: normal = Vector3.UP
		Faces.BOTTOM: normal = Vector3.DOWN
		Faces.FRONT: normal = Vector3.FORWARD
		Faces.BACK: normal = Vector3.BACK
	return normal


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


func setup_voxel(voxel, voxelset : VoxelSet, face := Faces.MAIN) -> void:
	setup_rvoxel(
		voxelset.get_voxel(voxel),
		voxelset,
		face
	)
	hint_tooltip = str(voxel)
	Represents[0] = voxel

func setup_rvoxel(voxel : Dictionary, voxelset : VoxelSet = null, face := Faces.MAIN) -> void:
	hint_tooltip = str(voxel)
	Represents[0] = voxel
	Represents[1] = voxelset
	
	var color : Color
	if face == Faces.MAIN:
		color = Voxel.get_color(voxel)
	else: color = Voxel.get_color_side(voxel, face_to_normal(face))
	set_voxel_color(color)
	
	var uv := -Vector2.ONE
	if face == Faces.MAIN:
		uv = Voxel.get_texture(voxel)
	else: uv = Voxel.get_texture_side(voxel, face_to_normal(face))
	if not uv == -Vector2.ONE and voxelset and voxelset.Tiles:
		var img_texture := ImageTexture.new()
		img_texture.create_from_image(voxelset.Tiles.get_data().get_rect(Rect2(
			Vector2.ONE * uv * voxelset.TileSize,
			Vector2.ONE * voxelset.TileSize
		)))
		set_voxel_texture(img_texture)
