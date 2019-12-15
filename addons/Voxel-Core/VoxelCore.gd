tool
extends EditorPlugin



# Refrences
const VoxelSetClass = preload('res://addons/Voxel-Core/src/VoxelSet.gd')
const VoxelEditorClass = preload('res://addons/Voxel-Core/src/VoxelEditor.gd')
const VoxelObjectClass = preload('res://addons/Voxel-Core/src/VoxelObject.gd')

const VoxelEditorEngineClass = preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')



# Declarations
var MainScene := ''

signal set_auto_save(autosave)
var AutoSave := true setget set_auto_save
func set_auto_save(autosave := !AutoSave, emit := true) -> void:
	AutoSave = autosave
	if emit: emit_signal('set_auto_save', AutoSave)


var VoxelEditor := VoxelEditorEngineClass.new()
func set_voxel_edit_undo_redo() -> void: VoxelEditor.undo_redo = get_undo_redo()


var BottomPanel : ToolButton
var BottomPanelVisible := false
var BottomPanelControl := preload('res://addons/Voxel-Core/engine/gui/BottomPanel.tscn').instance()
func set_bottom_panel_visible(visible := !BottomPanelControl.visible) -> void:
	if visible and not BottomPanelVisible:
		BottomPanel = add_control_to_bottom_panel(BottomPanelControl, 'Voxel-Core')
		make_bottom_panel_item_visible(BottomPanelControl)
		BottomPanelVisible = true
	elif not visible and BottomPanelVisible:
		hide_bottom_panel()
		remove_control_from_bottom_panel(BottomPanelControl)
		BottomPanelVisible = false



# Core
enum VoxelTypes { NVT = -1, VoxelSet, VoxelEditor, VoxelObject, VoxelMesh, VoxelMultiMesh, VoxelLayeredMesh, VoxelEmbeddedMultiMesh }
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


func select(object, select) -> void:
	if select: get_editor_interface().get_selection().add_node(object)
	else: get_editor_interface().get_selection().remove_node(object)


func _save(msg := 'SAVED VOXEL OBJECT CHANGES') -> void:
	print()
	get_editor_interface().save_scene()


func _edit(VoxelObject : VoxelObjectClass, show := true) -> void:
	VoxelEditor.Lock = true
	VoxelEditor.edit(VoxelObject)
	if show: set_bottom_panel_visible(true)

func _commit(hide := true) -> void:
	VoxelEditor.commit()
	if hide: set_bottom_panel_visible(false)
	_save()

func _cancel(hide := true) -> void:
	VoxelEditor.cancel()
	if hide: set_bottom_panel_visible(false)
	_save('CANCELED VOXEL OBJECT CHANGES')


func _enter_tree() -> void:
	add_autoload_singleton('VoxelSet', 'res://addons/Voxel-Core/defaults/VoxelSet.default.gd')
	
	connect('scene_closed', self, 'scene_closed')
	connect('scene_changed', self, 'engine_ready', [], CONNECT_ONESHOT)
	
	print('Loaded Voxel-Core.')

# Called once after everything in the engine, including this plugin, is setup.
# starting_scene   :   Node   -   Scene the engine opened with
#
# Example:
#   engine_ready([Node])
#
func engine_ready(starting_scene) -> void:
	set_voxel_edit_undo_redo()
	VoxelEditor.connect('script_changed', self, 'set_voxel_edit_undo_redo', [], CONNECT_DEFERRED)
	BottomPanelControl.set_voxel_edit(VoxelEditor)

func _exit_tree() -> void:
	remove_autoload_singleton('VoxelSet')
	
	BottomPanelControl.queue_free()
	
	disconnect('scene_closed', self, 'scene_closed')
	
	print('Unloaded Voxel-Core.')


func scene_closed(path : String) -> void:
	VoxelEditor.Lock = true
	_cancel()

func main_screen_changed(mainscene : String) -> void:
	MainScene = mainscene
	
	if mainscene == '3D' and VoxelEditor.VoxelObject:
		set_bottom_panel_visible(true)
	else:
		if VoxelEditor.Lock == false and VoxelEditor.VoxelObject:
			VoxelEditor.Lock = true
			_save()
		set_bottom_panel_visible(false)

func handles(object) -> bool:
	if voxel_type_of(object) >= VoxelTypes.VoxelObject:
		if AutoSave: _commit(false)
		else: _cancel(false)
		_edit(object)
		return true
	else: return false

func forward_spatial_gui_input(camera, event) -> bool:
	return VoxelEditor.__input(event, camera)

func _unhandled_key_input(event) -> void:
	if false:
		get_tree().set_input_as_handled()
