tool
extends Control
class_name VoxelEditorGUI, 'res://addons/VoxelCore/assets/VoxelEditorGUI.png'



# Declarations
var fix_level : int = 0
func is_fixed_level(fixed_level : int = 1) -> bool:
	fix_level += 1
	return fix_level == fixed_level


signal set_voxeleditorowner(voxeleditorowner)
var VoxelEditorOwner : VoxelEditor setget set_voxeleditorowner
func set_voxeleditorowner(voxeleditorowner : VoxelEditor, emit : bool = true) -> void:
	VoxelEditorOwner = voxeleditorowner

	if emit: emit_signal('set_voxeleditorowner', VoxelEditorOwner)

export(NodePath) var VoxelEditorOwnerPath : NodePath = NodePath('/root/CoreVoxelEditor') setget set_voxeleditorownerpath
# Sets the path to VoxelEditorOwner, and the VoxelEditorOwner in itself
# voxeleditorownerpath   :   NodePath   -   path to VoxelEditor to be set as VoxelEditorOwner
#
# Example:
#   set_voxeleditorownerpath([NodePath])
#
func set_voxeleditorownerpath(voxeleditorownerpath : NodePath, emit : bool = true) -> void:
	if is_inside_tree() and get_node(voxeleditorownerpath) is VoxelEditor:
		set_voxeleditorowner(get_node(voxeleditorownerpath), emit)
		VoxelEditorOwnerPath = voxeleditorownerpath


signal set_active(active, voxelobject, options)
var Active : bool = false setget set_active
# Sets the VoxelEditor's GUI active status
# active        :   bool          -   true, is active and visible; false, is not active and invisible
# voxelobject   :   VoxelObject   -   VoxelObject to be edited
# options       :   Dictionary    -   options for custom usage ::
#                                      clear           :   bool         :   clear if set inactive
#                                      commit_voxels   :   Dictionary   :   voxels to commit when set inactive
# emit          :   bool          -   true, emit 'set_active' signal; false, don't emit 'set_active' signal
#
# Example:
#   set_active(true, [VoxelObject], { ... }, false)
#
func set_active(active : bool = !Active, voxelobject = null, options : Dictionary = {}, emit : bool = true) -> void:
	Active = active
	visible = active

	if options.get('prompt') == 'commit': VoxelEditorOwner.commit(options.get('voxels'), emit)
	elif options.get('prompt') == 'clear': VoxelEditorOwner.clear(emit)

	if voxelobject: VoxelEditorOwner.begin(voxelobject, active, emit)

	if emit: emit_signal('set_active', active, voxelobject, options)



# Core
func _ready() -> void:
	fix_level = 0
	if is_fixed_level(): set_voxeleditorownerpath(VoxelEditorOwnerPath)


# Quick way to send a event to VoxelEditorOwner to be handled
# event    :   InputEvent   :   event to be sent to VoxelEditorOwner
# camera   :   Camera       :   camera refrence to be sent with event to VoxelEditorOwner
#
# Example:
#   handle_input([InputEvent], [Camera]) -> true
#
func handle_input(event : InputEvent, camera : Camera = get_viewport().get_camera()) -> bool:
	return VoxelEditorOwner.handle_input(event, camera) if VoxelEditorOwner else false
