tool
extends MeshInstance
# Mesh used to highlight voxel grid selections



## Exported Variables
# Highlight color
export var color := Color(1, 1, 1, 0.75) setget set_color



## Public Variables
# Grid positions and areas to highlight
# A Vector3 highlights a single grid position
# [Vector3, Vector3] highlights the area between two grid positions
# Many type of selections can be mixed and selected at a time
var selections := [] setget set_selections



## Private Variables
# VoxelTool used to construct mesh
var _voxel_tool := VoxelTool.new()



## Built-In Virtual Methods
func _init():
	setup()
func _ready() -> void:
	setup()



## Public Methods
func set_voxel_size(value : float, update := true) -> void:
	if is_instance_valid(_voxel_tool):
		_voxel_tool.set_voxel_size(value)
	
	if update:
		self.update()


func set_color(value : Color) -> void:
	color = value
	if is_instance_valid(material_override):
		material_override.albedo_color = color


func set_selections(value : Array, update := true) -> void:
	selections = value
	
	if update:
		self.update()


# Setup the material if not already done
func setup() -> void:
	if not is_instance_valid(material_override):
		material_override = SpatialMaterial.new()
	material_override.flags_transparent = true
	material_override.flags_unshaded = true
	material_override.params_grow = true
	material_override.params_grow_amount = 0.001
	material_override.albedo_color = color
	update()


# Update highlighted position(s) / area(s)
func update() -> void:
	if not selections.empty():
		_voxel_tool.begin()
		var voxel := Voxel.colored(color)
		for selection in selections:
			match typeof(selection):
				TYPE_VECTOR3:
					for face in Voxel.Faces:
						if not selections.has(selection + face):
							_voxel_tool.add_face(voxel, face, selection)
				TYPE_ARRAY:
					var origin := Vector3(
							selection[0 if selection[0].x < selection[1].x else 1].x,
							selection[0 if selection[0].y < selection[1].y else 1].y,
							selection[0 if selection[0].z < selection[1].z else 1].z)
					var dimensions : Vector3 = (selection[0] - selection[1]).abs()
					
					_voxel_tool.add_face(voxel, Vector3.RIGHT,
							Vector3(origin.x + dimensions.x, origin.y, origin.z + dimensions.z),
							Vector3(origin.x + dimensions.x, origin.y, origin.z),
							Vector3(origin.x + dimensions.x, origin.y + dimensions.y, origin.z + dimensions.z),
							Vector3(origin.x + dimensions.x, origin.y + dimensions.y, origin.z))
					_voxel_tool.add_face(voxel, Vector3.LEFT,
							Vector3(origin.x, origin.y, origin.z + dimensions.z),
							Vector3(origin.x, origin.y, origin.z),
							Vector3(origin.x, origin.y + dimensions.y, origin.z + dimensions.z),
							Vector3(origin.x, origin.y + dimensions.y, origin.z))
					_voxel_tool.add_face(voxel, Vector3.UP,
							Vector3(origin.x + dimensions.x, origin.y + dimensions.y, origin.z),
							Vector3(origin.x, origin.y + dimensions.y, origin.z),
							Vector3(origin.x + dimensions.x, origin.y + dimensions.y, origin.z + dimensions.z),
							Vector3(origin.x, origin.y + dimensions.y, origin.z + dimensions.z))
					_voxel_tool.add_face(voxel, Vector3.DOWN,
							Vector3(origin.x + dimensions.x, origin.y, origin.z),
							Vector3(origin.x, origin.y, origin.z),
							Vector3(origin.x + dimensions.x, origin.y, origin.z + dimensions.z),
							Vector3(origin.x, origin.y, origin.z + dimensions.z))
					_voxel_tool.add_face(voxel, Vector3.BACK,
							Vector3(origin.x + dimensions.x, origin.y, origin.z + dimensions.z),
							Vector3(origin.x, origin.y, origin.z + dimensions.z),
							Vector3(origin.x + dimensions.x, origin.y + dimensions.y, origin.z + dimensions.z),
							Vector3(origin.x, origin.y + dimensions.y, origin.z + dimensions.z))
					_voxel_tool.add_face(voxel, Vector3.FORWARD,
							Vector3(origin.x + dimensions.x, origin.y, origin.z),
							Vector3(origin.x, origin.y, origin.z),
							Vector3(origin.x + dimensions.x, origin.y + dimensions.y, origin.z),
							Vector3(origin.x, origin.y + dimensions.y, origin.z))
		mesh = _voxel_tool.commit()
	else:
		mesh = null
