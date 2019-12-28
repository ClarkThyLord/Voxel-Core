tool
extends PanelContainer



# Refrences
const VoxelSetClass := preload('res://addons/Voxel-Core/src/VoxelSet.gd')

const VoxelView := preload('res://addons/Voxel-Core/engine/BottomPanel/VoxelSetView/VoxelView/VoxelView.tscn')
const VoxelViewClass := preload('res://addons/Voxel-Core/engine/BottomPanel/VoxelSetView/VoxelView/VoxelView.gd')

onready var Voxels := get_node('HBoxContainer/VoxelSetView/Voxels')



# Declarations
var VoxelViews := {}


signal set_primary(primary)
export(String) var Primary setget set_primary
func set_primary(primary, emit := true) -> void:
	if not str(primary) == str(Primary):
		set_primary_voxel_view(primary, false)
	
	Primary = primary
	
	if emit: emit_signal('set_primary', Primary)

signal set_primary_color(color)
export(Color) var PrimaryColor setget set_primary_color
func set_primary_color(color : Color, emit := true) -> void:
	PrimaryColor = color
	
	if emit: emit_signal('set_primary_color', PrimaryColor)

func set_primary_voxel_view(id, emit := true) -> void:
	var voxelview = VoxelViews.get(Primary)
	if voxelview:
		voxelview.set_selected_mode(VoxelViewClass.SelectedModes.NONE, false, false)
		if is_connected('set_primary_color', voxelview, 'set_selected_color'):
			disconnect('set_primary_color', voxelview, 'set_selected_color')
	
	voxelview = VoxelViews.get(id)
	if voxelview:
		voxelview.set_selected_color(PrimaryColor)
		voxelview.set_selected_mode(VoxelViewClass.SelectedModes.PRIMARY, true, false)
		if not is_connected('set_primary_color', voxelview, 'set_selected_color'):
			connect('set_primary_color', voxelview, 'set_selected_color')
	
	if emit: set_primary(id)


signal set_secondary(secondary)
export(String) var Secondary setget set_secondary
func set_secondary(secondary, emit := true) -> void:
	if not str(secondary) == str(Secondary):
		set_secondary_voxel_view(secondary, false)
	
	Secondary = secondary
	
	if emit: emit_signal('set_secondary', Secondary)

signal set_secondary_color(color)
export(Color) var SecondaryColor setget set_secondary_color
func set_secondary_color(color : Color, emit := true) -> void:
	SecondaryColor = color
	
	if emit: emit_signal('set_secondary_color', SecondaryColor)

func set_secondary_voxel_view(id, emit := true) -> void:
	var voxelview = VoxelViews.get(Secondary)
	if voxelview:
		voxelview.set_selected_mode(VoxelViewClass.SelectedModes.NONE, false, false)
		if is_connected('set_secondary_color', voxelview, 'set_selected_color'):
			disconnect('set_secondary_color', voxelview, 'set_selected_color')
	
	voxelview = VoxelViews.get(id)
	if voxelview:
		voxelview.set_selected_color(SecondaryColor)
		voxelview.set_selected_mode(VoxelViewClass.SelectedModes.PRIMARY, true, false)
		if not is_connected('set_secondary_color', voxelview, 'set_selected_color'):
			connect('set_secondary_color', voxelview, 'set_selected_color')
	
	if emit: set_secondary(id)


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
	
	if VoxelSet is VoxelSetClass and VoxelSet.is_connected('updated', self, 'update'): VoxelSet.disconnect('update', self, '_update')
	VoxelSet = voxelset
	if not VoxelSet.is_connected('updated', self, 'update'): VoxelSet.connect('updated', self, '_update')
	
	if update: _update(VoxelSet.Voxels)
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
func _on_Search_text_changed(new_text : String) -> void:
	if VoxelSet:
		if new_text.empty():
			_update(VoxelSet.Voxels)
		else:
			var voxels := {}
			
			var keywords := new_text.split(',')
			
			for keyword in keywords:
				if keyword.is_valid_integer():
					keyword = keyword.to_int()
				var voxel = VoxelSet.get_voxel(keyword)
				if typeof(voxel) == TYPE_DICTIONARY: voxels[keyword] = voxel
			
			_update(voxels)


func _update(voxels : Dictionary) -> void:
	for child in Voxels.get_children():
		Voxels.remove_child(child)
		child.queue_free()
	
	VoxelViews.clear()
	for voxel_id in voxels:
		var voxelview := VoxelView.instance()
		voxelview.set_name(str(voxel_id))
		voxelview.setup(self, voxel_id, voxels[voxel_id])
		
		voxelview.connect('primary', self, 'set_primary_voxel_view')
		voxelview.connect('secondary', self, 'set_secondary_voxel_view')
		
		Voxels.add_child(voxelview)
		VoxelViews[voxel_id] = voxelview
	
	set_primary_voxel_view(Primary, false)
	set_secondary_voxel_view(Secondary, false)
