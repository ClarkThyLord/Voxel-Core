tool
extends MeshInstance



# Declarations
var vt := VoxelTool.new()


var Selections := [] setget set_selections
func set_selections(selections : Array, update := true) -> void:
	Selections = selections
	
	if update: self.update()


export(Color) var Modulate := Color.white setget set_modulate
func set_modulate(modulate : Color) -> void:
	Modulate = modulate
	Modulate.a = 0.6
	
	material_override.albedo_color = Modulate



# Core
func setup() -> void:
	if not is_instance_valid(material_override):
		material_override = SpatialMaterial.new()
	material_override.flags_transparent = true
	material_override.params_grow = true
	material_override.params_grow_amount = 0.001
	material_override.albedo_color = Modulate
	update()


func _init(): setup()
func _ready() -> void: setup()


func update() -> void:
	if not Selections.empty():
		vt.start()
		var voxel := Voxel.colored(Modulate)
		for selection in Selections:
			match typeof(selection):
				TYPE_VECTOR3:
					for direction in Voxel.Directions:
						if not Selections.has(selection + direction):
							vt.add_face(voxel, direction, selection)
				TYPE_ARRAY:
					pass
		mesh = vt.end()
	else: mesh = null
