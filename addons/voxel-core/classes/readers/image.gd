class_name ImageReader, "res://addons/voxel-core/assets/logos/MagicaVoxel.png"
extends Reference
# Image file reader



## Public Methods
# Reads images pixels, returns voxel content and voxel palette
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
				color.a = 1.0
				var index = result["palette"].find(color)
				if index == -1:
					index = result["palette"].size()
					result["palette"].append(color)
				result["voxels"][Vector3(x, -y, 0).round()] = index
	image.unlock()
	
	for index in range(result["palette"].size()):
		result["palette"][index] = Voxel.colored(result["palette"][index])
	
	return result


static func read_file(image_path : String) -> Dictionary:
	var image := Image.new()
	var err = image.load(image_path)
	if err == OK:
		return read(image)
	return { "error": err }
