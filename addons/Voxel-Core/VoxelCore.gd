tool
extends EditorPlugin



# Refrences
const VoxelSetClass = preload('res://addons/Voxel-Core/src/VoxelSet.gd')
const VoxelEditorClass = preload('res://addons/Voxel-Core/src/VoxelEditor.gd')
const VoxelObjectClass = preload('res://addons/Voxel-Core/src/VoxelObject.gd')

const VoxelEditorEngineClass = preload('res://addons/Voxel-Core/engine/VoxelEditor.engine.gd')



# Declarations
signal set_auto_save(autosave)
var AutoSave := true setget set_auto_save
func set_auto_save(autosave := !AutoSave, emit := true) -> void:
	AutoSave = autosave
	if emit: emit_signal('set_auto_save', AutoSave)


var VoxelEditor := VoxelEditorEngineClass.new()
func set_voxel_edit_undo_redo() -> void: VoxelEditor.undo_redo = get_undo_redo()


var BottomPanel : ToolButton
var BottomPanelControl := preload('res://addons/Voxel-Core/engine/gui/BottomPanel.tscn').instance()



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


func _edit(VoxelObject : VoxelObjectClass, show := true) -> void:
	if show:
		BottomPanel = add_control_to_bottom_panel(BottomPanelControl, 'Voxel-Core')
		make_bottom_panel_item_visible(BottomPanelControl)
	VoxelEditor.edit(VoxelObject)

func _commit(hide := true) -> void:
	if hide:
		hide_bottom_panel()
		remove_control_from_bottom_panel(BottomPanelControl)
	VoxelEditor.commit()

func _cancel(hide := true) -> void:
	if hide:
		hide_bottom_panel()
		remove_control_from_bottom_panel(BottomPanelControl)
	VoxelEditor.cancel()


func _enter_tree() -> void:
	add_autoload_singleton('VoxelSet', 'res://addons/Voxel-Core/defaults/VoxelSet.default.gd')
	
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
	
	print('Unloaded Voxel-Core.')


func scene_closed(path : String) -> void:
	pass

func scene_changed(scene : Node) -> void:
	pass

func main_screen_changed(scene : String) -> void:
	pass

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
