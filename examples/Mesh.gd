tool
extends MeshInstance



# Core
func _init():
	var vt := VoxelTool.new()
	vt.begin()
	
	var voxels = {}
	for i in range(10):
		var pos = Vector3(
			randi() % 16,
			randi() % 16,
			randi() % 16
		)
		voxels[pos] = Voxel.colored(Color.red)
		Voxel.set_metallic(voxels[pos], randf())
		Voxel.set_specular(voxels[pos], randf())
#		Voxel.set_roughness(voxels[pos], randf())
		Voxel.set_roughness(voxels[pos], randi() % 16)
	
	for pos in voxels:
		var voxel = voxels[pos]
		for face in Voxel.Directions:
			vt.add_face(
				voxel,
				face,
				pos
			)
	
	mesh = vt.commit()

