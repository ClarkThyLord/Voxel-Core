@tool
extends VBoxContainer
## VoxelSet Viewer Class


# Signals
signal voxel_set_changed



# Exported Variables
@export
var voxel_set : VoxelSet = null :
	get = get_voxel_set,
	set = set_voxel_set



# Private Variables
var _selected_voxel_ids : Array[int] = []



# Public Methods
## Returns [member voxel_set].
func get_voxel_set() -> VoxelSet:
	return voxel_set


## Sets [member voxel_set]; and, if in engine, calls on [method update].
func set_voxel_set(new_voxel_set : VoxelSet) -> void:
	if is_instance_valid(voxel_set):
		if voxel_set.changed.is_connected(update):
			voxel_set.changed.disconnect(update)
	
	voxel_set = new_voxel_set
	
	if is_instance_valid(voxel_set):
		voxel_set.changed.connect(update)
	
	voxel_set_changed.emit()
	
	if Engine.is_editor_hint():
		update()


func is_voxel_selected(voxel_id : int) -> bool:
	return voxel_id in _selected_voxel_ids


func select_all_voxels() -> void:
	if not is_instance_valid(voxel_set):
		return
	
	for voxel_id in voxel_set.get_voxel_ids():
		select_voxel(voxel_id)


func unselect_all_voxels() -> void:
	if not is_instance_valid(voxel_set):
		return
	
	for voxel_id in voxel_set.get_voxel_ids():
		unselect_voxel(voxel_id)


func select_voxel(voxel_id : int) -> void:
	if is_voxel_selected(voxel_id):
		return
	
	var voxel_button : Button = _get_voxel_button(voxel_id)
	voxel_button.button_pressed = true
	
	_selected_voxel_ids.append(voxel_id)


func unselect_voxel(voxel_id : int) -> void:
	if not is_voxel_selected(voxel_id):
		return
	
	var voxel_button : Button = _get_voxel_button(voxel_id)
	voxel_button.button_pressed = false
	
	_selected_voxel_ids.erase(voxel_id)


func remove_voxel(voxel_id : int) -> void:
	voxel_set.remove_voxel(voxel_id)


func update() -> void:
	for voxel_button in %VoxelsContainer.get_children():
		%VoxelsContainer.remove_child(voxel_button)
		voxel_button.queue_free()
	
	if not is_instance_valid(voxel_set):
		return
	
	for voxel_id in voxel_set.get_voxel_ids():
		var voxel_button : Button = Button.new()
		
		voxel_button.name = str(voxel_id)
		voxel_button.custom_minimum_size = Vector2(32, 32)
		voxel_button.toggle_mode = true
		
		voxel_button.gui_input.connect(Callable(_on_voxel_button_gui_input)
				.bind(voxel_id, voxel_button))
		
		%VoxelsContainer.add_child(voxel_button)



# Private Methods
func _get_voxel_button(voxel_id : int) -> Button:
	return %VoxelsContainer.find_child(str(voxel_id), false, false)


func _on_voxel_button_gui_input(event : InputEvent, voxel_id : int, button : Button) -> void:
	if event is InputEventMouseButton and not event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			var selected : bool = is_voxel_selected(voxel_id)
			
			if not Input.is_key_pressed(KEY_CTRL):
				unselect_all_voxels()
			
			if selected:
				unselect_voxel(voxel_id)
			else:
				select_voxel(voxel_id)
			
			accept_event()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			accept_event()
