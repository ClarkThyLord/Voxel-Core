tool
extends Spatial



# VoxelEditor:
# This is a makeshift abstract class intended to be inherited by all classes that will edit Voxels.
# NOTE: This class is intended to be inherited, and isn't meant to be instanced itself!



# Refrences
const VoxelObjectClass = preload('res://addons/Voxel-Core/src/VoxelObject.gd')



# Declarations
var undo_redo := UndoRedo.new()


signal set_lock(lock)
export(bool) var Lock := true setget set_lock
func set_lock(lock := !Lock, emit := true) -> void:
	Lock = lock
	if emit: emit_signal('set_lock', Lock)


func set_options(options := DefaultOptions) -> void:
	for option in options.keys():
		self.set(option, options[option])

export(Dictionary) var DefaultOptions : Dictionary setget set_default_options
func set_default_options(defaultoptions := {
		'Lock': true
	}, reset := false) -> void:
	DefaultOptions = defaultoptions
	_save()
	if reset: set_options()


var VoxelObject : VoxelObjectClass setget edit
var VoxelObjectData : Dictionary = {} setget set_voxel_object_data
func set_voxel_object_data(voxelobjectdata : Dictionary) -> void: return   #   VoxelObjectData shouldn't be settable externally


# Core
func _load() -> void:
	if has_meta('DefaultOptions'): set_default_options(get_meta('DefaultOptions'), true)

func _save() -> void:
	set_meta('DefaultOptions', DefaultOptions)


# The following will initialize the object as needed
func _init() -> void: _load()
func _ready() -> void:
	set_default_options()
	set_options()
	_load()


signal editing
func edit(voxelobject : VoxelObjectClass, options := {}, emit := true) -> void:
	if VoxelObjectClass and VoxelObject is VoxelObjectClass:
		cancel(emit)
	
	set_options(DefaultOptions if options.get('reset', false) else options)
	VoxelObject = voxelobject
	VoxelObjectData = {
		'voxels': voxelobject.get_voxels(),               #   TODO: store only modified data, instead of all the data
		'MeshType': voxelobject.MeshType,
		'BuildStaticBody': voxelobject.BuildStaticBody,
	}
	voxelobject.set_mesh_type(VoxelObjectClass.MeshTypes.NAIVE, false, false)
	voxelobject.set_build_static_body(true, false, false)
	voxelobject.update()                                  #   TODO: update only modified meshes, instead of all meshes
	
	if emit: emit_signal('editing')

signal committed
func commit(emit := true) -> void:
	VoxelObject.set_mesh_type(VoxelObjectData['MeshType'], false, false)
	VoxelObject.set_build_static_body(VoxelObjectData['BuildStaticBody'], false, false)
	
	VoxelObject.update()
	
	VoxelObject = null
	VoxelObjectData = {}
	undo_redo.clear_history()
	
	if emit: emit_signal('committed')

signal canceled
func cancel(emit := true) -> void:
	VoxelObject.set_voxels(VoxelObjectData['voxels'], false)
	VoxelObject.set_mesh_type(VoxelObjectData['MeshType'], false, false)
	VoxelObject.set_build_static_body(VoxelObjectData['BuildStaticBody'], false, false)
	
	VoxelObject.update()
	
	VoxelObject = null
	VoxelObjectData = {}
	undo_redo.clear_history()
	
	if emit: emit_signal('canceled')


func __input(event : InputEvent, camera := get_viewport().get_camera()):
	pass
