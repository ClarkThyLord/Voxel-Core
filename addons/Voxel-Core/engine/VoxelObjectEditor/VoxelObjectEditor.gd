tool
extends Control



# Refrences



# Declarations
var Undo_Redo : UndoRedo

var VoxelObject setget begin



# Core
func _ready():
	if not is_instance_valid(Undo_Redo):
		Undo_Redo = UndoRedo.new()


func begin(voxelobject) -> void:
	cancel()
	
	VoxelObject = voxelobject

func commit() -> void:
	pass

func cancel() -> void:
	pass


func handle_input(camera : Camera, event : InputEvent) -> bool:
	return false
