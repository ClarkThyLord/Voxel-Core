@tool
class_name Voxel
extends RefCounted
@icon("res://addons/voxel-core/classes/voxel/voxel.svg")
## Used to define individual voxel data used by Voxel-Core.
##
## Structure that's used to define individual voxel data, allows for the
## creation of a wide variety of voxels having their own names, materials,
## colors, textures and etc.
##
## [codeblock]
## var voxel = Voxel.new()
## voxel.color = Color.BROWN
## voxel.color_up = Color.GREEN
## [/codeblock]



# Constants
const FACE_RIGHT = Vector3.RIGHT

const FACE_LEFT = Vector3.LEFT

const FACE_UP = Vector3.UP

const FACE_DOWN = Vector3.DOWN

const FACE_FORWARD = Vector3.FORWARD

const FACE_BACK = Vector3.BACK



# Public Variables
## The index of the material, in refrence to [member VoxelSet.materials].
var material_index : int = 0 :
	set(new_material_index): material_index = clamp(new_material_index, 0, 1024)

## The color applied to all faces of the voxel by default.
var color : Color = Color.WHITE

## The color applied to the top face of the voxel, if transparent returns [member color].
var color_up : Color = Color.TRANSPARENT :
	get: return color if color_up.a == 0 else color_up

## The color applied to the bottom face of the voxel, if transparent returns [member color].
var color_down : Color = Color.TRANSPARENT :
	get: return color if color_down.a == 0 else color_down

## The color applied to the right face of the voxel, if transparent returns [member color].
var color_right : Color = Color.TRANSPARENT :
	get: return color if color_right.a == 0 else color_right

## The color applied to the left face of the voxel, if transparent returns [member color].
var color_left : Color = Color.TRANSPARENT :
	get: return color if color_left.a == 0 else color_left

## The color applied to the front face of the voxel, if transparent returns [member color].
var color_forward : Color = Color.TRANSPARENT :
	get: return color if color_forward.a == 0 else color_forward

## The color applied to the back face of the voxel, if transparent returns [member color].
var color_back : Color = Color.TRANSPARENT :
	get: return color if color_back.a == 0 else color_back

## The position of the texture applied to all faces of the voxel by default, in
## refrence to [member VoxelSet.texture].
var texture : Vector2 = -Vector2.ONE

## The position of the texture applied to the top face of the voxel, in
## refrence to [member VoxelSet.texture]; if negative returns [member texture].
var texture_up : Vector2 = -Vector2.ONE :
	get: return texture if texture_up == -Vector2.ONE else texture_up

## The position of the texture applied to the bottom face of the voxel, in
## refrence to [member VoxelSet.texture]; if negative returns [member texture].
var texture_down : Vector2 = -Vector2.ONE :
	get: return texture if texture_down == -Vector2.ONE else texture_down

## The position of the texture applied to the right face of the voxel, in
## refrence to [member VoxelSet.texture]; if negative returns [member texture].
var texture_right : Vector2 = -Vector2.ONE :
	get: return texture if texture_right == -Vector2.ONE else texture_right

## The position of the texture applied to the left face of the voxel, in
## refrence to [member VoxelSet.texture]; if negative returns [member texture].
var texture_left : Vector2 = -Vector2.ONE :
	get: return texture if texture_left == -Vector2.ONE else texture_left

## The position of the texture applied to the front face of the voxel, in
## refrence to [member VoxelSet.texture]; if negative returns [member texture].
var texture_forward : Vector2 = -Vector2.ONE :
	get: return texture if texture_forward == -Vector2.ONE else texture_forward

## The position of the texture applied to the back face of the voxel, in
## refrence to [member VoxelSet.texture]; if negative returns [member texture].
var texture_back : Vector2 = -Vector2.ONE :
	get: return texture if texture_back == -Vector2.ONE else texture_back



# Built-In Virtual Methods
func _to_string() -> String:
	return str({
		"material_index": material_index,
		
		"color": color,
		"color_up": color_up,
		"color_down": color_down,
		"color_right": color_right,
		"color_left": color_left,
		"color_forward": color_forward,
		"color_back": color_back,
		
		"texture": texture,
		"texture_up": texture_up,
		"texture_down": texture_down,
		"texture_right": texture_right,
		"texture_left": texture_left,
		"texture_forward": texture_forward,
		"texture_back": texture_back,
	})



# Public Methods
## Returns true if voxel has a defined color.
func has_color() -> bool:
	return color.a > 0


## Returns true if voxel [code]face[/code] has a defined color.
func has_face_color(face : Vector3) -> bool:
	match face:
		FACE_RIGHT:
			return color_right.a > 0
		FACE_LEFT:
			return color_left.a > 0
		FACE_UP:
			return color_up.a > 0
		FACE_DOWN:
			return color_down.a > 0
		FACE_FORWARD:
			return color_forward.a > 0
		FACE_BACK:
			return color_back.a > 0
	printerr("Error: Bad argument `%s` isn't a valid Voxel face" % face)
	return has_color()


## Returns color applied to all faces of the voxel by default.
func get_color() -> Color:
	return color


## Returns color applied to the [code]face[/code] of the voxel, if transparent returns [member color].
func get_face_color(face : Vector3) -> Color:
	match face:
		FACE_RIGHT:
			return color_right
		FACE_LEFT:
			return color_left
		FACE_UP:
			return color_up
		FACE_DOWN:
			return color_down
		FACE_FORWARD:
			return color_forward
		FACE_BACK:
			return color_back
	printerr("Error: Bad argument `%s` isn't a valid Voxel face" % face)
	return get_color()


## Returns true if voxel has a defined texture.
func has_texture() -> bool:
	return texture != Vector2.ONE


## Returns true if voxel [code]face[/code] has a defined texture.
func has_face_texture(face : Vector3) -> bool:
	match face:
		FACE_RIGHT:
			return texture_right != -Vector2.ONE
		FACE_LEFT:
			return texture_left != -Vector2.ONE
		FACE_UP:
			return texture_up != -Vector2.ONE
		FACE_DOWN:
			return texture_down != -Vector2.ONE
		FACE_FORWARD:
			return texture_forward != -Vector2.ONE
		FACE_BACK:
			return texture_back != -Vector2.ONE
	printerr("Error: Bad argument `%s` isn't a valid Voxel face" % face)
	return has_texture()


## Returns position of the texture applied to all faces of the voxel by default.
func get_texture() -> Vector2:
	return texture


## Returns the position of the texture applied to the [code]face[/code] of the
## voxel, if negative returns [member texture].
func get_face_texture(face : Vector3) -> Vector2:
	match face:
		FACE_RIGHT:
			return texture_right
		FACE_LEFT:
			return texture_left
		FACE_UP:
			return texture_up
		FACE_DOWN:
			return texture_down
		FACE_FORWARD:
			return texture_forward
		FACE_BACK:
			return texture_back
	printerr("Error: Bad argument `%s` isn't a valid Voxel face" % face)
	return get_texture()
