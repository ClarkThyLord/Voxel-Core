@tool
extends VBoxContainer
## Voxel Viewer Class



# Signals
signal voxel_id_changed(old_voxel_id : int, new_voxel_id : int)



# Public Variables
@export
var voxel_id : int = -1 :
	set = set_voxel_id

@export
var voxel_set : VoxelSet = null :
	get = get_voxel_set,
	set = set_voxel_set

@export_range(1, 100, 1)
var camera_sensitivity : int = 8 :
	set = set_camera_sensitivity



# Private Variables
var _is_dragging : bool = false



# Public Methods
func set_voxel_id(new_voxel_id : int) -> void:
	voxel_id = new_voxel_id
	
	if is_instance_valid(%VoxelIDLineEdit):
		%VoxelIDLineEdit.text = str(voxel_id)
	
	if is_instance_valid(voxel_set) and voxel_set.has_voxel_id(voxel_id):
		if is_instance_valid(%VoxelNameLineEdit):
			var voxel : Voxel = voxel_set.get_voxel(voxel_id)
			%VoxelNameLineEdit.text = str(voxel.get_name())
	
	if is_instance_valid(%VoxelViewer):
		%VoxelViewer.voxel_id = voxel_id


func set_camera_sensitivity(new_camera_sensitivity : int) -> void:
	camera_sensitivity = new_camera_sensitivity
	
	if is_instance_valid(%VoxelViewer):
		%VoxelViewer.camera_sensitivity = camera_sensitivity


## Returns [member voxel_set].
func get_voxel_set() -> VoxelSet:
	return voxel_set


## Sets [member voxel_set]; and, if in engine, calls on [method update].
func set_voxel_set(new_voxel_set : VoxelSet) -> void:
	voxel_set = new_voxel_set
	
	if is_instance_valid(%VoxelViewer):
		%VoxelViewer.voxel_set = voxel_set


func edit_voxel(voxel_set : VoxelSet, voxel_id : int) -> void:
	set_voxel_set(voxel_set)
	set_voxel_id(voxel_id)


# Private Methods
func _is_voxel_id_line_edit_text_valid() -> bool:
	var valid : bool = %VoxelIDLineEdit.text.is_valid_int()
	if not valid:
		%VoxelIDLineEdit.text = str(voxel_id)
	return valid


func _on_voxel_id_line_edit_text_submitted(new_voxel_id : String) -> void:
	if _is_voxel_id_line_edit_text_valid() and \
			%VoxelIDLineEdit.text != str(voxel_id):
		%VoxelIdChangeConfirmationDialog.popup()


func _on_voxel_id_line_edit_focus_exited():
	if _is_voxel_id_line_edit_text_valid() and \
			%VoxelIDLineEdit.text != str(voxel_id):
		%VoxelIdChangeConfirmationDialog.popup()


func _on_voxel_id_change_confirmation_dialog_about_to_popup():
	%VoxelIdChangeConfirmationDialog.dialog_text = "Change voxel id?"
	if voxel_set.has_voxel_id(int(%VoxelIDLineEdit.text)):
		%VoxelIdChangeConfirmationDialog.dialog_text += "\nWARNING: Will overwrite existing voxel!"


func _on_voxel_id_change_confirmation_dialog_canceled():
	%VoxelIDLineEdit.text = str(voxel_id)


func _on_voxel_id_change_confirmation_dialog_confirmed():
	var voxel : Voxel = voxel_set.get_voxel(voxel_id)
	
	var old_voxel_id : int = voxel_id
	var new_voxel_id : int = int(%VoxelIDLineEdit.text)
	
	voxel_set.remove_voxel(voxel_id)
	voxel_set.set_voxel(new_voxel_id, voxel)
	
	set_voxel_id(new_voxel_id)
	
	voxel_set.emit_changed()
	
	voxel_id_changed.emit(old_voxel_id, new_voxel_id)


func _on_voxel_name_line_edit_text_submitted(new_text : String) -> void:
	print(new_text)
