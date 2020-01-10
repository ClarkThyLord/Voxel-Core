tool
extends PanelContainer



# Refrences
const VoxelLayeredMeshClass := preload('res://addons/Voxel-Core/src/VoxelLayeredMesh.gd')
const VoxelLayerView := preload('res://addons/Voxel-Core/engine/BottomPanel/VoxelLayersView/VoxelLayerView/VoxelLayerView.tscn')

onready var Search := get_node('VBoxContainer/PanelContainer/HBoxContainer/Search')

onready var Add := get_node('VBoxContainer/PanelContainer/HBoxContainer/Add')
onready var AddDialog := get_node('VBoxContainer/PanelContainer/HBoxContainer/Add/AddDialog')
onready var AddName := get_node('VBoxContainer/PanelContainer/HBoxContainer/Add/AddDialog/Control/HBoxContainer/Name')
onready var AddConfirm := get_node('VBoxContainer/PanelContainer/HBoxContainer/Add/AddDialog/Control/Confirm')

onready var Layers := get_node('VBoxContainer/ScrollContainer/PanelContainer/Layers')



# Declarations
var layerviews := {} setget set_layer_views, get_layer_views
func get_layer_views() -> Dictionary: return {}
func set_layer_views(layers : Dictionary) -> void: pass


var VoxelObject : VoxelLayeredMeshClass setget set_voxel_object
func set_voxel_object(voxelobject : VoxelLayeredMeshClass, update := true) -> void:
	VoxelObject = voxelobject
	if update: _update()



# Core
func _ready(): _update()

func _update() -> void:
	for child in Layers.get_children():
		child.queue_free()
	
	layerviews.clear()
	if VoxelObject or true:
		var search : String = Search.text.to_lower()
		for layer_name in PoolStringArray(range(10)):
			if search.length() == 0 or layer_name.find(search) != -1:
				var layerview := VoxelLayerView.instance()
				layerview.set_name(layer_name)
				
				layerview.set_layer_name(layer_name)
				layerview.set_layer_visible(true or VoxelObject.is_layer_visible(layer_name))
				
				layerviews[layer_name] = layerview
				Layers.add_child(layerview)
				layerview._update()


func _on_Search_changed(new_text : String):
	_update()


func _on_Add_pressed():
	AddDialog.popup_centered()
	AddName.clear()
	AddName.grab_focus()
	AddConfirm.disabled = true

func _on_AddName_text_changed(new_text : String):
	AddConfirm.disabled = new_text.length() <= 0

func _on_AddConfirm_pressed():
	if AddName.text.length() > 0:
		# TODO
		AddDialog.hide()
		_update()


func _on_Layer_toggle(layer_name : String) -> void:
	# TODO
	_update()

func _on_Layer_move_up(layer_name : String) -> void:
	# TODO
	_update()

func _on_Layer_move_down(layer_name : String) -> void:
	# TODO
	_update()

func _on_Layer_remove(layer_name : String) -> void:
	# TODO
	_update()
