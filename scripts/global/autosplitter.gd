extends Node

# Format:
# 0-7: Magic bytes used by the autosplitter to find the array in memory
# 8: Loading flag
# 9: First movement flag
# 10: Latest unlocked key (0 if run just started)
# 11: 1 or 2, indicating the level of the latest unlocked key
# 12-52: Latest collectable unlocked (null terminated, truncated at 40 chars excluding null)
# 53-93: Current map name (null terminated, truncated at 40 chars excluding null)
# 94-134: Map name of latest solved panel (null terminated, truncated at 40 chars excluding null)
# 135-235: Node path from /root/scene to latest solved panel (null terminated, truncated at 100 chars excluding null)
var splitter_data: PackedByteArray


func _init():
	splitter_data = PackedByteArray()
	splitter_data.resize(236)
	
	reset()


func reset():
	splitter_data.fill(0)
	
	# Initialize magic bytes for sigscanning
	splitter_data.set(0, 156)
	splitter_data.set(1, 70)
	splitter_data.set(2, 159)
	splitter_data.set(3, 176)
	splitter_data.set(4, 75)
	splitter_data.set(5, 106)
	splitter_data.set(6, 224)
	splitter_data.set(7, 141)


func _copyString(value: String, index: int, length: int):
	for i in range(value.length()):
		if i <= length:
			splitter_data.set(index + i, value.unicode_at(i))
		else:
			break
	
	if value.length() <= length:
		splitter_data.set(index + value.length(), 0)
	else:
		splitter_data.set(index + length, 0)


func setLoadingFlag(value: bool):
	splitter_data.set(8, value)


func setFirstMovementFlag(value: bool):
	splitter_data.set(9, value)


func setLatestUnlockedKey(key: String, level: int):
	splitter_data.set(10, key.unicode_at(0))
	splitter_data.set(11, level)


func setLatestUnlockedCollectible(cname: String):
	_copyString(cname, 12, 40)


func setCurrentMap(cname: String):
	_copyString(cname, 53, 40)


func setLatestSolvedPanel(map_name: String, panel_path: NodePath):
	_copyString(map_name, 94, 40)
	_copyString(panel_path.get_concatenated_names(), 135, 100)
