@tool
extends "res://addons/voxel-core/controls/menus/menu.gd"
## Color Picker Menu Class



## Signals
signal color_changed(color)

signal color_picked(color)



## Exported Variables
var _color: Color = Color.WHITE
@export var color: Color:
	get:
		return _color
	set(value):
		set_color(value)

var _edit_alpha: bool = true
@export var edit_alpha: bool:
	get:
		return _edit_alpha
	set(value):
		set_edit_alpha(value)

var _hsv_mode: bool = false
@export var hsv_mode: bool:
	get:
		return _hsv_mode
	set(value):
		set_hsv_mode(value)

var _raw_mode: bool = false
@export var raw_mode: bool:
	get:
		return _raw_mode
	set(value):
		set_raw_mode(value)

var _deferred_mode: bool = false
@export var deferred_mode: bool:
	get:
		return _deferred_mode
	set(value):
		set_deferred_mode(value)

var _presets_enabled: bool = true
@export var presets_enabled: bool:
	get:
		return _presets_enabled
	set(value):
		set_presets_enabled(value)

var _presets_visible: bool = true
@export var presets_visible: bool:
	get:
		return _presets_visible
	set(value):
		set_presets_visible(value)



## OnReady Variables
@onready var color_picker : ColorPicker = get_node("VBoxContainer/ColorPicker")

@onready var confirm : Button = get_node("VBoxContainer/HBoxContainer/Confirm")

@onready var cancel : Button = get_node("VBoxContainer/HBoxContainer/Cancel")



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
	
	color_picker.connect("color_changed", _on_ColorPicker_color_changed)
	
	confirm.connect("pressed", _on_Confirm_pressed)
	
	cancel.connect("pressed", _on_Cancel_pressed)



## Public Methods
func set_color(value : Color) -> void:
	_color = value
	if is_instance_valid(color_picker):
		color_picker.color = color


func set_edit_alpha(value : bool) -> void:
	_edit_alpha = value
	if is_instance_valid(color_picker):
		color_picker.edit_alpha = edit_alpha


func set_hsv_mode(value : bool) -> void:
	_hsv_mode = value
	if is_instance_valid(color_picker):
		color_picker.hsv_mode = hsv_mode


func set_raw_mode(value : bool) -> void:
	_raw_mode = value
	if is_instance_valid(color_picker):
		color_picker.raw_mode = raw_mode


func set_deferred_mode(value : bool) -> void:
	_deferred_mode = value
	if is_instance_valid(color_picker):
		color_picker.deferred_mode = deferred_mode


func set_presets_enabled(value : bool) -> void:
	_presets_enabled = value
	if is_instance_valid(color_picker):
		color_picker.presets_enabled = presets_enabled


func set_presets_visible(value : bool) -> void:
	_presets_visible = value
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
