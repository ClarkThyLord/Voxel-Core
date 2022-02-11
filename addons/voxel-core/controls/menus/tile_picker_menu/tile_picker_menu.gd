@tool
extends "res://addons/voxel-core/controls/menus/menu.gd"
## Color Picker Menu Class



## Signals
signal tile_selected(tile)

signal tile_unselected(tile)

signal tile_picked(tiles)



## Exported Variables
# Range temporarily disabled for 4.0
var _selection_max: int = 10
@export var selection_max: int:
	get:
		return _selection_max
	set(value):
		set_selection_max(value)

var _hovered_color: Color = Color(1, 1, 1, 0.6)
@export var hovered_color: Color:
	get:
		return _hovered_color
	set(value):
		set_hovered_color(value)

var _selected_color: Color = Color.WHITE
@export var selected_color: Color:
	get:
		return _selected_color
	set(value):
		set_selection_color(value)

var _invalid_color: Color = Color.RED
@export var invalid_color: Color:
	get:
		return _invalid_color
	set(value):
		set_invalid_color(value)

var _voxel_set: Resource
@export var voxel_set: Resource:
	get:
		return _voxel_set
	set(value):
		set_voxel_set(value)



## OnReady Variables
@onready var tiles_viewer := get_node("VBoxContainer/ScrollContainer/TilesViewer")

@onready var confirm : Button = get_node("VBoxContainer/HBoxContainer/Confirm")

@onready var cancel : Button = get_node("VBoxContainer/HBoxContainer/Cancel")



## Built-In Virtual Methods
func _ready() -> void:
	set_selection_max(selection_max)
	set_hovered_color(hovered_color)
	set_selection_color(selected_color)
	set_invalid_color(invalid_color)
	set_voxel_set(voxel_set)
	
	update_rect_min()
	
	tiles_viewer.connect("tile_selected", _on_TilesViewer_selected_tile)
	tiles_viewer.connect("tile_unselected", _on_TilesViewer_unselected_tile)
	
	confirm.connect("pressed", _on_Confirm_pressed)
	
	cancel.connect("pressed", _on_Cancel_pressed)


## Public Methods
func set_selection_max(value : int, update := true) -> void:
	_selection_max = value
	if is_instance_valid(tiles_viewer):
		tiles_viewer.set_selection_max(value, update)


func set_hovered_color(value : Color, update := true) -> void:
	_hovered_color = value
	if is_instance_valid(tiles_viewer):
		tiles_viewer.set_hovered_color(value, update)


func set_selection_color(value : Color, update := true) -> void:
	_selected_color = value
	if is_instance_valid(tiles_viewer):
		tiles_viewer.set_selection_color(value, update)


func set_invalid_color(value : Color, update := true) -> void:
	_invalid_color = value
	if is_instance_valid(tiles_viewer):
		tiles_viewer.set_invalid_color(value, update)


func set_voxel_set(value : Resource, update := true) -> void:
	_voxel_set = value
	if is_instance_valid(tiles_viewer):
		tiles_viewer.set_voxel_set(value, update)



## Private Methods
func _on_TilesViewer_selected_tile(tile : Vector2):
	emit_signal("tile_selected", tile)


func _on_TilesViewer_unselected_tile(tile : Vector2):
	emit_signal("tile_unselected", tile)


func _on_Confirm_pressed() -> void:
	emit_signal("tile_picked", tiles_viewer.get_selections())
	hide()


func _on_Cancel_pressed():
	hide()
