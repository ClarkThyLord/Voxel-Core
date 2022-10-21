@tool
extends EditorPlugin



# Built-In Virtual Methods
func _enter_tree():
	print("Voxel-Core is active!")


func _exit_tree():
	print("Voxel-Core is inactive!")
