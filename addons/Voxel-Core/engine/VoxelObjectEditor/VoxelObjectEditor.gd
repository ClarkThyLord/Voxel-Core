tool
extends Control



# Imports
const VoxelGrid := preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelGrid/VoxelGrid.gd")
const VoxelCursor := preload("res://addons/Voxel-Core/engine/VoxelObjectEditor/VoxelCursor/VoxelCursor.gd")

const VoxelObject := preload("res://addons/Voxel-Core/classes/VoxelObject.gd")



# Refrences
onready var Raw := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Raw")

onready var Tool := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/Tool")
onready var Palette := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/Palette")
onready var SelectMode := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/SelectMode")

onready var MirrorX := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer2/MirrorX")
onready var MirrorY := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer2/MirrorY")
onready var MirrorZ := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer2/MirrorZ")

onready var ColorChooser := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer3/ColorChooser")
onready var ColorPicked := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer3/ColorChooser/ColorPicked")

onready var VoxelSetViewer := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer/VoxelSetViewer")


onready var Lock := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/Lock")
onready var Commit := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/Commit")
onready var Cancel := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/Cancel")

onready var More := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer2/More")


onready var Settings := get_node("VoxelObjectEditor/HBoxContainer/VBoxContainer3/Settings")



# Declarations
signal editing(state)
signal close


var Undo_Redo : UndoRedo


var last_position


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

func set_cursors_visibility(visible := not Lock.pressed) -> void:
	for cursor in Cursors.values():
		cursor.visible = visible

func set_cursors_position(position : Vector3) -> void: 
	Cursors[Vector3.ZERO].Selections = [position]


enum Tools { ADD, SUB }


var VoxelObjectRef : VoxelObject setget begin



# Utilities
func raycast_for(camera : Camera, screen_position : Vector2, target : Node) -> Dictionary:
	var hit := {}
	var exclude := []
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * 1000
	while true:
		hit = camera.get_world().direct_space_state.intersect_ray(from, to, exclude)
		if not hit.empty():
			if target.is_a_parent_of(hit.collider): break
			else: exclude.append(hit.collider)
		else: break
	return hit



# Core
func _ready():
	if not is_instance_valid(Undo_Redo):
		Undo_Redo = UndoRedo.new()
	
	Tool.clear()
	for tool_ in Tools.keys():
		Tool.add_icon_item(
			load("res://addons/Voxel-Core/assets/controls/" + tool_.to_lower() + ".png"),
			tool_,
			Tools[tool_]
		)
	
	for tab in range(More.get_tab_count()):
		var name : String = More.get_tab_title(tab)
		More.set_tab_icon(tab, load("res://addons/Voxel-Core/assets/controls/" + name.to_lower() + ".png"))
	
	for tab in range(Settings.get_tab_count()):
		var name : String = Settings.get_tab_title(tab)
		Settings.set_tab_icon(tab, load("res://addons/Voxel-Core/assets/controls/" + name.to_lower() + ".png"))

func _exit_tree():
	Grid.queue_free()
	for cursor in Cursors:
		Cursors[cursor].queue_free()


func begin(voxelobject : VoxelObject) -> void:
	cancel()
	
	VoxelObjectRef = voxelobject
	VoxelObjectRef.EditHint = true
	VoxelObjectRef.add_child(Grid)
	for cursor in Cursors.values():
		VoxelObjectRef.add_child(cursor)
	VoxelSetViewer.set_voxel_set(VoxelObjectRef.Voxel_Set)
	VoxelObjectRef.connect("tree_exiting", self, "cancel", [true])
	VoxelObjectRef.connect("set_voxel_set", VoxelSetViewer, "set_voxel_set")

func commit() -> void:
	cancel()

func cancel(close := false) -> void:
	if is_instance_valid(VoxelObjectRef):
		VoxelObjectRef.EditHint = false
		VoxelObjectRef.remove_child(Grid)
		for cursor in Cursors.values():
			VoxelObjectRef.remove_child(cursor)
		VoxelObjectRef.disconnect("tree_exiting", self, "cancel")
		VoxelObjectRef.disconnect("set_voxel_set", VoxelSetViewer, "set_voxel_set")
	
	Lock.pressed = true
	Commit.disabled = true
	Cancel.disabled = true
	
	VoxelObjectRef = null
	
	if close: emit_signal("close")


func handle_input(camera : Camera, event : InputEvent) -> bool:
	if is_instance_valid(VoxelObjectRef):
		if event is InputEventMouse:
			var hit := raycast_for(camera, event.position, VoxelObjectRef)
			
			last_position = null if hit.empty() else Voxel.world_to_grid(VoxelObjectRef.to_local(hit.position))
			if typeof(last_position) == TYPE_VECTOR3:
				set_cursors_position(last_position)
			
			
			if not Lock.pressed:
				if event.button_mask & BUTTON_MASK_RIGHT == BUTTON_MASK_RIGHT:
					set_cursors_visibility(false)
					return false
				var cursors_visible := not hit.empty()
				
				if event is InputEventMouseButton:
					match event.button_index:
						BUTTON_LEFT: return true
				
				set_cursors_visibility(cursors_visible)
	return false


func _on_Lock_toggled(locked : bool) -> void:
	if locked: set_cursors_visibility(false)
	elif typeof(last_position) == TYPE_VECTOR3:
		set_cursors_visibility(true)
		set_cursors_position(last_position)
	emit_signal("editing", !locked)
