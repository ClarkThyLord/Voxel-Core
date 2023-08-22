@tool
extends VBoxContainer
## VoxelSet Editor Class



# Signals
signal selection_changed

signal voxel_set_changed



# Exported Variables
@export_range(0, 10, 1, "or_greater")
var selection_limit : int = 1 :
	set = set_selection_limit

@export
var cyclic_selection : bool = true :
	set = set_cyclic_selection

@export
var voxel_set : VoxelSet = null :
	get = get_voxel_set,
	set = set_voxel_set



# Private Variables
var _editor_disabled : bool = false



# Public Methods
func set_selection_limit(new_selection_limit : int) -> void:
	selection_limit = new_selection_limit
	
	if is_instance_valid(%VoxelSetViewer):
		%VoxelSetViewer.selection_limit = selection_limit


func set_cyclic_selection(new_cyclic_selection : bool) -> void:
	cyclic_selection = new_cyclic_selection
	
	if is_instance_valid(%VoxelSetViewer):
		%VoxelSetViewer.cyclic_selection = cyclic_selection


## Returns [member voxel_set].
func get_voxel_set() -> VoxelSet:
	return voxel_set


## Sets [member voxel_set]; and, if in engine, calls on [method update].
func set_voxel_set(new_voxel_set : VoxelSet) -> void:
	voxel_set = new_voxel_set
	
	if is_instance_valid(%VoxelSetViewer):
		%VoxelSetViewer.set_voxel_set(voxel_set)
	
	voxel_set_changed.emit()
	
	if Engine.is_editor_hint():
		update()


func enable_editor() -> void:
	%AddVoxelButton.disabled = false
	
	_editor_disabled = false


func disable_editor() -> void:
	%AddVoxelButton.disabled = true
	
	_editor_disabled = true


func update() -> void:
	if not is_instance_valid(voxel_set):
		disable_editor()
		return
	enable_editor()



# Private Methods
func _on_add_voxel_button_pressed():
	if not is_instance_valid(voxel_set):
		return
	
	var voxel : Voxel = Voxel.new()
	
	voxel_set.add_voxel(voxel)
	
	voxel_set.emit_changed()


func _on_remove_voxel_button_pressed():
	if not is_instance_valid(voxel_set):
		return
	
	for voxel_id in %VoxelSetViewer.get_selected_voxel_ids():
		voxel_set.remove_voxel(voxel_id)
	
	voxel_set.emit_changed()
	
	%VoxelSetViewer.unselect_all_voxel_ids()


func _on_duplicate_voxel_button_pressed():
	if not is_instance_valid(voxel_set):
		return
	
	var duplicated_voxel_id : int = -1
	for voxel_id in %VoxelSetViewer.get_selected_voxel_ids():
		duplicated_voxel_id = voxel_set.duplicate_voxel(voxel_id)
	
	voxel_set.emit_changed()
	
	%VoxelSetViewer.unselect_all_voxel_ids()
	%VoxelSetViewer.select_voxel_id(duplicated_voxel_id)


func _on_voxel_set_viewer_selection_changed():
	var selected_voxel_ids_count : int = \
			%VoxelSetViewer.get_selected_voxel_ids_count()
	
	%SelectedVoxelsOptions.visible = selected_voxel_ids_count > 0
	%VoxelEditorHBoxContainer.visible = selected_voxel_ids_count > 0
	
	if selected_voxel_ids_count == 1:
		%VoxelEditor.edit_voxel(
				voxel_set, %VoxelSetViewer.get_first_selected_voxel_id())
	
	selection_changed.emit()


func _on_voxel_editor_voxel_id_changed(old_voxel_id, new_voxel_id):
	%VoxelSetViewer.select_voxel_id(new_voxel_id)
