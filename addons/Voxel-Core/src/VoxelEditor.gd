tool
extends Spatial



# VoxelEditor:
# This is a makeshift abstract class intended to be inherited by all classes that will edit Voxels.
# NOTE: This class is intended to be inherited, and isn't meant to be instanced itself!



# Refrences
const VoxelObjectClass = preload('res://addons/Voxel-Core/src/VoxelObject.gd')



# Declarations
# Sets the given options
# options   :   Dictionary   -   options to set
#
# Example:
#   set_options({ property: value })
#
func set_options(options := DefaultOptions) -> void:
	for option in options.keys():
		self.set(option, options[option])

export(Dictionary) var DefaultOptions : Dictionary setget set_default_options   #   Default options
# Setter for DefaultOptions.
# defaultoptions   :   Dictionary   -   value to set
# reset            :   bool         -   whether to set given options
#
# Example:
#   set_default_options({ property: value }, true)
#
func set_default_options(defaultoptions := {
		'Lock': true
	}, reset := false) -> void:
	DefaultOptions = defaultoptions
	_save()
	if reset: set_options()


var VoxelObject : VoxelObjectClass setget edit                             #   VoxelObject being edited
var VoxelObjectData : Dictionary = {} setget set_voxel_object_data         #   Stores specified data from VoxelObject before being modified
func set_voxel_object_data(voxelobjectdata : Dictionary) -> void: return   #   VoxelObjectData shouldn't be settable externally


# Core
func _load() -> void:
	if has_meta('DefaultOptions'): set_default_options(get_meta('DefaultOptions'), true)

func _save() -> void:
	set_meta('DefaultOptions', DefaultOptions)


# The following will initialize the object as needed
# NOTE: Should be copied pasted to inheriting class
#func _init() -> void:
#	set_default_options()
#	_load()
#func _ready() -> void:
#	set_default_options()
#	set_options()
#	_load()


signal editing
# Start editing given VoxelObject, and commit previous VoxelObject if present, emits 'editing'.
# voxelobject   :   VoxelObject   -   VoxelObject to be edited
# options       :   Dictionary    -   options to set
# update        :   bool          -   whether to update VoxelObject
# emit          :   bool          -   true, emit signal; false, don't emit signal
#
# Example:
#   edit([VoxelObject], { property: value }, false, false)
#
func edit(voxelobject : VoxelObjectClass, options := {}, update := true, emit := true) -> void:
	commit(true, true)
	
	set_options(DefaultOptions if options.get('reset', false) else options)
	VoxelObject = voxelobject
	VoxelObject.set_editing(true, false)
	if update: VoxelObject.update()                                  #   TODO: update only modified meshes, instead of all meshes
	
	if emit: emit_signal('editing')

signal committed
# Commits VoxelObject currently being edited, emits 'committed'
# update   :   bool   -   whether to update VoxelObject
# emit     :   bool   -   true, emit signal; false, don't emit signal
#
# Example:
#   commit(false, false)
#
func commit(update := true, emit := true) -> void:
	if VoxelObject and VoxelObject is VoxelObjectClass:
		VoxelObject.set_editing(false, false)
		if update: VoxelObject.update()
		
		VoxelObject = null
		VoxelObjectData = {}
		
		if emit: emit_signal('committed')


# Handles events
# event      :   InputEvent   -   InputEvent to be handled
# camera     :   Camera       -   curernt Camera
# @returns   :   bool         -   whether InputEvent has been used
#
# Example:
#   _input([InputEvent], [Camera]) -> true
#
func __input(event : InputEvent, camera := get_viewport().get_camera()) -> bool:
	return false
