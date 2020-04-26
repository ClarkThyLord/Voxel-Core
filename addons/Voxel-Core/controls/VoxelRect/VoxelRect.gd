tool
extends ColorRect



# Refrences
onready var VoxelColorRef := get_node("VoxelColor")
onready var VoxelTextureRef := get_node("VoxelColor/VoxelTexture")



# Declarations
signal selected

var Represents

export(Color) var VoxelColor : Color setget set_voxel_color
func set_voxel_color(voxel_color : Color) -> void:
	VoxelColor = voxel_color
	
	if VoxelColorRef:
		VoxelColorRef.color = VoxelColor

export(Texture) var VoxelTexture : Texture = null setget set_voxel_texture
func set_voxel_texture(voxel_texture : Texture) -> void:
	VoxelTexture = voxel_texture
	
	if VoxelTextureRef:
		VoxelTextureRef.texture = VoxelTexture


export(Color) var NormalColor := Color.transparent setget set_normal_color
func set_normal_color(normal_color) -> void:
	NormalColor = normal_color
	_update()

var hovered := false
export(Color) var HoveredColor := Color(1, 1, 1, 0.45) setget set_hovered_color
func set_hovered_color(hovered_color) -> void:
	HoveredColor = hovered_color
	_update()

export(Color) var FocusedColor := Color(1, 1, 1, 0.3) setget set_focused_color
func set_focused_color(focused_color) -> void:
	FocusedColor = focused_color
	_update()

var selected := false
export(Color) var SelectedColor := Color(1, 1, 1, 0.6) setget set_selected_color
func set_selected_color(selected_color) -> void:
	SelectedColor = selected_color
	_update()

export(bool) var Disabled := false setget set_disabled
func set_disabled(disabled : bool) -> void:
	Disabled = disabled
	
	if Disabled:
		focus_mode = Control.FOCUS_NONE
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		focus_mode = Control.FOCUS_ALL
		mouse_filter = Control.MOUSE_FILTER_STOP
	
	_update()

export(Color) var DisabledColor := Color(1, 1, 1, 0.7) setget set_disabled_color
func set_disabled_color(disabled_color) -> void:
	DisabledColor = disabled_color
	_update()



# Core
func _ready():
	set_voxel_color(VoxelColor)
	set_voxel_texture(VoxelTexture)
	_update()


func _update() -> void:
	if Disabled:
		hovered = false
		selected = false
		if has_focus(): release_focus()
		modulate = DisabledColor
	else:
		if hovered: color = HoveredColor
		elif selected: color = SelectedColor
		elif has_focus(): color = FocusedColor
		else: color = NormalColor
		modulate = Color.white


func _on_mouse_entered():
	hovered = true
	_update()

func _on_mouse_exited():
	hovered = false
	_update()

func _on_focus_entered():
	_update()

func _on_focus_exited():
	_update()

func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		selected = !selected
		_update()
