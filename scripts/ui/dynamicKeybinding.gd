extends LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	focus_entered.connect(_onClick)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _onClick():
	clear()
