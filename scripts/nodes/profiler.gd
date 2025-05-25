extends Node
	
func _ready():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	global.initializeSteam()
	for f in global.listFiles("res://objects/scenes/"):
		var scene = load(f).instantiate()
		var panels = getAllPanels(scene)
		var proxied = {}
		for panel in panels:
			for proxy in panel.proxies:
				proxied[panel.get_node(proxy)] = true
		for panel in panels:
			if len(panel.proxies) > 0:
				continue
			if panel.symbol.strip_edges() == "" and not panel in proxied:
				print(f, " ", panel.clue, " ", panel.answer)
				

func getAllPanels(node: Node, result = []) -> Array:
	if node is PanelMain:
		result.push_back(node)
	for child in node.get_children():
		var _ignore = getAllPanels(child, result)
	return result
