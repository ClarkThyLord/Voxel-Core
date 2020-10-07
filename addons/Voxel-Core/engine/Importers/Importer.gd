tool
extends EditorImportPlugin



# Core
static func read_file(file_path : String) -> Dictionary:
	var result = { "error": ERR_FILE_UNRECOGNIZED }
	match file_path.get_extension():
		"png", "bmp", "dds", "exr", "hdr", "jpg", "jpeg", "tga", "svg", "svgz", "webp":
			result = ImageReader.read_file(file_path)
		"vox": result = VoxReader.read_file(file_path)
		"qb": continue
		"qbt": continue
		"vxm": continue
	return result
