# Big thanks to Manuel Strey, scayze!
# MIT License, https://github.com/scayze/MagicaVoxel-Importer
extends Reference
class_name MagicaVoxelReader, 'res://addons/VoxelCore/assets/MagicaVoxel.png'



# Declarations
const MagicaVoxelColors : Array = [
	"00000000", "ffffffff", "ffccffff", "ff99ffff", "ff66ffff", "ff33ffff", "ff00ffff", "ffffccff", "ffccccff", "ff99ccff", "ff66ccff", "ff33ccff", "ff00ccff", "ffff99ff", "ffcc99ff", "ff9999ff",
	"ff6699ff", "ff3399ff", "ff0099ff", "ffff66ff", "ffcc66ff", "ff9966ff", "ff6666ff", "ff3366ff", "ff0066ff", "ffff33ff", "ffcc33ff", "ff9933ff", "ff6633ff", "ff3333ff", "ff0033ff", "ffff00ff",
	"ffcc00ff", "ff9900ff", "ff6600ff", "ff3300ff", "ff0000ff", "ffffffcc", "ffccffcc", "ff99ffcc", "ff66ffcc", "ff33ffcc", "ff00ffcc", "ffffcccc", "ffcccccc", "ff99cccc", "ff66cccc", "ff33cccc",
	"ff00cccc", "ffff99cc", "ffcc99cc", "ff9999cc", "ff6699cc", "ff3399cc", "ff0099cc", "ffff66cc", "ffcc66cc", "ff9966cc", "ff6666cc", "ff3366cc", "ff0066cc", "ffff33cc", "ffcc33cc", "ff9933cc",
	"ff6633cc", "ff3333cc", "ff0033cc", "ffff00cc", "ffcc00cc", "ff9900cc", "ff6600cc", "ff3300cc", "ff0000cc", "ffffff99", "ffccff99", "ff99ff99", "ff66ff99", "ff33ff99", "ff00ff99", "ffffcc99",
	"ffcccc99", "ff99cc99", "ff66cc99", "ff33cc99", "ff00cc99", "ffff9999", "ffcc9999", "ff999999", "ff669999", "ff339999", "ff009999", "ffff6699", "ffcc6699", "ff996699", "ff666699", "ff336699",
	"ff006699", "ffff3399", "ffcc3399", "ff993399", "ff663399", "ff333399", "ff003399", "ffff0099", "ffcc0099", "ff990099", "ff660099", "ff330099", "ff000099", "ffffff66", "ffccff66", "ff99ff66",
	"ff66ff66", "ff33ff66", "ff00ff66", "ffffcc66", "ffcccc66", "ff99cc66", "ff66cc66", "ff33cc66", "ff00cc66", "ffff9966", "ffcc9966", "ff999966", "ff669966", "ff339966", "ff009966", "ffff6666",
	"ffcc6666", "ff996666", "ff666666", "ff336666", "ff006666", "ffff3366", "ffcc3366", "ff993366", "ff663366", "ff333366", "ff003366", "ffff0066", "ffcc0066", "ff990066", "ff660066", "ff330066",
	"ff000066", "ffffff33", "ffccff33", "ff99ff33", "ff66ff33", "ff33ff33", "ff00ff33", "ffffcc33", "ffcccc33", "ff99cc33", "ff66cc33", "ff33cc33", "ff00cc33", "ffff9933", "ffcc9933", "ff999933",
	"ff669933", "ff339933", "ff009933", "ffff6633", "ffcc6633", "ff996633", "ff666633", "ff336633", "ff006633", "ffff3333", "ffcc3333", "ff993333", "ff663333", "ff333333", "ff003333", "ffff0033",
	"ffcc0033", "ff990033", "ff660033", "ff330033", "ff000033", "ffffff00", "ffccff00", "ff99ff00", "ff66ff00", "ff33ff00", "ff00ff00", "ffffcc00", "ffcccc00", "ff99cc00", "ff66cc00", "ff33cc00",
	"ff00cc00", "ffff9900", "ffcc9900", "ff999900", "ff669900", "ff339900", "ff009900", "ffff6600", "ffcc6600", "ff996600", "ff666600", "ff336600", "ff006600", "ffff3300", "ffcc3300", "ff993300",
	"ff663300", "ff333300", "ff003300", "ffff0000", "ffcc0000", "ff990000", "ff660000", "ff330000", "ff0000ee", "ff0000dd", "ff0000bb", "ff0000aa", "ff000088", "ff000077", "ff000055", "ff000044",
	"ff000022", "ff000011", "ff00ee00", "ff00dd00", "ff00bb00", "ff00aa00", "ff008800", "ff007700", "ff005500", "ff004400", "ff002200", "ff001100", "ffee0000", "ffdd0000", "ffbb0000", "ffaa0000",
	"ff880000", "ff770000", "ff550000", "ff440000", "ff220000", "ff110000", "ffeeeeee", "ffdddddd", "ffbbbbbb", "ffaaaaaa", "ff888888", "ff777777", "ff555555", "ff444444", "ff222222", "ff111111"
]



# Core
class MagicaVoxelData:
	var pos = Vector3(0,0,0)
	var color
	func init(file):
		pos.x = file.get_8()
		pos.z = -file.get_8()
		pos.y = file.get_8()
		
		color = file.get_8()

static func read_vox(file_path):
	#Initialize and populate voxel array
	var voxelArray = []
	for x in range(0,128):
		voxelArray.append([])
		for y in range(0,128):
			voxelArray[x].append([])
			voxelArray[x][y].resize(128)
	
	var file = File.new()
	var error = file.open( file_path, File.READ )
	if error != OK:
		if file.is_open(): file.close()
		return error
	
	##################
	#  Import Voxels #
	##################
	var colors = null
	var voxels = null
	var magic = PoolByteArray([file.get_8(),file.get_8(),file.get_8(),file.get_8()]).get_string_from_ascii()
	
	var version = file.get_32()
	
	var dimensions = Vector3()
	 
	# a MagicaVoxel .vox file starts with a 'magic' 4 character 'VOX ' identifier
	if magic == "VOX ":
		var sizex = 0
		var sizey = 0
		var sizez = 0
		
		while file.get_position() < file.get_len():
			# each chunk has an ID, size and child chunks
			var chunkId = PoolByteArray([file.get_8(),file.get_8(),file.get_8(),file.get_8()]).get_string_from_ascii() #char[] chunkId
			var chunkSize = file.get_32()
			var childChunks = file.get_32()
			var chunkName = chunkId
			# there are only 2 chunks we only care about, and they are SIZE and XYZI
			if chunkName == "SIZE":
				sizex = file.get_32()
				sizey = file.get_32()
				sizez = file.get_32()
				 
				file.get_buffer(chunkSize - 4 * 3)
			elif chunkName == "XYZI":
				# XYZI contains n voxels
				var numVoxels = file.get_32()
				
				# each voxel has x, y, z and color index values
				voxels = []
				for i in range(0,numVoxels):
					var mvc = MagicaVoxelData.new()
					mvc.init(file)
					voxels.append(mvc)
					voxelArray[mvc.pos.x][mvc.pos.y][mvc.pos.z] = mvc
			elif chunkName == "RGBA":
				colors = []
				 
				for i in range(0,256):
					var r = float(file.get_8() / 255.0)
					var g = float(file.get_8() / 255.0)
					var b = float(file.get_8() / 255.0)
					var a = float(file.get_8() / 255.0)
					
					colors.append(Color(r,g,b,a))
					
			else: file.get_buffer(chunkSize)  # read any excess bytes
		
		if voxels.size() == 0: return null #failed to read any valid voxel voxels
		 
		# now push the voxel data into our voxel chunk structure
		for i in range(0,voxels.size()):
			# use the MagicaVoxelColors array by default, or overrideColor if it is available
			if colors == null:
				voxels[i].color = Color(MagicaVoxelColors[voxels[i].color]-1)
			else:
				voxels[i].color = colors[voxels[i].color-1]
		
		dimensions.x = sizex
		dimensions.y = sizey
		dimensions.z = sizez
	file.close()
	
	var real_voxels = {}
	for voxel in voxels: real_voxels[voxel.pos.floor()] = Voxel.colored(voxel.color)
	
	return { 'dimensions': dimensions, 'voxels': real_voxels }