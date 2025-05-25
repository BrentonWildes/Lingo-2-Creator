extends Node
@export var distance = 200
	
func _ready():
	call_deferred("_deferredReady")
	
func _deferredReady():
	get_parent().get_node("pivot/camera").far = distance
