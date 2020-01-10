tool
extends PanelContainer



# Refrences
onready var Name := get_node('PanelContainer/Name')
onready var NameEdit := get_node('PanelContainer/NameEdit')
onready var NewName := get_node('PanelContainer/NameEdit/Name')
onready var Rename := get_node('PanelContainer/NameEdit/Rename')
onready var Cancel := get_node('PanelContainer/NameEdit/Cancel')

onready var Remove := get_node('PanelContainer/HBoxContainer/Remove')
onready var Visible := get_node('PanelContainer/HBoxContainer/Visible')



# Declarations
export(String) var LayerName := '' setget set_layer_name
func set_layer_name(layername : String, update := true) -> void:
	LayerName = layername
	if update: _update()


export(bool) var LayerVisible := true setget set_layer_visible
func set_layer_visible(visible : bool = !LayerVisible, update := true) -> void:
	LayerVisible = visible
	if update: _update()

export(Color) var VisibleColor := Color.white setget set_visible_color
func set_visible_color(color : Color, update := true) -> void:
	VisibleColor = color
	if update: _update()

export(Color) var InvisibleColor := Color(1, 1, 1, 0.3) setget set_invisible_color
func set_invisible_color(color : Color, update := true) -> void:
	InvisibleColor = color
	if update: _update()



# Core
func _ready():
	Name.visible = true
	NameEdit.visible = false
	_update()


func _update() -> void:
	if Name:
		Name.text = LayerName
		Name.set("custom_colors/font_color", VisibleColor if LayerVisible else InvisibleColor)


func _on_Name_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.doubleclick:
		Name.visible = false
		NameEdit.visible = true
		NewName.grab_focus()

signal rename(name, newname)
func rename(newname : String, emit := true) -> void:
	Name.text = newname
	Name.visible = true
	NameEdit.visible = false
	if emit: emit_signal('rename', LayerName, newname)

func _on_Rename_pressed():
	rename(NewName.text)

func _on_Cancel_pressed():
	Name.visible = true
	NameEdit.visible = false


signal toggle(name)
func _on_Visible_pressed():
	set_layer_visible()
	emit_signal('toggle', LayerName)

signal move_up(name)
func _on_MoveUp_pressed():
	emit_signal('move_up', LayerName)

signal move_down(name)
func _on_MoveDown_pressed():
	emit_signal('move_down', LayerName)

signal remove(name)
func _on_Remove_pressed():
	emit_signal('remove', LayerName)
