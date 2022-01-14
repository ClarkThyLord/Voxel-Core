tool
extends "res://addons/voxel-core/controls/menus/menu.gd"
## Color Picker Menu Class



## Signals
signal selected_tile(tile)

signal unselected_tile(tile)



## Exported Variables
export(int, -1, 256) var selection_max := 0 setget set_selection_max

export var hovered_color := Color(1, 1, 1, 0.6) setget set_hovered_color

export var selected_color := Color.white setget set_selection_color

export var invalid_color := Color.red setget set_invalid_color

export(Resource) var voxel_set setget set_voxel_set



## OnReady Variables
onready var tiles_viewer := get_node("VBoxContainer/ScrollContainer/TilesViewer")



## Built-In Virtual Methods
func _reay() -> void:
	set_selection_max(selection_max)
	set_hovered_color(hovered_color)
	set_selection_color(selected_color)
	set_invalid_color(invalid_color)
	set_voxel_set(voxel_set)
	
	update_rect_min()


## Public Methods
func set_selection_max(value : int, update := true) -> void:
	selection_max = value
	if is_instance_valid(tiles_viewer):
		tiles_viewer.set_selection_max(value, update)


func set_hovered_color(value : Color, update := true) -> void:
	hovered_color = value
	if is_instance_valid(tiles_viewer):
		tiles_viewer.set_hovered_color(value, update)


func set_selection_color(value : Color, update := true) -> void:
	selected_color = value
	if is_instance_valid(tiles_viewer):
		tiles_viewer.set_selection_color(value, update)


func set_invalid_color(value : Color, update := true) -> void:
	invalid_color = value
	if is_instance_valid(tiles_viewer):
		tiles_viewer.set_invalid_color(value, update)


func set_voxel_set(value : Resource, update := true) -> void:
	voxel_set = value
	if is_instance_valid(tiles_viewer):
		tiles_viewer.set_voxel_set(value, update)



## Private Methods
func _on_TilesViewer_selected_tile(tile : Vector2):
	emit_signal("selected_tile", tile)


func _on_TilesViewer_unselected_tile(tile : Vector2):
	emit_signal("unselected_tile", tile)
