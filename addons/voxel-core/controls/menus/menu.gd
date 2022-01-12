tool
extends WindowDialog
## Menu Class



## Built-In Virtual Methods
func _ready() -> void:
	set_as_minsize()
	rect_size += Vector2(32, 32)
	rect_min_size = rect_size
	
	get_tree().connect("screen_resized", self, "_on_SceneTree_screen_resized")



## Public Methods
func show_centered() -> void:
	set_as_minsize()
	set_position(
			(get_viewport_rect().size / 2) - (rect_min_size / 2))
	show()


func popup_centered(size : Vector2 = Vector2( 0, 0 )) -> void:
	set_as_minsize()
	.popup_centered(size)



## Private Methods
func _on_SceneTree_screen_resized() -> void:
	if visible:
		show_centered()
