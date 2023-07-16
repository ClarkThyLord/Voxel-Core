@tool
@icon("res://addons/voxel-core/classes/voxel/voxel.svg")
class_name Voxel
extends RefCounted
## Voxel datatype; part of Voxel-Core.
##
## A voxel represents a single sample, or data point, in a three-dimensional 
## space; that is to say, a voxel represents only a single point on a grid, and 
## not the whole grid. Voxels contain multiple pieces of customizable data,
## enabling the creation of a wide variety of voxels. In addition, as voxels 
## consist of 6 faces, this enables for data to be set on a voxel or face to 
## face basis; with each face allowing for the definition of its own data. 
## Voxels contain data such as:
## voxel name, materials, colors, textures and etc.
## [br]
## Usage, the following creates a voxel with all brown colored faces:
## [codeblock]
## var voxel : Voxel = Voxel.new()
## voxel.name = "dirt"
## voxel.color = Color.BROWN
## [/codeblock]
## [br]
## Another usage, the following creates a voxel with all brown colored faces, 
## except for the top face being green:
## [codeblock]
## var voxel : Voxel = Voxel.new()
## voxel.name = "grass dirt"
## voxel.color = Color.BROWN
## voxel.color_top = Color.GREEN
## [/codeblock]
## [br]
## [b]Note:[/b] Reference [VoxelSet]s and voxel visualization objects, such as 
## [VoxelMeshInstance3D], to find out more on how to use [Voxel]s.



# Constants
## Represents voxel's right face.
const FACE_RIGHT = Vector3i.RIGHT

## Represents voxel's left face.
const FACE_LEFT = Vector3i.LEFT

## Represents voxel's top face.
const FACE_TOP = Vector3i.UP

## Represents voxel's bottom face.
const FACE_BOTTOM = Vector3i.DOWN

## Represents voxel's front face.
const FACE_FRONT = Vector3i.FORWARD

## Represents voxel's back face.
const FACE_BACK = Vector3i.BACK

## Listing of all voxel faces and their respective perpendicular voxel faces.
const FACES = {
	FACE_RIGHT: [
		FACE_TOP,
		FACE_BOTTOM,
		FACE_FRONT,
		FACE_BACK,
	],
	FACE_LEFT: [
		FACE_TOP,
		FACE_BOTTOM,
		FACE_FRONT,
		FACE_BACK,
	],
	FACE_TOP: [
		FACE_RIGHT,
		FACE_LEFT,
		FACE_FRONT,
		FACE_BACK,
	],
	FACE_BOTTOM: [
		FACE_RIGHT,
		FACE_LEFT,
		FACE_FRONT,
		FACE_BACK,
	],
	FACE_FRONT: [
		FACE_RIGHT,
		FACE_LEFT,
		FACE_TOP,
		FACE_BOTTOM,
	],
	FACE_BACK: [
		FACE_RIGHT,
		FACE_LEFT,
		FACE_TOP,
		FACE_BOTTOM,
	],
}



# Public Variables
## The lowercase name of the voxel.
var name : String = "" :
	set = set_name

## The index of material applied to all voxel faces; index is in reference to 
## [member VoxelSet.materials].
var material_index : int = -1 :
	set = set_material_index

## The default color applied to all voxel faces.
var color : Color = Color.WHITE

## The color applied to the right face of the voxel, if transparent, returns 
## [member color].
var color_right : Color = Color.TRANSPARENT :
	get: return color if color_right.a == 0 else color_right

## The color applied to the left face of the voxel, if transparent, returns 
## [member color].
var color_left : Color = Color.TRANSPARENT :
	get: return color if color_left.a == 0 else color_left

## The color applied to the top face of the voxel, if transparent, returns 
## [member color].
var color_top : Color = Color.TRANSPARENT :
	get: return color if color_top.a == 0 else color_top

## The color applied to the bottom face of the voxel, if transparent, returns 
## [member color].
var color_bottom : Color = Color.TRANSPARENT :
	get: return color if color_bottom.a == 0 else color_bottom

## The color applied to the front face of the voxel, if transparent, returns 
## [member color].
var color_front : Color = Color.TRANSPARENT :
	get: return color if color_front.a == 0 else color_front

## The color applied to the back face of the voxel, if transparent, returns 
## [member color].
var color_back : Color = Color.TRANSPARENT :
	get: return color if color_back.a == 0 else color_back

## The default tile position of the texture applied to all voxel faces, in 
## refrence to [member VoxelSet.texture].
var texture_tile : Vector2i = -Vector2i.ONE

## The tile position of the texture applied to the right face of the voxel, 
## in refrence to [member VoxelSet.texture]; if negative, returns 
## [member texture_tile].
var texture_tile_right : Vector2i = -Vector2i.ONE :
	get: return texture_tile if texture_tile_right == -Vector2i.ONE else texture_tile_right

## The tile position of the texture applied to the left face of the voxel, 
## in refrence to [member VoxelSet.texture]; if negative, returns 
## [member texture_tile].
var texture_tile_left : Vector2i = -Vector2i.ONE :
	get: return texture_tile if texture_tile_left == -Vector2i.ONE else texture_tile_left

## The tile position of the texture applied to the top face of the voxel, 
## in refrence to [member VoxelSet.texture]; if negative, returns 
## [member texture_tile].
var texture_tile_top : Vector2i = -Vector2i.ONE :
	get: return texture_tile if texture_tile_top == -Vector2i.ONE else texture_tile_top

## The tile position of the texture applied to the bottom face of the voxel, 
## in refrence to [member VoxelSet.texture]; if negative, returns 
## [member texture_tile].
var texture_tile_bottom : Vector2i = -Vector2i.ONE :
	get: return texture_tile if texture_tile_bottom == -Vector2i.ONE else texture_tile_bottom

## The tile position of the texture applied to the front face of the voxel, 
## in refrence to [member VoxelSet.texture]; if negative, returns 
## [member texture_tile].
var texture_tile_front : Vector2i = -Vector2i.ONE :
	get: return texture_tile if texture_tile_front == -Vector2i.ONE else texture_tile_front

## The tile position of the texture applied to the back face of the voxel, 
## in refrence to [member VoxelSet.texture]; if negative, returns 
## [member texture_tile].
var texture_tile_back : Vector2i = -Vector2i.ONE :
	get: return texture_tile if texture_tile_back == -Vector2i.ONE else texture_tile_back



# Built-In Virtual Methods
func _to_string() -> String:
	return str({
		"name": name,
		
		"material_index": material_index,
		
		"color": color,
		"color_right": color_right,
		"color_left": color_left,
		"color_top": color_top,
		"color_bottom": color_bottom,
		"color_front": color_front,
		"color_back": color_back,
		
		"texture_tile": texture_tile,
		"texture_tile_right": texture_tile_right,
		"texture_tile_left": texture_tile_left,
		"texture_tile_top": texture_tile_top,
		"texture_tile_bottom": texture_tile_bottom,
		"texture_tile_front": texture_tile_front,
		"texture_tile_back": texture_tile_back,
	})



# Public Methods
## Returns [member name].
func get_name() -> String:
	return name


## Sets [member name].
func set_name(new_name : String) -> void:
	name = new_name.to_lower()


## Returns [member material_index].
func get_material_index() -> int:
	return material_index


## Sets [member material_index].
func set_material_index(new_material_index : int) -> void:
	material_index = clamp(new_material_index, -1, 1024)


## Returns [code]true[/code] if voxel's [member color] is not transparent; 
## otherwise returns [code]false[/code].
func has_color() -> bool:
	return color.a > 0


## Returns voxel's [member color] applied to all faces by default.
func get_color() -> Color:
	return color


## Sets voxel's [member color] applied to all faces by default.
func set_color(new_color : Color) -> void:
	color = new_color


## Returns [code]true[/code] if voxel's given [code]voxel_face[/code] has an 
## assigned non transparent color; otherwise returns [code]false[/code].
func has_face_color(voxel_face : Vector3i) -> bool:
	match voxel_face:
		FACE_RIGHT:
			return color_right.a > 0
		FACE_LEFT:
			return color_left.a > 0
		FACE_TOP:
			return color_top.a > 0
		FACE_BOTTOM:
			return color_bottom.a > 0
		FACE_FRONT:
			return color_front.a > 0
		FACE_BACK:
			return color_back.a > 0
	push_error("Bad argument `%s` isn't a valid voxel_face" % voxel_face)
	return has_color()


## Returns color assigned to voxel's given [code]voxel_face[/code] if it isn't 
## transparent; otherwise returns [member color].
func get_face_color(voxel_face : Vector3i) -> Color:
	match voxel_face:
		FACE_RIGHT:
			return color_right
		FACE_LEFT:
			return color_left
		FACE_TOP:
			return color_top
		FACE_BOTTOM:
			return color_bottom
		FACE_FRONT:
			return color_front
		FACE_BACK:
			return color_back
	push_error("Bad argument `%s` isn't a valid voxel_face" % voxel_face)
	return get_color()


## Sets color to voxel's given [code]voxel_face[/code].
func set_face_color(voxel_face : Vector3i, new_color : Color) -> void:
	match voxel_face:
		FACE_RIGHT:
			color_right = new_color
		FACE_LEFT:
			color_left = new_color
		FACE_TOP:
			color_top = new_color
		FACE_BOTTOM:
			color_bottom = new_color
		FACE_FRONT:
			color_front = new_color
		FACE_BACK:
			color_back = new_color
	push_error("Bad argument `%s` isn't a valid voxel_face" % voxel_face)


## Returns [code]true[/code] if voxel's [member texture_tile] is not negative; 
## otherwise returns [code]false[/code].
func has_texture_tile() -> bool:
	return texture_tile != -Vector2i.ONE


## Returns voxel's [member texture_tile] applied to all faces by default.
func get_texture_tile() -> Vector2i:
	return texture_tile


## Sets voxel's [member texture_tile] applied to all faces by default.
func set_texture(new_texture_tile : Vector2i) -> void:
	texture_tile = new_texture_tile

## Returns [code]true[/code] if voxel's given [code]voxel_face[/code] has an 
## assigned non negative texture tile; otherwise returns [code]false[/code].
func has_face_texture(voxel_face : Vector3i) -> bool:
	match voxel_face:
		FACE_RIGHT:
			return texture_tile_right != -Vector2i.ONE
		FACE_LEFT:
			return texture_tile_left != -Vector2i.ONE
		FACE_TOP:
			return texture_tile_top != -Vector2i.ONE
		FACE_BOTTOM:
			return texture_tile_bottom != -Vector2i.ONE
		FACE_FRONT:
			return texture_tile_front != -Vector2i.ONE
		FACE_BACK:
			return texture_tile_back != -Vector2i.ONE
	push_error("Bad argument `%s` isn't a valid voxel_face" % voxel_face)
	return has_texture_tile()


## Returns texture tile assigned to voxel's given [code]voxel_face[/code] if it's 
## not negative; otherwise returns [member texture_tile].
func get_face_texture_tile(voxel_face : Vector3i) -> Vector2i:
	match voxel_face:
		FACE_RIGHT:
			return texture_tile_right
		FACE_LEFT:
			return texture_tile_left
		FACE_TOP:
			return texture_tile_top
		FACE_BOTTOM:
			return texture_tile_bottom
		FACE_FRONT:
			return texture_tile_front
		FACE_BACK:
			return texture_tile_back
	push_error("Bad argument `%s` isn't a valid voxel_face" % voxel_face)
	return get_texture_tile()


## Sets texture tile to voxel's given [code]voxel_face[/code].
func set_face_texture_tile(voxel_face : Vector3i, new_texture_tile : Vector2) -> void:
	match voxel_face:
		FACE_RIGHT:
			texture_tile_right = new_texture_tile
		FACE_LEFT:
			texture_tile_left = new_texture_tile
		FACE_TOP:
			texture_tile_top = new_texture_tile
		FACE_BOTTOM:
			texture_tile_bottom = new_texture_tile
		FACE_FRONT:
			texture_tile_front = new_texture_tile
		FACE_BACK:
			texture_tile_back = new_texture_tile
	push_error("Bad argument `%s` isn't a valid voxel_face" % voxel_face)


## Duplicates the voxel, returning a new voxel.
func duplicate() -> Voxel:
	var voxel : Voxel = Voxel.new()
	
	voxel.name = name
	voxel.material_index = material_index
	
	voxel.color = color
	voxel.color_right = color_right
	voxel.color_left = color_left
	voxel.color_top = color_top
	voxel.color_bottom = color_bottom
	voxel.color_front = color_front
	voxel.color_back = color_back
	
	voxel.texture_tile = texture_tile
	voxel.texture_tile_right = texture_tile_right
	voxel.texture_tile_left = texture_tile_left
	voxel.texture_tile_top = texture_tile_top
	voxel.texture_tile_bottom = texture_tile_bottom
	voxel.texture_tile_front = texture_tile_front
	voxel.texture_tile_back = texture_tile_back
	
	return voxel
