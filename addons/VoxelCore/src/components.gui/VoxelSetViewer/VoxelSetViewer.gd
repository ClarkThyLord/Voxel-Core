tool
extends ScrollContainer



# Imports
const VoxelObject = preload('res://addons/VoxelCore/src/VoxelObject.gd')
const VoxelView = preload('res://addons/VoxelCore/src/components.gui/VoxelViewer/VoxelViewer.tscn')



# Refrences
onready var voxels : HBoxContainer = $Voxels



# Declarations
signal set_active_voxel(active_voxel)
# Active VoxelView
var ActiveVoxel = null setget set_active_voxel
# Set active VoxelView
# voxelviewer   : VoxelViewer   :   VoxelViewer to set as active
# emit          : bool          :   true, emit 'set_active_voxel' signal; false, don't emit 'set_active_voxel' signal
#
# Example:
#   set_active_voxel([VoxelViewer], false)
#
func set_active_voxel(voxelviewer, emit : bool = true) -> void:
	if ActiveVoxel == voxelviewer and !voxelviewer.active:
		ActiveVoxel = null
		if emit: emit_signal('set_active_voxel', ActiveVoxel)
		return
	elif ActiveVoxel != null and voxelviewer != ActiveVoxel: ActiveVoxel.set_active(false, false)
	
	ActiveVoxel = voxelviewer
	if emit: emit_signal('set_active_voxel', ActiveVoxel)


# String of keys to be displayed in all VoxelView's hint
export(String) var DataDisplay : String = '' setget set_data_display
# Setter for DataDisplay
# datadisplay   :   String   :   String to set as DataDisplay
# update        :   update   :   true, call on update; false, don't call on update
#
# Example:
#   set_data_display('something new,and BIG', false)
#
func set_data_display(datadisplay : String, update : bool = true) -> void:
	DataDisplay = datadisplay
	
	if update: update()


signal set_voxelset
# VoxelSet to visualize
var voxelset : VoxelSet setget set_voxelset
# Setter for voxelset
# _voxelset   :   VoxelSet   -   VoxelSet to be set
# update      :   bool       -   true, call on update; false, don't call on update
# emit        :   bool       -   true, emit 'set_voxelset' signal; false, don't emit 'set_voxelset' signal
#
# Example:
#   set_voxelset([VoxelSet], false)
#
func set_voxelset(_voxelset : VoxelSet, update : bool = true, emit : bool = true) -> void:
	ActiveVoxel = null
	voxelset = _voxelset
	
	if update: update()
	if emit: emit_signal('set_voxelset')

export(NodePath) var VoxelSetPath : NodePath = NodePath('/root/CoreVoxelSet') setget set_voxelsetpath
# Sets the path to voxelset, and the voxelset in itself
# voxelsetpath   :   NodePath   -   path to VoxelSet to be set as voxelset
# emit        :   bool       -   true, emit 'set_voxelset' signal; false, don't emit 'set_voxelset' signal
#
# Example:
#   set_voxelsetpath([NodePath])
#
func set_voxelsetpath(voxelsetpath : NodePath, emit : bool = true) -> void:
	if is_inside_tree() and has_node(voxelsetpath):
		if get_node(voxelsetpath) is VoxelSet:
			set_voxelset(get_node(voxelsetpath), emit)
			VoxelSetPath = voxelsetpath
		elif get_node(voxelsetpath) is VoxelObject:
			set_voxelset(get_node(voxelsetpath).VoxelSetUsed, emit)
			VoxelSetPath = voxelsetpath



# Core
func _ready() -> void: set_voxelsetpath(VoxelSetPath)


# Updates the VoxelViews present
#
# Example:
#   update()
#
func update() -> void:
	if voxels and voxelset is VoxelSet:
		for child in voxels.get_children():
			voxels.remove_child(child)
			child.queue_free()
		
		var voxel_ids : Array = voxelset.voxels.keys()
		voxel_ids.sort()
		
		var voxelset_texture : Image
		if voxelset.AlbedoTexture != '': voxelset_texture = (load(voxelset.AlbedoTexture) as Texture).get_data()
		
		for voxel_id in voxel_ids:
			var voxel = voxelset.get_voxel(voxel_id)
			var voxelview := VoxelView.instance()
			
			voxelview.represents = voxel_id
			
			var text = ''
			var data : Dictionary = Voxel.get_data(voxel)
			for key in data.keys(): if DataDisplay.find(key) > -1: text += str(key).capitalize() + ' : ' + str(data[key])
			voxelview.update_text(text)
			
			voxelview.set_voxel_color(Voxel.get_color(voxel))
			
			var texture_pos : Vector2 = Voxel.get_texture(voxel)
			if voxelset_texture and not texture_pos == null:
				var img_tex := ImageTexture.new()
				var rec := Rect2(Vector2.ONE * texture_pos * voxelset.TileSize, Vector2.ONE * voxelset.TileSize)
				var tile_tex := voxelset_texture.get_rect(rec)
				
				tile_tex.resize(30, 30)
				
				img_tex.create_from_image(tile_tex)
				
				voxelview.set_voxel_texture(img_tex)
			
			voxelview.connect('set_active', self, 'set_active_voxel')
			
			voxels.add_child(voxelview)
