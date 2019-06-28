tool
extends ColorRect



# Refrences
onready var voxel : ColorRect = get_node('VoxelColor')



# Declarations
# That which this VoxelView represents
var represents = null


# Usage hint to be shown
export(String) var UsageHint : String = '\n\nLeft Click   : select voxel\nRight Click : unselect voxel'
# Whether or not to usage hint will be in tooltip
export(bool) var usage_hint : bool = true setget set_usage_hint
func set_usage_hint(_usage_hint : bool = !usage_hint) -> void:
	usage_hint = _usage_hint
	
	update_text()


signal set_focus(_self)
# Focus state of VoxelView
var focus : bool = false setget set_focus
# Setter for focus
# _focus     :   bool              -   true, is focused; false, isn't focused
# emit       :   bool              -   true, emit 'set_focus' signal; false, don't emit 'set_focus' signal
#
# Example:
#   set_focus(false, false) -> VoxelView[self]
#
func set_focus(_focus : bool = !focus, emit : bool = true) -> void:
	focus = _focus
	
	if !active: color = focused_color if focus else unfocused_color
	
	if emit: emit_signal('set_focus', self)

signal set_active(_self)
# Active state of VoxelView
var active : bool = false setget set_active
# Setter for active
# _active     :   bool              -   true, is active; false, isn't active
# emit        :   bool              -   true, emit 'set_active' signal; false, don't emit 'set_active' signal
#
# Example:
#   set_active(false, false) -> VoxelView[self]
#
func set_active(_active : bool, emit : bool = true) -> void:
	active = _active
	
	if active: color = active_color
	else: color = focused_color if focus else unfocused_color
	
	if emit: emit_signal('set_active', self)


export(Color) var unfocused_color : Color = Color(0, 0, 0, 0) setget set_unfocused_color
func set_unfocused_color(color : Color) -> void:
	unfocused_color = color
	
	if !focus and !active: self.color = unfocused_color

export(Color) var focused_color : Color = Color(1, 1, 1, 0.2) setget set_focused_color
func set_focused_color(color : Color) -> void:
	focused_color = color
	
	if focus and !active: self.color = focused_color

export(Color) var active_color : Color = Color(1, 1, 1, 0.4) setget set_active_color
func set_active_color(color : Color) -> void:
	active_color = color
	
	if active: self.color = active_color

export(Color) var voxel_color : Color = Color() setget set_voxel_color
func set_voxel_color(color : Color) -> void:
	voxel_color = color
	
	if voxel: voxel.color = voxel_color



# Core
func _ready():
	color = unfocused_color
	voxel.color = voxel_color
	update_text(hint_tooltip)


func update_text(text : String = hint_tooltip) -> void:
	text = text.replace(UsageHint, '')
	if usage_hint: text += UsageHint
	
	hint_tooltip = text


func _on_focus_entered() -> void: set_focus(true)

func _on_focus_exited() -> void: set_focus(false)

func _on_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed(): set_active(true)
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.is_pressed() and active: set_active(false)
