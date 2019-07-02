tool
extends "res://addons/VoxelCore/src/VoxelSet.gd"



# The following will initialize the object as needed
func _load():
	set_voxel(Voxel.colored(Color.black, {}, {'name': 'black'}))
	set_voxel(Voxel.colored(Color.white, {}, {'name': 'white'}))
	
	set_voxel(Voxel.textured(Vector2(0, 0), {}, Color.white, {}, {'name': 'grass'}))
	set_voxel(Voxel.textured(Vector2(1, 0), {}, Color.white, {}, {'name': 'stone'}))
	set_voxel(Voxel.textured(Vector2(2, 0), {}, Color.white, {}, {'name': 'dirt'}))
	set_voxel(Voxel.textured(Vector2(3, 0), {
		Vector3.UP: Vector2(0, 0),
		Vector3.DOWN: Vector2(2, 0)
	}, Color.white, {}, {'name': 'dirt grass'}))
	set_voxel(Voxel.textured(Vector2(4, 0), {}, Color.white, {}, {'name': 'wooden plank'}))
	
	set_voxel(Voxel.textured(Vector2(0, 1), {}, Color.white, {}, {'name': 'cobblestone'}))
	set_voxel(Voxel.textured(Vector2(1, 1), {}, Color.white, {}, {'name': 'bedrock'}))
	set_voxel(Voxel.textured(Vector2(2, 1), {}, Color.white, {}, {'name': 'sand'}))
	set_voxel(Voxel.textured(Vector2(3, 1), {}, Color.white, {}, {'name': 'gravel'}))
	set_voxel(Voxel.textured(Vector2(4, 1), {}, Color.white, {}, {'name': 'wood'}))
	
	set_voxel(Voxel.textured(Vector2(0, 2), {}, Color.white, {}, {'name': 'diamond ore'}))
	set_voxel(Voxel.textured(Vector2(1, 2), {}, Color.white, {}, {'name': 'restone ore'}))
	set_voxel(Voxel.textured(Vector2(2, 2), {}, Color.white, {}, {'name': 'gold ore'}))
	set_voxel(Voxel.textured(Vector2(3, 2), {}, Color.white, {}, {'name': 'iron ore'}))
	set_voxel(Voxel.textured(Vector2(4, 2), {}, Color.white, {}, {'name': 'charcoal ore'}))
	
	set_voxel(Voxel.textured(Vector2(0, 3), {}, Color.white, {}, {'name': 'obsidian'}))
	set_voxel(Voxel.textured(Vector2(1, 3), {}, Color.white, {}, {'name': 'brick wall'}))
	set_voxel(Voxel.textured(Vector2(2, 3), {
		Vector3.UP: Vector2(3, 3),
		Vector3.DOWN: Vector2(4, 3)
	}, Color.white, {}, {'name': 'tnt'}))
	
	set_voxel(Voxel.textured(Vector2(0, 4), {}, Color.white, {}, {'name': 'iron block'}))
	set_voxel(Voxel.textured(Vector2(1, 4), {}, Color.white, {}, {'name': 'gold block'}))
	set_voxel(Voxel.textured(Vector2(2, 4), {}, Color.white, {}, {'name': 'diamond block'}))
	set_voxel(Voxel.textured(Vector2(3, 4), {}, Color.white, {}, {'name': 'emerald block'}))
	set_voxel(Voxel.textured(Vector2(4, 4), {}, Color.white, {}, {'name': 'redstone block'}))
