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


func update() -> void:
	for voxel_button in %VoxelsContainer.get_children():
		%VoxelsContainer.remove_child(voxel_button)
		voxel_button.queue_free()
	
	if not is_instance_valid(voxel_set):
		return
	
	for voxel_id in voxel_set.get_voxel_ids():
		var voxel_button : Button = Button.new()
		
		voxel_button.custom_minimum_size = Vector2(32, 32)
		
		%VoxelsContainer.add_child(voxel_button)
