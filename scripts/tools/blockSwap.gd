@tool
extends GridMap

@export var should_queue:bool = false
@export var from:int
@export var to:int

func _process(_delta):
	if ( should_queue ):
		should_queue = false
		
		for cell in get_used_cells():
			if ( get_cell_item( Vector3i(cell.x, cell.y, cell.z )) == from ):
				set_cell_item( Vector3i(cell.x, cell.y, cell.z), to )
