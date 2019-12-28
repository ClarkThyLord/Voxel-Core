tool
extends "res://addons/Voxel-Core/src/VoxelSet.gd"



# The following will initialize the object as needed
func _load():
	set_tile_size(16)
	set_albedo_texture(preload("res://assets/examples/UV/Minecraft/Tileset/Tileset.png"))
	
	set_voxel(Voxel.colored(Color.black), 'black')
	set_voxel(Voxel.colored(Color.white), 'white')
	
	set_voxel(Voxel.textured(Vector2(0, 0)), 'grass')
	set_voxel(Voxel.textured(Vector2(1, 0)), 'stone')
	set_voxel(Voxel.textured(Vector2(2, 0)), 'dirt')
	set_voxel(Voxel.textured(Vector2(3, 0), {
		Vector3.UP: Vector2(0, 0),
		Vector3.DOWN: Vector2(2, 0)
	}, Color.white), 'dirt grass')
	set_voxel(Voxel.textured(Vector2(4, 0)), 'wooden plank')
	
	set_voxel(Voxel.textured(Vector2(0, 1)), 'cobblestone')
	set_voxel(Voxel.textured(Vector2(1, 1)), 'bedrock')
	set_voxel(Voxel.textured(Vector2(2, 1)), 'sand')
	set_voxel(Voxel.textured(Vector2(3, 1)), 'gravel')
	set_voxel(Voxel.textured(Vector2(4, 1)), 'wood')
	
	set_voxel(Voxel.textured(Vector2(0, 2)), 'diamond ore')
	set_voxel(Voxel.textured(Vector2(1, 2)), 'restone ore')
	set_voxel(Voxel.textured(Vector2(2, 2)), 'gold ore')
	set_voxel(Voxel.textured(Vector2(3, 2)), 'iron ore')
	set_voxel(Voxel.textured(Vector2(4, 2)), 'charcoal ore')
	
	set_voxel(Voxel.textured(Vector2(0, 3)), 'obsidian')
	set_voxel(Voxel.textured(Vector2(1, 3)), 'brick wall')
	set_voxel(Voxel.textured(Vector2(2, 3), {
		Vector3.UP: Vector2(3, 3),
		Vector3.DOWN: Vector2(4, 3)
	}, Color.white), 'tnt')
	
	set_voxel(Voxel.textured(Vector2(0, 4)), 'iron block')
	set_voxel(Voxel.textured(Vector2(1, 4)), 'gold block')
	set_voxel(Voxel.textured(Vector2(2, 4)), 'diamond block')
	set_voxel(Voxel.textured(Vector2(3, 4)), 'emerald block')
	set_voxel(Voxel.textured(Vector2(4, 4)), 'redstone block')
