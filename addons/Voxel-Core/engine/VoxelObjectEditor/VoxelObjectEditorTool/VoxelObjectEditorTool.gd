tool
extends Reference



# Declarations
export(String) var name := ""


export(int) var selection_offset := 0

export(PoolStringArray) var selection_modes := PoolStringArray([
	"individual",
	"area",
	"extrude"
])


export(Vector3) var mirror_modes := Vector3.ONE



# Core
func work(editor) -> void:
	pass
