tool
extends ScrollContainer



# Refrences
const VoxelSetClass := preload('res://addons/Voxel-Core/src/VoxelSet.gd')

const VoxelView := preload('res://addons/Voxel-Core/engine/BottomPanel/VoxelSetView/VoxelView/VoxelView.tscn')
const VoxelViewClass := preload('res://addons/Voxel-Core/engine/BottomPanel/VoxelSetView/VoxelView/VoxelView.gd')



# Declarations
var Selected := [] setget set_selected
func set_selected(selected : Array) -> void: return   #   Selected shouldn't be settable externally

signal selected(index)
func add_selected(voxelview : VoxelViewClass, emit := true) -> void:
	var index := Selected.find(null)
	if index > -1:
		Selected[index] = voxelview
		voxelview.set_selected(true, false)
		
		if emit: emit_signal('selected', index)
	else: voxelview.set_selected(false, false)

signal unselected(index)
func remove_selected(voxelview : VoxelViewClass, emit := true) -> void:
	var index := Selected.find(voxelview)
	if index > -1:
		Selected[index] = null
		voxelview.set_selected(false, false)
		
		if emit: emit_signal('unselected', index)


signal set_select_limit(selectlimit)
export(int) var SelectLimit := 0 setget set_select_limit
func set_select_limit(selectlimit : int, emit := true) -> void:
	SelectLimit = selectlimit
	
	for select_index in range(Selected.size()):
		if select_index + 1 > SelectLimit:
			Selected[select_index].set_selected(false, false)
			Selected.remove(select_index)
	Selected.resize(SelectLimit)
	
	if emit: emit_signal('set_select_limit', SelectLimit)


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
#	set_voxel_set_path(VoxelSetPath, true, false)


func _update() -> void:
	if VoxelSet and VoxelSet is VoxelSetClass:
		for voxel_id in VoxelSet.Voxels:
			var voxelview = VoxelView.instance()
			voxelview.setup(voxel_id, VoxelSet.Voxels[voxel_id], self)
			get_node('PanelContainer/Voxels').add_child(voxelview)
