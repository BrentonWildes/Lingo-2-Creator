extends Node

@export var bag:String = "res://assets/libraries/randomizers/default.gd"

func _ready():
	var puzzles = _readGrabBag( bag )
	puzzles.shuffle()
	var puzzle = puzzles.pop_back()
	
	var parent = get_parent()
	parent.clue = puzzle[0]
	parent.symbol = puzzle[1]
	parent.answer = puzzle[2]
	
func _readGrabBag(path):
	var loaded_script = ResourceLoader.load(path)
	var instanced_script = loaded_script.new()
	var result = []
	for line in instanced_script.puzzles:
		result.append(line.split(","))
	return result
