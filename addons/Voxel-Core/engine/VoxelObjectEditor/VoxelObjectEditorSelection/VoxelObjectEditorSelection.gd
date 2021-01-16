tool
extends Reference



## Public Variables
var name := ""



## Public Methods
# Handles VoxelObjectEditor selection(s)
# editor     :   VoxelObjectEditor   :   refrence to VoxelObjectEditor
# event      :   InputEventMouse     :   event to be handled
# prev_hit   :   Dictionary          :   previous raycast result
func select(editor, event : InputEventMouse, prev_hit : Dictionary) -> bool:
	return false
