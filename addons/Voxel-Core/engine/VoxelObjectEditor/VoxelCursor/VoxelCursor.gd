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
					var origin := Vector3(
						selection[0 if selection[0].x < selection[1].x else 1].x,
						selection[0 if selection[0].y < selection[1].y else 1].y,
						selection[0 if selection[0].z < selection[1].z else 1].z
					)
					var dimensions : Vector3 = (selection[0] - selection[1]).abs()
					if dimensions.x == 0: dimensions.x = 1
					if dimensions.y == 0: dimensions.y = 1
					if dimensions.z == 0: dimensions.z = 1
					
					vt.add_face(voxel, Vector3.RIGHT,
						Vector3(origin.x + dimensions.x, origin.y, origin.z),
						Vector3(origin.x + dimensions.x, origin.y, origin.z + dimensions.z),
						Vector3(origin.x + dimensions.x, origin.y + dimensions.y, origin.z),
						Vector3(origin.x + dimensions.x, origin.x + dimensions.x, origin.z + dimensions.z)
					)
					vt.add_face(voxel, Vector3.LEFT,
						Vector3(origin.x, origin.y, origin.z),
						Vector3(origin.x, origin.y, origin.z + dimensions.z),
						Vector3(origin.x, origin.y + dimensions.y, origin.z),
						Vector3(origin.x, origin.x + dimensions.x, origin.z + dimensions.z)
					)
					vt.add_face(voxel, Vector3.UP,
						Vector3(origin.x + dimensions.x, origin.y + dimensions.y, origin.z + dimensions.z),
						Vector3(origin.x, origin.y + dimensions.y, origin.z + dimensions.z),
						Vector3(origin.x + dimensions.x, origin.y + dimensions.y, origin.z),
						Vector3(origin.x, origin.y + dimensions.y, origin.z)
					)
					vt.add_face(voxel, Vector3.DOWN,
						Vector3(origin.x + dimensions.x, origin.y, origin.z + dimensions.z),
						Vector3(origin.x, origin.y, origin.z + dimensions.z),
						Vector3(origin.x + dimensions.x, origin.y, origin.z),
						Vector3(origin.x, origin.y , origin.z)
					)
					vt.add_face(voxel, Vector3.FORWARD,
						Vector3(origin.x, origin.y, origin.z),
						Vector3(origin.x + dimensions.x, origin.y, origin.z),
						Vector3(origin.x, origin.y + dimensions.y, origin.z),
						Vector3(origin.x + dimensions.x, origin.y + dimensions.y, origin.z)
					)
					vt.add_face(voxel, Vector3.BACK,
						Vector3(origin.x, origin.y, origin.z + dimensions.z),
						Vector3(origin.x + dimensions.x, origin.y, origin.z + dimensions.z),
						Vector3(origin.x, origin.y + dimensions.y, origin.z + dimensions.z),
						Vector3(origin.x + dimensions.x, origin.y + dimensions.y, origin.z + dimensions.z)
					)
		mesh = vt.end()
	else: mesh = null
