tool
extends ScrollContainer



# Refrences
const VoxelSetClass := preload('res://addons/Voxel-Core/src/VoxelSet.gd')

const VoxelView := preload('res://addons/Voxel-Core/engine/BottomPanel/VoxelSetView/VoxelView/VoxelView.tscn')



# Declarations
# VoxelSet being used, emits 'set_voxel_set'.
# voxelset   :   bool   -   value to set
# update     :   bool   -   call on update
# emit       :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel_set(true, false, false)
#
signal set_voxel_set(voxelset)
var VoxelSet : VoxelSetClass setget set_voxel_set
func set_voxel_set(voxelset : VoxelSetClass, update := true, emit := true) -> void:
	if voxelset == VoxelSet: return
	elif typeof(voxelset) == TYPE_NIL:
		if has_node('/root/VoxelSet'): voxelset = get_node('/root/CoreVoxelSet')
		else: return
	
	if VoxelSet is VoxelSetClass and VoxelSet.is_connected('updated', self, 'update'): VoxelSet.disconnect('update', self, 'update')
	VoxelSet = voxelset
	if not VoxelSet.is_connected('updated', self, 'update'): VoxelSet.connect('updated', self, 'update')
	
	if update: _update()
	if emit: emit_signal('set_voxel_set', VoxelSet)


# NodePath to VoxelSet being used, emits 'set_voxel_set'.
# voxelsetpath   :   bool   -   value to set
# update         :   bool   -   call on update
# emit           :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_voxel_set_path([NodePath], false, false)
#
export(NodePath) var VoxelSetPath : NodePath setget set_voxel_set_path
func set_voxel_set_path(voxelsetpath : NodePath, update := true, emit := true) -> void:
	if voxelsetpath.is_empty(): VoxelSetPath = voxelsetpath
	elif is_inside_tree() and has_node(voxelsetpath) and get_node(voxelsetpath) is VoxelSetClass:
		VoxelSetPath = voxelsetpath
		set_voxel_set(get_node(voxelsetpath), update, emit)



# Core
#func _ready():
#	set_voxel_set_path(VoxelSetPath)


func _update() -> void:
	if VoxelSet and VoxelSet is VoxelSetClass:
		for voxel_id in VoxelSet.Voxels:
			var voxelview = VoxelView.instance()
			voxelview.setup(voxel_id, VoxelSet.Voxels[voxel_id])
			get_node('PanelContainer/Voxels').add_child(voxelview)
