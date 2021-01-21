class_name Reader
extends Reference
# Makeshift interface class inhereted by all file readers.



## Public Methods
# Calls on appropriate file reader according to file_path's extension.
# file_path   :   String       :   path to file to be read
# return      :   Dictionary   :   read results, contains: { error : int, voxels : Dictionary<Vec3, int>, palette : Dictionary<int, Dictionary<String, Variant> }
static func read_file(file_path : String) -> Dictionary:
	var result = { "error": ERR_FILE_UNRECOGNIZED }
	match file_path.get_extension():
		"png", "bmp", "dds", "exr", "hdr", "jpg", "jpeg", "tga", "svg", "svgz", "webp":
			result = ImageReader.read_file(file_path)
		"vox": result = VoxReader.read_file(file_path)
		"qb": continue
		"qbt": continue
		"vxm": continue
		"gpl": result = GPLReader.read_file(file_path)
	return result
