extends Node
class_name textPlayerReplacement

@export var replace = "{{player}}"

# Run the replacer on ready and after ready
# That way it runs in more use cases
func _ready():
	var parent = get_parent()
	if parent.text.contains( replace ):
		parent.text = parent.text.replace( replace, global.user )
	call_deferred( "_readier" )

func _readier():
	var parent = get_parent()
	if parent.text.contains( replace ):
		parent.text = parent.text.replace( replace, global.user )
