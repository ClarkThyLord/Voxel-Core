tool
extends Control



# Imports
const VoxelGrid := preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelGrid/VoxelGrid.gd")
const VoxelCursor := preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelCursor/VoxelCursor.gd")

const VoxelObject := preload("res://addons/Voxel-Core/classes/VoxelObject.gd")



# Refrences
onready var VoxelSetViewer := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VoxelSetViewer")



# Declarations
var Undo_Redo : UndoRedo


var Grid := VoxelGrid.new() setget set_grid
func set_grid(grid : VoxelGrid) -> void: pass

var Cursors := {
	Vector3(0, 0, 0): VoxelCursor.new(),
	Vector3(1, 0, 0): VoxelCursor.new(),
	Vector3(1, 1, 0): VoxelCursor.new(),
	Vector3(1, 1, 1): VoxelCursor.new(),
	Vector3(0, 1, 1): VoxelCursor.new(),
	Vector3(0, 1, 0): VoxelCursor.new(),
	Vector3(0, 0, 1): VoxelCursor.new(),
	Vector3(1, 0, 1): VoxelCursor.new()
} setget set_cursors
func set_cursors(cursors : Dictionary) -> void: pass


var VoxelObjectRef : VoxelObject setget begin



# Core
func _ready():
	if not is_instance_valid(Undo_Redo):
		Undo_Redo = UndoRedo.new()

func _exit_tree():
	Grid.queue_free()
	for cursor in Cursors:
		Cursors[cursor].queue_free()


func begin(voxelobject : VoxelObject) -> void:
	cancel()
	
	VoxelObjectRef = voxelobject
	VoxelSetViewer.set_voxel_set(VoxelObjectRef.Voxel_Set)
	VoxelObjectRef.connect("set_voxel_set", VoxelSetViewer, "set_voxel_set")

func commit() -> void:
	cancel()

func cancel() -> void:
	if is_instance_valid(VoxelObjectRef):
		VoxelObjectRef.disconnect("set_voxel_set", VoxelSetViewer, "set_voxel_set")
	VoxelObjectRef = null


func handle_input(camera : Camera, event : InputEvent) -> bool:
	return false
