tool
extends WindowDialog
## Menu Class



## Exported Variables
export var keep_centered := true



## Built-In Virtual Methods
func _ready() -> void:
	get_tree().connect("screen_resized", self, "_on_SceneTree_screen_resized")



## Public Methods
func update_rect_min() -> void:
	rect_min_size = Vector2.ZERO
	set_as_minsize()
	rect_size += Vector2(32, 32)
	rect_min_size = rect_size


func show_centered() -> void:
	update_rect_min()
	set_position(
			(get_viewport_rect().size / 2) - (rect_min_size / 2))
	show()


func popup_centered(size : Vector2 = Vector2( 0, 0 )) -> void:
	update_rect_min()
	.popup_centered(size)



## Private Methods
func _on_SceneTree_screen_resized() -> void:
	if keep_centered and visible:
		show_centered()
