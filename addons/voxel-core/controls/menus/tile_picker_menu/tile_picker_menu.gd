tool
extends "res://addons/voxel-core/controls/menus/menu.gd"
## Color Picker Menu Class



## Signals
signal tile_selected(tile)

signal tile_unselected(tile)

signal tile_picked(tiles)



## Exported Variables
export(int, -1, 256) var selection_max := 0 setget set_selection_max

export var hovered_color := Color(1, 1, 1, 0.6) setget set_hovered_color

export var selected_color := Color.white setget set_selection_color

export var invalid_color := Color.red setget set_invalid_color

export(Resource) var voxel_set setget set_voxel_set



## OnReady Variables
onready var tiles_viewer := get_node("VBoxContainer/ScrollContainer/TilesViewer")

onready var confirm : Button = get_node("VBoxContainer/HBoxContainer/Confirm")

onready var cancel : Button = get_node("VBoxContainer/HBoxContainer/Cancel")



## Built-In Virtual Methods
func _ready() -> void:
	set_selection_max(selection_max)
	set_hovered_color(hovered_color)
	set_selection_color(selected_color)
	set_invalid_color(invalid_color)
	set_voxel_set(voxel_set)
	
	update_rect_min()
	
	tiles_viewer.connect("tile_selected", self, "_on_TilesViewer_selected_tile")
	tiles_viewer.connect("tile_unselected", self, "_on_TilesViewer_unselected_tile")
	
	confirm.connect("pressed", self, "_on_Confirm_pressed")
	
	cancel.connect("pressed", self, "_on_Cancel_pressed")


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
	emit_signal("tile_selected", tile)


func _on_TilesViewer_unselected_tile(tile : Vector2):
	emit_signal("tile_unselected", tile)


func _on_Confirm_pressed() -> void:
	emit_signal("tile_picked", tiles_viewer.get_selections())
	hide()


func _on_Cancel_pressed():
	hide()
