tool
extends EditorPlugin



# Refrences
const VoxelSetClass := preload('res://addons/Voxel-Core/src/VoxelSet.gd')
const VoxelEditorClass := preload('res://addons/Voxel-Core/src/VoxelEditor.gd')
const VoxelObjectClass := preload('res://addons/Voxel-Core/src/VoxelObject.gd')

const BottomPanelScene := preload('res://addons/Voxel-Core/engine/BottomPanel/BottomPanel.tscn')
const VoxelEditorEngineClass := preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')



# Declarations
var MainScene := ''          #   Current main scene
var HandledObject : Object   #   Current object handled


signal set_auto_save(autosave)
var AutoSave := true setget set_auto_save   #   Will save scene when changes to VoxelObject are made
# Setter for AutoSave, emits 'set_auto_save'.
# autosave   :   bool   -   value to set
# emit       :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   set_auto_save(true, false)
#
func set_auto_save(autosave := !AutoSave, emit := true) -> void:
	AutoSave = autosave
	if emit: emit_signal('set_auto_save', AutoSave)


var VoxelEditor := VoxelEditorEngineClass.new()                                    #   VoxelEditor used by VoxelCore
func set_voxel_edit_undo_redo() -> void: VoxelEditor.undo_redo = get_undo_redo()   #   Sets UndoRedo of engine to VoxelEditor


var BottomPanel : ToolButton      #   Refrence ToolButton of bottom panel
var BottomPanelControl            #   Refrence BottomPanel
var BottomPanelVisible := false   #   Whether BottomPanel is currently visible or not
# Sets BottomPanelControl to bottom panel.
# visible   :   bool   -   true, creates and adds bottom panel; false, removes and frees bottom panel
#
# Example:
#   set_bottom_panel_visible(false)
#
func set_bottom_panel_visible(visible := !BottomPanelVisible) -> void:
	if visible and not BottomPanelVisible and MainScene == '3D':
		BottomPanelControl = BottomPanelScene.instance()
		BottomPanel = add_control_to_bottom_panel(BottomPanelControl, 'Voxel-Core')
		BottomPanelControl.setup(self)
		make_bottom_panel_item_visible(BottomPanelControl)
		BottomPanelVisible = true
	elif not visible and BottomPanelVisible and BottomPanelControl:
		hide_bottom_panel()
		remove_control_from_bottom_panel(BottomPanelControl)
		BottomPanelControl.queue_free()
		BottomPanelVisible = false



# Core
enum VoxelTypes { NVT = -1, VoxelSet, VoxelEditor, VoxelObject, VoxelMesh, VoxelMultiMesh, VoxelLayeredMesh, VoxelEmbeddedMultiMesh }
# Returns the internal type of the given Variant object, using the VoxelTypes enum.
# object   :   Object   -   Object to check type of
#
# Example:
#   voxel_type_of([Object]) -> VoxelTypes.VoxelMesh
#
static func voxel_type_of(object : Object) -> int:
	if object is VoxelSetClass:
		return VoxelTypes.VoxelSet
	elif object is VoxelEditorClass:
		return VoxelTypes.VoxelEditor
	elif object is VoxelObjectClass:
		return VoxelTypes.VoxelObject
	elif object is VoxelMesh:
		return VoxelTypes.VoxelMesh
	elif object is VoxelMultiMesh:
		return VoxelTypes.VoxelMultiMesh
	elif object is VoxelLayeredMesh:
		return VoxelTypes.VoxelLayeredMesh
	elif object is VoxelEmbeddedMultiMesh:
		return VoxelTypes.VoxelEmbeddedMultiMesh
	else: return VoxelTypes.NVT


# Set select of given object in editor.
# select   :   bool     -   whether to select or unselect
# object   :   Object   -   Object to select or unselect
#
# Example:
#   select(false, [Object])
#
func select(select : bool, object := HandledObject) -> void:
	if object is Node:
		if select: get_editor_interface().get_selection().add_node(object)
		else: get_editor_interface().get_selection().remove_node(object)

# Toggle selection of currently handled object.
#
# Example:
#   select_toggle()
#
func select_toggle() -> void:
	select(not get_editor_interface().get_selection().get_selected_nodes().has(HandledObject), HandledObject)


# Saves current scene if AutoSave is active.
#
# Example:
# _save()
#
func _save() -> void:
	if AutoSave:
		print('VoxelCore AUTOSAVE')
		get_editor_interface().save_scene()


# Sets VoxelObject to be edited by the VoxelEditor, and shows BottomPanel if appropriate.
# VoxelObject   :   VoxelObject   -   VoxelObject to edit.
# show          :   bool          -   whether to show bottom panel
#
# Example:
#   _edit([VoxelObject], false)
#
func _edit(VoxelObject : VoxelObjectClass, show := true) -> void:
	VoxelEditor.edit(VoxelObject)
	if not VoxelObject.is_connected('tree_exiting', self, 'handle_remove'):
		VoxelObject.connect('tree_exiting', self, 'handle_remove')
	if show: set_bottom_panel_visible(true)

# Commits the changes to the current VoxelObject being edited by VoxelEditor.
# hide       :   bool   -   whether to hide bottom panel
# unselect   :   bool   -   whether to unselect commited VoxelObject
#
# Example:
#   _commit(false, true)
#
func _commit(hide := true, unselect := false) -> void:
	if VoxelEditor.VoxelObject:
		VoxelEditor.VoxelObject.disconnect('tree_exiting', self, 'handle_remove')
		VoxelEditor.commit()
		if hide: set_bottom_panel_visible(false)
		if unselect: select(false, HandledObject)

# Cancels the changes to the current VoxelObject being edited by VoxelEditor.
# hide       :   bool   -   whether to hide bottom panel
# unselect   :   bool   -   whether to unselect commited VoxelObject
#
# Example:
#   _cancel(false, true)
#
func _cancel(hide := true, unselect := false) -> void:
	if VoxelEditor.VoxelObject:
		VoxelEditor.VoxelObject.disconnect('tree_exiting', self, 'handle_remove')
		VoxelEditor.cancel()
		if hide: set_bottom_panel_visible(false)
		if unselect: select(false, HandledObject)


# Load plugin.
func _enter_tree() -> void:
	add_autoload_singleton('VoxelSet', 'res://addons/Voxel-Core/defaults/VoxelSet.default.gd')
	
	
	connect('scene_closed', self, 'scene_closed')
	connect('main_screen_changed',self, 'main_screen_changed')
	
	
	print('Loaded Voxel-Core.')

# Setup plugin connections and etc.
func _setup() -> void:
	set_voxel_edit_undo_redo()
	
	
	if not VoxelEditor.is_connected('set_lock', self, 'select'):
		VoxelEditor.connect('set_lock', self, 'select')
	if not VoxelEditor.is_connected('script_changed', self, 'set_voxel_edit_undo_redo'):
		VoxelEditor.connect('script_changed', self, 'set_voxel_edit_undo_redo', [], CONNECT_DEFERRED)

func _init() -> void: _setup()
func _ready() -> void: _setup()

# Unload plugin.
func _exit_tree() -> void:
	disconnect('scene_closed', self, 'scene_closed')
	disconnect('main_screen_changed', self, 'main_screen_changed')
	
	VoxelEditor.disconnect('set_lock', self, 'select')
	VoxelEditor.disconnect('script_changed', self, 'set_voxel_edit_undo_redo')
	
	
	remove_autoload_singleton('VoxelSet')
	set_bottom_panel_visible(false)
	
	
	print('Unloaded Voxel-Core.')


# Calls on _cancel when a scene is closed.
# path   :   String   -   path to scene closed
#
# Example:
#   scene_closed("res://examples/Simple.tscn")
#
func scene_closed(path : String) -> void:
	_cancel()

# Sets MainScene ,and shows and hides bottom panel as appropriate.
# mainscene   :   String   -   mainscene currently active
#
# Example:
#    main_screen_changed('2D')
#
func main_screen_changed(mainscene : String) -> void:
	MainScene = mainscene
	
	if mainscene == '3D' and voxel_type_of(HandledObject) >= VoxelTypes.VoxelObject:
		_edit(HandledObject)
	else:
		var modified := VoxelEditor.Modified
		if AutoSave: _commit()
		else: _cancel()
		if modified and not VoxelEditor.Lock: _save()

# Handles objects selected in-editor.
# object   :   Object   -   Object selected in-editor.
#
# Example:
#   handle([Object])
#
func handles(object : Object) -> bool:
	HandledObject = object
	if voxel_type_of(object) >= VoxelTypes.VoxelObject:
		if object == VoxelEditor.VoxelObject:
			if not VoxelEditor.Lock: select(false)
		else:
			if VoxelEditor.VoxelObject:
				if AutoSave: _commit(false)
				else: _cancel(false)
			_edit(object)
		return true
	else:
		if VoxelEditor.VoxelObject:
			select(false, VoxelEditor.VoxelObject)
			if AutoSave: _commit()
			else: _cancel()
		else: set_bottom_panel_visible(false)
		return false

# Called whenever Lock of VoxelEditor is called, calls on _save if unlocked and VoxelObject being edited is modified.
# lock   :   bool   -   value of lock
#
# Example:
#   handle_lock(false)
#
func handle_lock(lock : bool) -> void:
	if lock and VoxelEditor.Modified:
		_save()

# Called whenever a object is removed.
#
# Example:
#   handle_remove()
#
func handle_remove() -> void:
	if AutoSave: _commit()
	else: _cancel()

# Forwards Spatial input when Object selected is a VoxelObject to VoxelEditor.
# camera     :   Camera       -   current in-engine camera
# event      :   InputEvent   -   event to be handled
# @returns   :   bool         -   whether input event has been consumed
#
# Example:
#    forward_spatial_gui_input([Camera], [InputEvent]) -> true
#
func forward_spatial_gui_input(camera : Camera, event : InputEvent) -> bool:
	return VoxelEditor.__input(event, camera)
