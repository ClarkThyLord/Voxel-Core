tool
extends Reference



# Declarations
export(String) var name := ""



# Core
func select(editor, event : InputEvent, prev_hit : Dictionary) -> Dictionary:
	return {
		"consume": true,
		"selection": []
	}
