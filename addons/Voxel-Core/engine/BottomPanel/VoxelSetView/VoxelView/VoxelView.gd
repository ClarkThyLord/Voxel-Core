tool
extends ColorRect



# Declarations
var ID : int setget set_id
func set_id(id : int) -> void: return                     #   ID shouldn't be settable directly
var Represents : Dictionary setget set_represents
func set_represents(id : Dictionary) -> void: return      #   Represents shouldn't be settable directly
var VoxelSetView setget set_voxel_set_view   #   VoxelView shouldn't be settable directly
func set_voxel_set_view(voxelsetview) -> void: return


export(Color) var NormalColor := Color(0, 0, 0, 0.1)

var Focused := false
export(Color) var FocusedColor := Color(0, 0, 0, 0.25)

var Hovered := false
export(Color) var HoverdColor := Color(0, 0, 0, 0.35)

signal selected(selected)
var Selected := false
export(Color) var SelectedColor := Color(1, 1, 1, 0.1)
func set_selected(selected : bool = !Selected, emit := true) -> void:
	Selected = selected
	if emit: emit_signal('selected', Selected)
	if emit and VoxelSetView:
		if Selected: VoxelSetView.add_selected(self)
		else: VoxelSetView.remove_selected(self)
	_update()



# Core
func _ready(): color = NormalColor

func setup(id : int, voxel : Dictionary, voxelsetviewer) -> void:
	ID = id
	Represents = voxel
	VoxelSetView = voxelsetviewer
	
	get_node('CenterContainer/Color').color = Voxel.get_color(voxel)
	get_node('CenterContainer/Texture').texture = Voxel.get_texture(voxel)


func _update():
	if Selected: color = SelectedColor
	elif Hovered: color = HoverdColor
	elif Focused: color = FocusedColor
	else: color = NormalColor


func _on_focus_entered():
	Focused = true
	_update()

func _on_focus_exited():
	Focused = false
	_update()


func _on_mouse_entered():
	Hovered = true
	_update()

func _on_mouse_exited():
	Hovered = false
	_update()


func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed() or event is InputEventKey and event.scancode == KEY_ENTER and event.pressed:
		set_selected()
