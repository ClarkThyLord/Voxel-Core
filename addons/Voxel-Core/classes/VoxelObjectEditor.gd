tool
extends Reference
class_name VoxelObjectEditor, "res://addons/Voxel-Core/assets/classes/VoxelEditor.png"



#
# VoxelObjectEditor, 
#



# Refrences
const VoxelObject := preload("res://addons/Voxel-Core/classes/VoxelObject.gd")



# Declarations
signal set_tools

var Tools := [] setget set_tools
func set_tools(tools : Array) -> void:
	Tools = tools
	
	emit_signal("set_tools")



# Utilities
func raycast(camera : Camera, screen_point : Vector2, ray_length := 1000.0, exclude := []) -> Dictionary:
	var from = camera.project_ray_origin(screen_point)
	var to = from + camera.project_ray_normal(screen_point) * ray_length
	return camera.get_world().direct_space_state.intersect_ray(from, to, exclude)

func raycast_for(targets : Array, camera : Camera, screen_point : Vector2, ray_length := 1000.0) -> Dictionary:
	var exclude := []
	var hit : Dictionary
	var from = camera.project_ray_origin(screen_point)
	var to = from + camera.project_ray_normal(screen_point) * 1000
	while true:
		hit = camera.get_world().direct_space_state.intersect_ray(from, to, exclude)
		if not hit.empty():
			for target in targets:
				if target.is_a_parent_of(hit.collider):
					hit["target"] = target
					break
			exclude.append(hit.collider)
		else: break
	return hit



# Core
func input(event : InputEvent, camera : Camera) -> void:
	pass
