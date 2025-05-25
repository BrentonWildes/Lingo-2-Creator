extends Node3D
class_name Receiver

@export var senders:Array[NodePath] = []
@export var senderGroup:Array[NodePath] = []
@export var nested:bool = false
@export var complete_at:int = 0
@export var max_length:int = 0
@export var excludeSenders:Array[NodePath] = []

var total = 0
var triggered = 0
var all_senders

# Called when the node enters the scene tree for the first time.
func _ready():
	if (!Engine.is_editor_hint()):
		all_senders = senders.duplicate()
		var exclude = []
		
		for sender in excludeSenders:
			exclude.push_back(get_node(sender).get_path())
		
		if ( senderGroup != null and !senderGroup.is_empty() ):
			for groups in senderGroup:
				var group = get_node( groups )
				if group:
					if ( nested ):
						for children in group.get_children():
							for sender in children.get_children():
								if ( !exclude.has(sender.get_path()) ):
									all_senders.push_back(sender.get_path())
					else:
						for sender in group.get_children():
							if ( !exclude.has(sender.get_path()) ):
								all_senders.push_back(sender.get_path())
		
		if (complete_at > 0):
			total = complete_at
		else:
			total = all_senders.size()
		
		var i = 0
		while i < all_senders.size():
			var sender = get_node( all_senders[i] )
			sender.trigger.connect(handleTriggered)
			sender.untrigger.connect(handleUntriggered)
			i+=1

func handleTriggered():
	print("parent triggered ran")

func handleUntriggered():
	print("parent untriggered ran")
