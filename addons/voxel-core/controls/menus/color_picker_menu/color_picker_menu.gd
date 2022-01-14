tool
extends "res://addons/voxel-core/controls/menus/menu.gd"
## Color Picker Menu Class



## Signals
signal color_changed(color)

signal color_picked(color)



## Exported Variables
export var color : Color = Color.white setget set_color

export var edit_alpha : bool = true setget set_edit_alpha

export var hsv_mode : bool = false setget set_hsv_mode

export var raw_mode : bool = false setget set_raw_mode

export var deferred_mode : bool = false setget set_deferred_mode

export var presets_enabled : bool = true setget set_presets_enabled

export var presets_visible : bool = true setget set_presets_visible



## OnReady Variables
onready var color_picker : ColorPicker = get_node("VBoxContainer/ColorPicker")

onready var confirm : Button = get_node("VBoxContainer/HBoxContainer/Confirm")

onready var cancel : Button = get_node("VBoxContainer/HBoxContainer/Cancel")



## Built-In Vritual Methods
func _ready() -> void:
	set_color(color)
	set_edit_alpha(edit_alpha)
	set_hsv_mode(hsv_mode)
	set_raw_mode(raw_mode)
	set_deferred_mode(deferred_mode)
	set_presets_enabled(presets_enabled)
	set_presets_visible(presets_visible)
	
	update_rect_min()
	
	color_picker.connect("color_changed", self, "_on_ColorPicker_color_changed")
	
	confirm.connect("pressed", self, "_on_Confirm_pressed")
	
	cancel.connect("pressed", self, "_on_Cancel_pressed")



## Public Methods
func set_color(value : Color) -> void:
	color = value
	if is_instance_valid(color_picker):
		color_picker.color = color


func set_edit_alpha(value : bool) -> void:
	edit_alpha = value
	if is_instance_valid(color_picker):
		color_picker.edit_alpha = edit_alpha


func set_hsv_mode(value : bool) -> void:
	hsv_mode = value
	if is_instance_valid(color_picker):
		color_picker.hsv_mode = hsv_mode


func set_raw_mode(value : bool) -> void:
	raw_mode = value
	if is_instance_valid(color_picker):
		color_picker.raw_mode = raw_mode


func set_deferred_mode(value : bool) -> void:
	deferred_mode = value
	if is_instance_valid(color_picker):
		color_picker.deferred_mode = deferred_mode


func set_presets_enabled(value : bool) -> void:
	presets_enabled = value
	if is_instance_valid(color_picker):
		color_picker.presets_enabled = presets_enabled


func set_presets_visible(value : bool) -> void:
	presets_visible = value
	if is_instance_valid(color_picker):
		color_picker.presets_visible = presets_visible



## Private Methods
func _on_ColorPicker_color_changed(color : Color) -> void:
	emit_signal("color_changed", color)


func _on_Confirm_pressed() -> void:
	emit_signal("color_picked", color_picker.color)
	hide()


func _on_Cancel_pressed():
	hide()
