tool
extends WindowDialog
## Menu Class



## Built-In Virtual Methods
func _ready() -> void:
	set_as_minsize()
	rect_size += Vector2(32, 32)
	rect_min_size = rect_size



## Public Methods
func show_centered() -> void:
	set_as_minsize()
	popup_centered()
