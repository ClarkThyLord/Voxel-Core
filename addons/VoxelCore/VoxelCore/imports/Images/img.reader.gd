tool
extends Reference
class_name ImageReader

static func read(file_path) -> Dictionary:
	var voxels : Dictionary = {}
	
	var image : Image = Image.new()
	var err = image.load(file_path)
	if err != OK:
	    print("Could not load image file")
	    return err
	
	image.lock()
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			if not image.get_pixel(x, y).a == 0: voxels[Vector3(x, y, 0).round()] = Voxel.colored(image.get_pixel(x, y))
	image.unlock()
	
	return voxels
