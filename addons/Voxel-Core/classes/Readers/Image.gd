extends Reference
class_name ImageReader, "res://addons/Voxel-Core/assets/logos/MagicaVoxel.png"



# Core
static func read(image : Image) -> Dictionary:
	var result := {
		"error": OK,
		"voxels": {},
		"palette": [],
	}
	
	image.lock()
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			if image.get_pixel(x, y).a > 0:
				var color := image.get_pixel(x, y)
				var index = result["palette"].find(color)
				if index > -1:
					result["palette"].append(color)
					index = result["palette"].size() - 1
				result["voxels"][Vector3(x, -y, 0).round()] = index
	image.unlock()
	
	for index in result["palette"]:
		result["palette"][index] = Voxel.colored(result["palette"][index])
	
	return result
