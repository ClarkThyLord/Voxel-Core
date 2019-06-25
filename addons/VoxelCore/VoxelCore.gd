tool
extends EditorPlugin



# Imports
const VoxelCoreDock = preload('res://addons/VoxelCore/VoxelCore/dock.tscn')

const MagicaVoxelMesh = preload('res://addons/VoxelCore/VoxelCore/imports/MagicaVoxel/MagicaVoxel.Mesh.gd')
const MagicaVoxelVoxelObject = preload('res://addons/VoxelCore/VoxelCore/imports/MagicaVoxel/MagicaVoxel.VoxelObject.gd')



# Utils
# Setter for AutoSave
# object     :   Object   -   Object to test for
# @returns   :   int      -   Type of VoxelCore object
# 
# Example:
#   is_voxelcore([Object]) -> 2
#
static func is_voxelcore(object : Object) -> int:
	if object is VoxelObject: return 1
	elif object is VoxelEditor: return 2
	elif object is VoxelEditorGUI: return 3
	elif object is VoxelSet: return 4
	else: return 0



# Declarations
# Name of current screen(e.g. 2D, 3D, Script and etc.)
var ScreenName : String = ''
var ObjectHandled : Object


# Instances for used objects in plugin
var VoxelCoreDockInstance
var MagicaVoxelMeshInstance : MagicaVoxelMesh = MagicaVoxelMesh.new()
var MagicaVoxelVoxelObjectInstance : MagicaVoxelVoxelObject = MagicaVoxelVoxelObject.new()


func set_editing(editing : bool, save : bool = false):
	if editing and get_node('/root/CoreVoxelEditorGUI').Active: return;
	
	if ObjectHandled: select_toggle(!editing)
	
	if editing and CustomEditor: get_node('/root/CoreVoxelEditorGUI').set_active(true)
	
	if save: save()


signal set_autosave(autosave)
# Whether to automatically save changes whenever committing VoxelObject changes
var AutoSave : bool = true setget set_autosave
# Setter for AutoSave
# autosave   :   bool   -   true, AutoSave is enabled; false, AutoSave is disabled
# emit       :   bool   -   true, emit 'set_autosave' signal; false, don't emit 'set_autosave' signal
#
# Example:
#   set_autosave(false, false)
#
func set_autosave(autosave : bool = !AutoSave, emit : bool = true) -> void:
	AutoSave = autosave
	
	if emit: emit_signal('set_autosave', autosave)


signal set_custom_editor(active)
# Whether to use custom editor, VoxelEditorGUI.default, in-engine or not
var CustomEditor : bool = false setget set_custom_editor
# Setter for CustomEditor
# autosave   :   bool   -   true, CustomEditor is enabled; false, CustomEditor is disabled
# emit       :   bool   -   true, emit 'set_custom_editor' signal; false, don't emit 'set_custom_editor' signal
#
# Example:
#   set_custom_editor(false, false)
#
func set_custom_editor(active : bool = !CustomEditor, emit : bool = true) -> void:
	CustomEditor = active
	
	if emit: emit_signal('set_custom_editor', active)


# Whether GUI is visible or not
var GuiVisible : bool = false setget set_gui_visible
# Setter for GuiVisible
# visible   :   bool   -   true, GUI will be set visible; false, GUI will be set invisible
#
# Example:
#   set_gui_visible(false)
#
func set_gui_visible(visible : bool = !GuiVisible) -> void:
	if has_node('/root/CoreVoxelEditor'):
		if visible && VoxelCoreDockInstance == null:
			VoxelCoreDockInstance = VoxelCoreDock.instance()
			connect('set_custom_editor', VoxelCoreDockInstance, 'set_custom_editor')
			VoxelCoreDockInstance.connect('set_custom_editor', self, 'set_custom_editor')
			connect('set_autosave', VoxelCoreDockInstance, 'set_autosave')
			VoxelCoreDockInstance.connect('set_autosave', self, 'set_autosave')
		
			get_node('/root/CoreVoxelEditor').connect('cleared', self, 'set_gui_visible', [false])
		
			add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, VoxelCoreDockInstance)
			
			VoxelCoreDockInstance.set_custom_editor(CustomEditor)
			VoxelCoreDockInstance.set_autosave(AutoSave)
		elif !visible && VoxelCoreDockInstance != null:
			disconnect('set_custom_editor', VoxelCoreDockInstance, 'set_custom_editor')
			disconnect('set_autosave', VoxelCoreDockInstance, 'set_autosave')
			
			get_node('/root/CoreVoxelEditor').disconnect('cleared', self, 'set_gui_visible')
			
			remove_control_from_docks(VoxelCoreDockInstance)
			VoxelCoreDockInstance.queue_free()
			VoxelCoreDockInstance = null
		
		GuiVisible = visible



# Core
# Setup everything the plugin will use in-engine and in-game
func _enter_tree() -> void:
	add_autoload_singleton('CoreVoxelSet', 'res://addons/VoxelCore/src/VoxelSet/VoxelSet.default.gd')
	add_autoload_singleton('CoreVoxelEditor', 'res://addons/VoxelCore/src/VoxelEditor.gd')
	add_autoload_singleton('CoreVoxelEditorGUI', 'res://addons/VoxelCore/src/VoxelEditorGUI/VoxelEditorGUI.default.tscn')

	add_custom_type('VoxelObject', 'MeshInstance', load('res://addons/VoxelCore/src/VoxelObject.gd'), preload('res://addons/VoxelCore/assets/VoxelCore.png'))
	add_custom_type('VoxelEditor', 'Spatial', load('res://addons/VoxelCore/src/VoxelEditor.gd'), preload('res://addons/VoxelCore/assets/VoxelEditor.png'))
	add_custom_type('VoxelEditorGUI', 'Control', load('res://addons/VoxelCore/src/VoxelEditorGUI.gd'), preload('res://addons/VoxelCore/assets/VoxelEditorGUI.png'))

	add_import_plugin(MagicaVoxelMeshInstance)
	add_import_plugin(MagicaVoxelVoxelObjectInstance)
	
	connect('scene_closed', self, 'scene_closed')
	connect('main_screen_changed', self, 'main_screen_changed')
	connect('scene_changed', self, 'engine_ready', [], CONNECT_ONESHOT)
	
	print('VoxelCore loaded!')

# Remove everything the plugin uses; since the plugin is being disabled
func _exit_tree() -> void:
	remove_autoload_singleton('CoreVoxelSet')
	remove_autoload_singleton('CoreVoxelEditor')
	remove_autoload_singleton('CoreVoxelEditorGUI')

	remove_custom_type('VoxelObject')
	remove_custom_type('VoxelEditor')
	remove_custom_type('VoxelEditorGUI')

	remove_import_plugin(MagicaVoxelMeshInstance)
	remove_import_plugin(MagicaVoxelVoxelObjectInstance)

	disconnect('scene_closed', self, 'scene_closed')
	disconnect('main_screen_changed', self, 'main_screen_changed')
	
	print('VoxelCore unloaded!')


# Called once after everything in the engine, including this plugin, is setup
# starting_scene   :   Node   -   Scene the engine opened with
#
# Example:
#   engine_ready([Node])
#
func engine_ready(starting_scene):
	set_voxeleditor_undo_redo()
	get_node('/root/CoreVoxelEditor').connect('script_changed', self, 'set_voxeleditor_undo_redo', [], CONNECT_DEFERRED)
	get_node('/root/CoreVoxelEditor').connect('set_edit', self, 'set_editing')
	
	get_node('/root/CoreVoxelEditorGUI').connect('set_custom_editor', self, 'set_custom_editor')


func scene_closed(node : Node) -> void:
	if has_node('/root/CoreVoxelEditor'):
		get_node('/root/CoreVoxelEditor').clear()
		get_node('/root/CoreVoxelEditor').Edit = false

func main_screen_changed(screen_name : String) -> void:
	ScreenName = screen_name
	
	if has_node('/root/CoreVoxelEditor'):
		if get_node('/root/CoreVoxelEditor').VoxelObjectRef and screen_name == '3D': set_gui_visible(true)
		else:
			if get_node('/root/CoreVoxelEditor').Edit and get_node('/root/CoreVoxelEditor').VoxelObjectRef:
				get_node('/root/CoreVoxelEditor').Edit = false
				save()
			set_gui_visible(false)

func handles(object : Object) -> bool:
	if has_node('/root/CoreVoxelEditor'):
		if is_voxelcore(object) == 1:
			ObjectHandled = object
			
			if object != get_node('/root/CoreVoxelEditor').VoxelObjectRef:
				get_node('/root/CoreVoxelEditor').begin(object)
				if ScreenName == '3D': set_gui_visible(true)
			else: select_toggle()
			
			return true
		else:
			ObjectHandled = null
			
			if get_node('/root/CoreVoxelEditor').VoxelObjectRef != null:
				get_node('/root/CoreVoxelEditor').commit()
			set_gui_visible(false)
			
			return false
	else: return false


func forward_spatial_gui_input(camera : Camera, event : InputEvent) -> bool:
	return get_node('/root/CoreVoxelEditor').handle_input(event, camera) if has_node('/root/CoreVoxelEditor') and !CustomEditor else false

func _unhandled_key_input(event : InputEventKey) -> void:
	if has_node('/root/CoreVoxelEditor') and GuiVisible and event is InputEventKey and !event.pressed:
		if !Input.is_mouse_button_pressed(BUTTON_RIGHT) and get_node('/root/CoreVoxelEditor').Edit:
			match event.scancode:
				KEY_SPACE:
					get_node('/root/CoreVoxelEditor').set_edit()
					if AutoSave: save()
				KEY_ALT:
					save()
				KEY_A:
					get_node('/root/CoreVoxelEditor').set_tool(VoxelEditor.Tools.ADD)
				KEY_S:
					get_node('/root/CoreVoxelEditor').set_tool(VoxelEditor.Tools.REMOVE)
				KEY_D:
					get_node('/root/CoreVoxelEditor').set_tool(VoxelEditor.Tools.PAINT)
				KEY_G:
					get_node('/root/CoreVoxelEditor').set_tool(VoxelEditor.Tools.COLOR_PICKER)
				KEY_C:
					VoxelCoreDockInstance.paint_color_visible()
				KEY_Q:
					get_node('/root/CoreVoxelEditor').set_mirror_x()
				KEY_W:
					get_node('/root/CoreVoxelEditor').set_mirror_y()
				KEY_E:
					get_node('/root/CoreVoxelEditor').set_mirror_z()
			
			get_tree().set_input_as_handled()
		elif event is InputEventKey and !event.pressed and event.scancode == KEY_SPACE:
			get_node('/root/CoreVoxelEditor').set_edit()
			
			get_tree().set_input_as_handled()


# Save current engine scene
func save():
	print('SAVED VOXEL OBJECT')
	get_editor_interface().save_scene()


# Sets CoreVoxelEditor's UndoRedo to the Engine's UndoRedo
func set_voxeleditor_undo_redo(): get_node('/root/CoreVoxelEditor').undo_redo = get_undo_redo()


# Called once after everything in the engine, including this plugin, is setup
# node     :   Node   -   Scene the engine opened with
# select   :   bool   -   true, node will become selected; false, node will become select_toggle
#
# Example:
#   select_toggle([Node], false)
#
func select_toggle(select : bool = !get_node('/root/CoreVoxelEditor').Edit, object := ObjectHandled) -> void:
	if object:
		if select: get_editor_interface().get_selection().add_node(object)
		else: get_editor_interface().get_selection().remove_node(object)
