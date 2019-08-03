tool
extends MeshInstance

enum States { ABS, REL }
export(States) var State = States.ABS

export(bool) var Solid : bool = true

export(Color, RGB) var _Color : Color = Color(1, 0, 0)

export(Array) var Points : Array = [] setget set_points
func set_points(points : Array, update : bool = true):
	Points = points
	
	if update: update()



# Core
func update() -> void:
	pass

# The following are helper functions used to generate VoxelCursor faces
# st        :   SurfaceTool   -   SurfaceTool to work with
# voxel     :   Dictionary    -   Voxel data
# g1        :   Vector3       -   Voxels starting vertex position, as a grid position
# g2        :   Vector3       -   Voxels second vertex position, as a grid position; uses Voxels starting position if not given
# g3        :   Vector3       -   Voxels third vertes position, as a grid position; uses Voxels starting position if not given
# g4        :   Vector3       -   Voxels last vertex position, as a grid position; uses Voxels starting position if not given
# uvscale   :   float         -   UV scale
#
# Example:
#   generate_up([SurfaceTool], [Voxel], Vector(1, 2))
#   generate_right([SurfaceTool], [Voxel], Vector(1,2), Vector(3,2), null, Vector(4, -3))
#   generate_right([SurfaceTool], [Voxel], Vector(1,2), Vector(3,2), null, Vector(4, -3), 0.13215)
#
static func generate_right(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.RIGHT)
	
	st.add_vertex(Voxel.grid_to_pos(g1 + Vector3.RIGHT))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))
	
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))

static func generate_left(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.LEFT)
	
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.UP + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))
	
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos(g1))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))

static func generate_up(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.UP)
	
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.UP + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))
	
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.UP + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos(g1 + Vector3.UP))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT + Vector3.UP))

static func generate_down(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.DOWN)
	
	st.add_vertex(Voxel.grid_to_pos(g1))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT))
	
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.RIGHT))

static func generate_back(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.BACK)
	
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.ONE))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.UP + Vector3.BACK))
	
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos(g1 + Vector3.BACK))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.UP + Vector3.BACK))

static func generate_forward(st : SurfaceTool, voxel : Dictionary, g1 : Vector3, g2 = null, g3 = null, g4 = null, uvscale : float = 1) -> void:
	st.add_normal(Vector3.FORWARD)
	
	st.add_vertex(Voxel.grid_to_pos(g1))
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))
	
	
	st.add_vertex(Voxel.grid_to_pos((g2 if g2 != null else g1) + Vector3.RIGHT))
	
	st.add_vertex(Voxel.grid_to_pos((g4 if g4 != null else g1) + Vector3.RIGHT + Vector3.UP))
	
	st.add_vertex(Voxel.grid_to_pos((g3 if g3 != null else g1) + Vector3.UP))