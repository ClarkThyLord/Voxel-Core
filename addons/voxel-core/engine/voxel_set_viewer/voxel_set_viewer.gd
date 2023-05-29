@tool
extends VBoxContainer
## VoxelSet Viewer Class



# Signals
signal voxel_set_changed



# Exported Variables
@export_range(0, 10, 1, "or_greater")
var selection_limit : int = 1 :
	set = set_selection_limit

@export
var cyclic_selection : bool = true

@export
var voxel_set : VoxelSet = null :
	get = get_voxel_set,
	set = set_voxel_set



# Private Variables
var _hovered_voxel : int = -1

var _last_hovered_voxel : int = -1

var _selected_voxels : Array[int] = []



# Public Methods
func set_selection_limit(new_select_limit : int) -> void:
	selection_limit = new_select_limit
	
	while _selected_voxels.size() > selection_limit:
		unselect_voxel(_selected_voxels.pop_back())


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
	return voxel_id in _selected_voxels


func get_first_selected_voxel() -> int:
	if _selected_voxels.size() == 0:
		return -1
	return _selected_voxels[0]


func get_selected_voxels() -> Array[int]:
	return _selected_voxels


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
	if selection_limit == 0:
		return
	elif not is_instance_valid(voxel_set):
		return
	elif not voxel_set.has_voxel_id(voxel_id):
		return
	elif is_voxel_selected(voxel_id):
		return
	
	if _selected_voxels.size() == selection_limit:
		if cyclic_selection:
			unselect_voxel(get_first_selected_voxel())
		else:
			return
	
	var voxel_button : Button = _get_voxel_button(voxel_id)
	voxel_button.button_pressed = true
	
	_selected_voxels.append(voxel_id)


func unselect_voxel(voxel_id : int) -> void:
	if not is_instance_valid(voxel_set):
		return
	elif not voxel_set.has_voxel_id(voxel_id):
		return
	elif not is_voxel_selected(voxel_id):
		return
	
	var voxel_button : Button = _get_voxel_button(voxel_id)
	voxel_button.button_pressed = false
	
	_selected_voxels.erase(voxel_id)


func add_voxel() -> void:
	if not is_instance_valid(voxel_set):
		return
	
	voxel_set.add_voxel(Voxel.new())


func remove_voxel(voxel_id : int) -> void:
	if not is_instance_valid(voxel_set):
		return
	elif not voxel_set.has_voxel_id(voxel_id):
		return
	
	voxel_set.remove_voxel(voxel_id)


func duplicate_voxel(voxel_id : int) -> void:
	if not is_instance_valid(voxel_set):
		return
	elif not voxel_set.has_voxel_id(voxel_id):
		return
	
	if voxel_set.has_voxel_id(voxel_id):
		var voxel : Voxel = voxel_set.get_voxel(voxel_id)
		voxel_set.add_voxel(voxel.duplicate())


func update() -> void:
	for voxel_button in %VoxelsContainer.get_children():
		%VoxelsContainer.remove_child(voxel_button)
		voxel_button.queue_free()
	
	if not is_instance_valid(voxel_set):
		return
	
	var selected_voxels : Array[int] = _selected_voxels.duplicate()
	_selected_voxels.clear()
	
	for voxel_id in voxel_set.get_voxel_ids():
		var voxel_button : Button = Button.new()
		
		voxel_button.name = str(voxel_id)
		voxel_button.custom_minimum_size = Vector2(32, 32)
		voxel_button.toggle_mode = true
		
		voxel_button.mouse_entered.connect(
				Callable(_on_voxel_button_mouse_entered).bind(voxel_id))
		voxel_button.mouse_exited.connect(
				Callable(_on_voxel_button_mouse_exited))
		voxel_button.gui_input.connect(Callable(_on_voxel_button_gui_input)
				.bind(voxel_id))
		
		%VoxelsContainer.add_child(voxel_button)
		
		if voxel_id in selected_voxels:
			voxel_button.set_pressed_no_signal(true)
			_selected_voxels.append(voxel_id)



# Private Methods
func _get_voxel_button(voxel_id : int) -> Button:
	return %VoxelsContainer.find_child(str(voxel_id), false, false)


func _show_voxel_popup_menu(position : Vector2) -> void:
	%VoxelPopupMenu.clear()
	
	%VoxelPopupMenu.add_item("Add", 0)
	
	if _hovered_voxel > -1:
		%VoxelPopupMenu.add_separator()
		
		%VoxelPopupMenu.add_item("Remove Hovered", 1)
		%VoxelPopupMenu.add_item("Duplicate Hovered", 2)
	
	if _selected_voxels.size() > 0:
		%VoxelPopupMenu.add_separator()
		
		%VoxelPopupMenu.add_item("Remove Selected", 3)
		%VoxelPopupMenu.add_item("Duplicate Selected", 4)
	
	if %VoxelPopupMenu.item_count == 0:
		return
	
	%VoxelPopupMenu.position = position
	%VoxelPopupMenu.reset_size()
	%VoxelPopupMenu.popup()


func _on_voxels_container_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and not event.is_pressed():
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_show_voxel_popup_menu(
					get_screen_position() + get_local_mouse_position())
			
			accept_event()


func _on_voxel_button_mouse_entered(voxel_id : int) -> void:
	_hovered_voxel = voxel_id


func _on_voxel_button_mouse_exited() -> void:
	if %VoxelPopupMenu.visible:
		return
	_hovered_voxel = -1


func _on_voxel_button_gui_input(event : InputEvent, voxel_id : int) -> void:
	if event is InputEventMouseButton and not event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_voxel_selected(voxel_id):
				unselect_voxel(voxel_id)
			else:
				select_voxel(voxel_id)
			
			accept_event()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_show_voxel_popup_menu(
					get_screen_position() + get_local_mouse_position())
			
			accept_event()


func _on_voxel_popup_menu_id_pressed(id : int) -> void:
	match id:
		0: # Add
			add_voxel()
		1: # Remove
			remove_voxel(_last_hovered_voxel)
		2: # Duplicate
			duplicate_voxel(_last_hovered_voxel)
		3: # Remove Selected
			for voxel_id in _selected_voxels:
				remove_voxel(voxel_id)
		4: # Duplicate Selected
			for voxel_id in _selected_voxels:
				duplicate_voxel(voxel_id)


func _on_voxel_popup_menu_popup_hide():
	_last_hovered_voxel = _hovered_voxel
	_hovered_voxel = -1
