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
	
	voxel_set.add_voxel(Voxel.new())


func _on_remove_voxel_button_pressed():
	if not is_instance_valid(voxel_set):
		return
	
	for voxel_id in %VoxelSetViewer.get_selected_voxel_ids():
		voxel_set.remove_voxel(voxel_id)


func _on_duplicate_voxel_button_pressed():
	if not is_instance_valid(voxel_set):
		return
	
	for voxel_id in %VoxelSetViewer.get_selected_voxel_ids():
		voxel_set.duplicate_voxel(voxel_id)


func _on_voxel_set_viewer_selection_changed():
	%SelectedVoxelsOptions.visible = %VoxelSetViewer.get_selected_voxel_ids_count() > 0
	%VoxelEditorHBoxContainer.visible = %VoxelSetViewer.get_selected_voxel_ids_count() > 0
	selection_changed.emit()
