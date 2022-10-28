@tool
class_name Voxel
extends RefCounted
@icon("res://addons/voxel-core/classes/voxel/voxel.svg")
## Used to define individual voxel data; used by Voxel-Core.
##
## A Voxel is a simple class that's used to define individual voxel data, 
## allowing for the definition of a wide variety of voxels having their own
## names, materials, colors, tiles and etc.
##
## [codeblock]
## var voxel : Voxel = Voxel.new()
## voxel.color = Color.BROWN
## voxel.color_up = Color.GREEN
## [/codeblock]



# Constants
## Represents voxel's right face.
const FACE_RIGHT = Vector3.RIGHT

## Represents voxel's left face.
const FACE_LEFT = Vector3.LEFT

## Represents voxel's top face.
const FACE_UP = Vector3.UP

## Represents voxel's bottom face.
const FACE_DOWN = Vector3.DOWN

## Represents voxel's front face.
const FACE_FORWARD = Vector3.FORWARD

## Represents voxel's back face.
const FACE_BACK = Vector3.BACK



# Public Variables
## The lowercase name of the voxel.
var name : String = "" :
	set = set_name

## The index of the material, in refrence to [member VoxelSet.materials].
var material_index : int = -1 :
	set = set_material_index

## The color applied to all faces of the voxel by default.
var color : Color = Color.WHITE

## The color applied to the right face of the voxel, if transparent returns [member color].
var color_right : Color = Color.TRANSPARENT :
	get: return color if color_right.a == 0 else color_right

## The color applied to the left face of the voxel, if transparent returns [member color].
var color_left : Color = Color.TRANSPARENT :
	get: return color if color_left.a == 0 else color_left

## The color applied to the top face of the voxel, if transparent returns [member color].
var color_up : Color = Color.TRANSPARENT :
	get: return color if color_up.a == 0 else color_up

## The color applied to the bottom face of the voxel, if transparent returns [member color].
var color_down : Color = Color.TRANSPARENT :
	get: return color if color_down.a == 0 else color_down

## The color applied to the front face of the voxel, if transparent returns [member color].
var color_forward : Color = Color.TRANSPARENT :
	get: return color if color_forward.a == 0 else color_forward

## The color applied to the back face of the voxel, if transparent returns [member color].
var color_back : Color = Color.TRANSPARENT :
	get: return color if color_back.a == 0 else color_back

## The position of the tile applied to all faces of the voxel by default, in
## refrence to [member VoxelSet.tiles].
var tile : Vector2 = -Vector2.ONE

## The position of the tile applied to the right face of the voxel, in
## refrence to [member VoxelSet.tiles]; if negative returns [member tile].
var tile_right : Vector2 = -Vector2.ONE :
	get: return tile if tile_right == -Vector2.ONE else tile_right

## The position of the tile applied to the left face of the voxel, in
## refrence to [member VoxelSet.tiles]; if negative returns [member tile].
var tile_left : Vector2 = -Vector2.ONE :
	get: return tile if tile_left == -Vector2.ONE else tile_left

## The position of the tile applied to the top face of the voxel, in
## refrence to [member VoxelSet.tiles]; if negative returns [member tile].
var tile_up : Vector2 = -Vector2.ONE :
	get: return tile if tile_up == -Vector2.ONE else tile_up

## The position of the tile applied to the bottom face of the voxel, in
## refrence to [member VoxelSet.tiles]; if negative returns [member tile].
var tile_down : Vector2 = -Vector2.ONE :
	get: return tile if tile_down == -Vector2.ONE else tile_down

## The position of the tile applied to the front face of the voxel, in
## refrence to [member VoxelSet.tiles]; if negative returns [member tile].
var tile_forward : Vector2 = -Vector2.ONE :
	get: return tile if tile_forward == -Vector2.ONE else tile_forward

## The position of the tile applied to the back face of the voxel, in
## refrence to [member VoxelSet.tiles]; if negative returns [member tile].
var tile_back : Vector2 = -Vector2.ONE :
	get: return tile if tile_back == -Vector2.ONE else tile_back



# Built-In Virtual Methods
func _to_string() -> String:
	return str({
		"name": name,
		"material_index": material_index,
		
		"color": color,
		"color_right": color_right,
		"color_left": color_left,
		"color_up": color_up,
		"color_down": color_down,
		"color_forward": color_forward,
		"color_back": color_back,
		
		"tile": tile,
		"tile_right": tile_right,
		"tile_left": tile_left,
		"tile_up": tile_up,
		"tile_down": tile_down,
		"tile_forward": tile_forward,
		"tile_back": tile_back,
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


## Set [member material_index]
func set_material_index(new_material_index : int) -> void:
	material_index = clamp(new_material_index, -1, 1024)


## Returns true if voxel [member color] is not transparent.
func has_color() -> bool:
	return color.a > 0


## Returns [member color] applied to all faces of the voxel by default.
func get_color() -> Color:
	return color


## Sets [member color] applied to all faces of the voxel by default.
func set_color(new_color : Color) -> void:
	color = new_color


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
	printerr("Error: Bad argument `%s` isn't a valid voxel face" % face)
	return has_color()


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
	printerr("Error: Bad argument `%s` isn't a valid voxel face" % face)
	return get_color()


## Sets color applied to the [code]face[/code] of the voxel.
func set_face_color(face : Vector3, new_color : Color) -> void:
	match face:
		FACE_RIGHT:
			color_right = new_color
		FACE_LEFT:
			color_left = new_color
		FACE_UP:
			color_up = new_color
		FACE_DOWN:
			color_down = new_color
		FACE_FORWARD:
			color_forward = new_color
		FACE_BACK:
			color_back = new_color
	printerr("Error: Bad argument `%s` isn't a valid voxel face" % face)


## Returns true if voxel has a defined tile.
func has_tile() -> bool:
	return tile != Vector2.ONE


## Returns position of the tile applied to all faces of the voxel by default.
func get_tile() -> Vector2:
	return tile


## Sets position of the tile applied to all faces of the voxel by default.
func set_tile(new_tile : Vector2) -> void:
	tile = new_tile


## Returns true if voxel [code]face[/code] has a defined tile.
func has_face_tile(face : Vector3) -> bool:
	match face:
		FACE_RIGHT:
			return tile_right != -Vector2.ONE
		FACE_LEFT:
			return tile_left != -Vector2.ONE
		FACE_UP:
			return tile_up != -Vector2.ONE
		FACE_DOWN:
			return tile_down != -Vector2.ONE
		FACE_FORWARD:
			return tile_forward != -Vector2.ONE
		FACE_BACK:
			return tile_back != -Vector2.ONE
	printerr("Error: Bad argument `%s` isn't a valid voxel face" % face)
	return has_tile()


## Returns the position of the tile applied to the [code]face[/code] of the
## voxel, if negative returns [member tile].
func get_face_tile(face : Vector3) -> Vector2:
	match face:
		FACE_RIGHT:
			return tile_right
		FACE_LEFT:
			return tile_left
		FACE_UP:
			return tile_up
		FACE_DOWN:
			return tile_down
		FACE_FORWARD:
			return tile_forward
		FACE_BACK:
			return tile_back
	printerr("Error: Bad argument `%s` isn't a valid voxel face" % face)
	return get_tile()


## Sets the position of the tile applied to the [code]face[/code] of the voxel.
func set_face_tile(face : Vector3, new_tile : Vector2) -> void:
	match face:
		FACE_RIGHT:
			tile_right = new_tile
		FACE_LEFT:
			tile_left = new_tile
		FACE_UP:
			tile_up = new_tile
		FACE_DOWN:
			tile_down = new_tile
		FACE_FORWARD:
			tile_forward = new_tile
		FACE_BACK:
			tile_back = new_tile
	printerr("Error: Bad argument `%s` isn't a valid voxel face" % face)


## Duplicates the voxel, returning a new voxel.
func duplicate() -> Voxel:
	var voxel : Voxel = Voxel.new()
	voxel.name = name
	voxel.material_index = material_index
	
	voxel.color = color
	voxel.color_right = color_right
	voxel.color_left = color_left
	voxel.color_up = color_up
	voxel.color_down = color_down
	voxel.color_forward = color_forward
	voxel.color_back = color_back
	
	voxel.tile = tile
	voxel.tile_right = tile_right
	voxel.tile_left = tile_left
	voxel.tile_up = tile_up
	voxel.tile_down = tile_down
	voxel.tile_forward = tile_forward
	voxel.tile_back = tile_back
	return voxel
