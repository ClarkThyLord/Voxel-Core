@tool
extends PopupMenu
## Menu Class



## Exported Variables
@export var keep_centered := true



## Built-In Virtual Methods
func _ready() -> void:
	get_tree().connect("screen_resized", _on_SceneTree_screen_resized)



## Public Methods
func update_rect_min() -> void:
	min_size = Vector2.ZERO
	size = min_size
	size += Vector2i(32, 32)
	min_size = size


func show_centered() -> void:
	update_rect_min()
	set_position(
			(Vector2i(get_visible_rect().size / 2)) - (min_size / 2))
	show()


func popup_centered(size : Vector2 = Vector2( 0, 0 )) -> void:
	update_rect_min()
	super.popup_centered(size)



## Private Methods
func _on_SceneTree_screen_resized() -> void:
	if keep_centered and visible:
		show_centered()
