tool
extends Reference



## Public Variables
# Name of this tool
var name := ""

# Offset applied to VoxelObjectEditor selection when using this tool
var tool_normal := 0

# Types of selection modes
var selection_modes := PoolStringArray([
	"individual",
	"area",
	"extrude",
])

# A 1 in each coordinate means all selection mirrors are applicable using this tool
var mirror_modes := Vector3.ONE



## Public Methods
# Applies tool
# editor  :   VoxelObjectEditor   :   refrence to VoxelObjectEditor
func work(editor) -> void:
	pass
