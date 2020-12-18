tool
extends MeshInstance



# Declarations
var st := SurfaceTool.new()


export(bool) var Disabled := false setget set_disabled
func set_disabled(disabled : bool) -> void:
	Disabled = disabled
	visible = not disabled
	find_node("CollisionShape", true, false).disabled = disabled


export(Color) var Modulate := Color.white setget set_modulate
func set_modulate(modulate : Color) -> void:
	Modulate = modulate
	
	material_override.albedo_color = Modulate

enum GridModes { SOLID, WIRED }
export(GridModes) var GridMode := GridModes.WIRED setget set_grid_mode
func set_grid_mode(grid_mode : int, update := true) -> void:
	GridMode = grid_mode
	
	if update: self.update()

export(Vector3) var GridDimensions := Vector3(16, 16, 16) setget set_grid_dimensions
func set_grid_dimensions(grid_dimensions : Vector3, update := true) -> void:
	GridDimensions = Vector3(
		clamp(grid_dimensions.x, 1, 100),
		clamp(grid_dimensions.y, 1, 100),
		clamp(grid_dimensions.z, 1, 100)
	)
	
	if update: self.update()



# Core
func setup() -> void:
	if not is_instance_valid(material_override):
		material_override = SpatialMaterial.new()
	material_override.albedo_color = Modulate
	material_override.set_cull_mode(2)
	update()


func _init(): setup()
func _ready() -> void: setup()


func update() -> void:
	match GridMode:
		GridModes.SOLID:
			mesh = PlaneMesh.new()
			scale = Vector3(
				GridDimensions.x * Voxel.VoxelSize,
				1,
				GridDimensions.z * Voxel.VoxelSize
			)
		GridModes.WIRED:
			scale = Vector3.ONE
			st.begin(Mesh.PRIMITIVE_LINES)
			
			var x : int = -GridDimensions.x
			while x <= GridDimensions.x:
				st.add_normal(Vector3.UP)
				st.add_vertex(Voxel.grid_to_snapped(Vector3(x, 0, -abs(GridDimensions.z))))
				st.add_vertex(Voxel.grid_to_snapped(Vector3(x, 0, abs(GridDimensions.z))))
				
				x += 1
			
			var z : int = -GridDimensions.z
			while z <= GridDimensions.z:
				st.add_normal(Vector3.UP)
				st.add_vertex(Voxel.grid_to_snapped(Vector3(-abs(GridDimensions.x), 0, z)))
				st.add_vertex(Voxel.grid_to_snapped(Vector3(abs(GridDimensions.x), 0, z)))
				
				z += 1
			
			mesh = st.commit()
	for child in get_children():
		remove_child(child)
		child.queue_free()
	create_convex_collision()
	set_disabled(Disabled)
