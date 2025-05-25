extends Node
class_name Multiplayer

@export var is_connected_panel:NodePath = ""
@export var player_count_sign:NodePath = ""
@export var instance_per_save_name = false
@export var ghost_mode = true
@export var hide_avatars = false

var player_steam_id
var player_node
var active_lobby_id = 0
var active_lobby_members = {}
var is_remote_signal = false
var next_message_id = 0
var messages_needing_ack = {}
var panel_nodes
var is_connected_panel_node
var player_count_sign_node

const MAX_PLAYERS = 250
const PROTOCOL_VERSION = 2
const RECIPIENT_BROADCAST_ALL = -1

func _ready():
	# P2P solve messages should still be received while paused.
	set_process_mode(Node.PROCESS_MODE_ALWAYS)

	player_steam_id = Steam.getSteamID()
	player_node = get_node("/root/scene/player")

	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	Steam.persona_state_change.connect(_on_persona_state_change)
	Steam.p2p_session_request.connect(_on_p2p_session_request)

	_setup_recurring_task(0.1, _broadcast_player_location)
	_setup_recurring_task(5.0, _resend_messages_needing_ack)
	_setup_recurring_task(10.0, _request_lobby_list)

	_request_lobby_list()

func _process(_delta: float) -> void:
	_read_p2p_packet()

func _exit_tree():
	if active_lobby_id != 0:
		Steam.leaveLobby(active_lobby_id)

func _setup_recurring_task(wait_time, function):
	var timer = Timer.new()
	timer.set_wait_time(wait_time)
	timer.set_one_shot(false)
	timer.timeout.connect(function)
	add_child(timer)
	timer.start()

func _broadcast_player_location():
	if active_lobby_id == 0:
		return
	_send_p2p_packet({
		"global_transform": player_node.global_transform,
	}, RECIPIENT_BROADCAST_ALL, Steam.P2P_SEND_UNRELIABLE_NO_DELAY, false)

func _resend_messages_needing_ack():
	for message_id in messages_needing_ack:
		var message = messages_needing_ack[message_id]
		if message["recipient_id"] in active_lobby_members:
			_send_p2p_packet(message["data"], message["recipient_id"], message["mode"], true)
		else:
			messages_needing_ack.erase(message_id)

func _request_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListNumericalFilter("protocol_version", PROTOCOL_VERSION, Steam.LOBBY_COMPARISON_EQUAL)
	Steam.addRequestLobbyListStringFilter("map", global.map, Steam.LOBBY_COMPARISON_EQUAL)
	if instance_per_save_name:
		Steam.addRequestLobbyListStringFilter("save_file", global.user.to_lower(), Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

func _on_lobby_match_list(lobbies: Array) -> void:
	if active_lobby_id != 0 && not active_lobby_id in lobbies:
		# Not sure why this happens, but it seems to sometimes.
		lobbies.append(active_lobby_id)
	var best_lobby_id = 0
	var best_lobby_size = -1
	for lobby_id in lobbies:
		var lobby_size = Steam.getNumLobbyMembers(lobby_id)
		if lobby_size > best_lobby_size || (lobby_size == best_lobby_size && lobby_id < best_lobby_id):
			best_lobby_id = lobby_id
			best_lobby_size = lobby_size
	if best_lobby_id == 0:
		Steam.createLobby(Steam.LOBBY_TYPE_INVISIBLE, MAX_PLAYERS)
	elif best_lobby_id != active_lobby_id:
		Steam.joinLobby(best_lobby_id)
	elif best_lobby_size <= 1:
		_request_lobby_list()

func _on_lobby_created(result: int, lobby_id: int) -> void:
	if result != Steam.RESULT_OK:
		return
	var _ignore = Steam.setLobbyData(lobby_id, "map", global.map)
	_ignore = Steam.setLobbyData(lobby_id, "protocol_version", str(PROTOCOL_VERSION))
	if instance_per_save_name:
		_ignore = Steam.setLobbyData(lobby_id, "save_file", global.user.to_lower())
	_request_lobby_list()

func _on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, result: int) -> void:
	if result != Steam.RESULT_OK:
		return
	if active_lobby_id != 0 && active_lobby_id != lobby_id:
		Steam.leaveLobby(active_lobby_id)
	active_lobby_id = lobby_id
	_update_lobby_members()
	# Broadcast out all our solves in case we have existing save data.
	_send_hi(RECIPIENT_BROADCAST_ALL)

func _on_lobby_chat_update(_lobby_id: int, member_id: int, _making_change_id: int, chat_state: int) -> void:
	_update_lobby_members()
	# New user joined, so send them all our already solved panels.
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		_send_hi(member_id)

func _send_hi(recipient_id):
	var solves = []
	if !ghost_mode:
		for panel_node in panel_nodes:
			if panel_node.is_complete:
				solves.append(panel_node.get_path())
		if is_connected_panel_node != null && !is_connected_panel_node.is_complete:
			solves.append(is_connected_panel_node.get_path())
	_send_p2p_packet({
		"hi": true,
		"solves": solves,
	}, recipient_id, Steam.P2P_SEND_RELIABLE, true)

func _on_lobby_data_update(_lobby_id: int, _member_id: int, _key: int) -> void:
	_update_lobby_members()

func _on_persona_state_change(_persona_id: int, _flag: int) -> void:
	_update_lobby_members()

func _update_lobby_members():
	if active_lobby_id == 0:
		return
	var lobby_size: int = Steam.getNumLobbyMembers(active_lobby_id)
	var prior_lobby_members = active_lobby_members
	active_lobby_members = {}
	for i in range(0, lobby_size):
		var member_id: int = Steam.getLobbyMemberByIndex(active_lobby_id, i)
		if member_id != player_steam_id:
			var steam_name = Steam.getFriendPersonaName(member_id)
			print(steam_name)
			if member_id in prior_lobby_members:
				active_lobby_members[member_id] = prior_lobby_members[member_id]
			else:
				active_lobby_members[member_id] = load("res://objects/nodes/multiplayer/avatar.tscn").instantiate()
				active_lobby_members[member_id].set_steam_name(steam_name)
				get_node("/root/scene").add_child.call_deferred( active_lobby_members[member_id] )
			active_lobby_members[member_id].steam_id = member_id
			if false && ghost_mode:
				active_lobby_members[member_id].steam_name = ""
				active_lobby_members[member_id].material = "transparentWhite"
			else:
				active_lobby_members[member_id].steam_name = steam_name
				active_lobby_members[member_id].material = "gold"
	for member in prior_lobby_members.values():
		if not member.steam_id in active_lobby_members:
			member.queue_free()

func _on_p2p_session_request(remote_id: int) -> void:
	if remote_id in active_lobby_members:
		var _ignore = Steam.acceptP2PSessionWithUser(remote_id)

func _read_p2p_packet() -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(0)
	if packet_size > 0:
		var packet: Dictionary = Steam.readP2PPacket(packet_size, 0)
		var remote_id = packet["remote_steam_id"]
		if remote_id in active_lobby_members:
			var serialized: PackedByteArray = packet["data"]
			var data: Dictionary = bytes_to_var(serialized)
			if "hi" in data:
				_receive_hi(remote_id)
			if "global_transform" in data:
				_receive_member_location(remote_id, data["global_transform"])
			#if "solves" in data:
			#	for solve in data["solves"]:
			#		_receive_solve(solve)
			#if "unsolves" in data:
			#	for unsolve in data["unsolves"]:
			#		_receive_unsolve(unsolve)
			if "message_id" in data:
				_send_p2p_packet({
					"ack": data["message_id"],
				}, remote_id, Steam.P2P_SEND_RELIABLE_WITH_BUFFERING, false)
			if "ack" in data:
				messages_needing_ack.erase(data["ack"])

func _receive_hi(member_id: int) -> void:
	var member = active_lobby_members[member_id]
	member.said_hi = true
	_update_player_count_sign()

func _receive_member_location(member_id: int, global_transform) -> void:
	var member = active_lobby_members[member_id]
	member.global_move_to(global_transform)
	if !member.visible && !hide_avatars:
		member.show()

func _receive_solve(path) -> void:
	if ghost_mode:
		return
	var node = get_node_or_null(path)
	if node != null && node is PanelMain && !node.is_complete:
		var input = node.get_node_or_null("Viewport/GUI/Panel/TextEdit")
		if input != null:
			is_remote_signal = true
			input.complete()
			is_remote_signal = false

func _receive_unsolve(path) -> void:
	if ghost_mode:
		return
	var node = get_node_or_null(path)
	if node != null && node is PanelMain && node.is_complete:
		var input = node.get_node_or_null("Viewport/GUI/Panel/TextEdit")
		if input != null:
			is_remote_signal = true
			input.uncomplete()
			is_remote_signal = false

func _send_p2p_packet(data: Dictionary, recipient_id: int, mode: int, needs_ack: bool) -> void:
	if recipient_id == RECIPIENT_BROADCAST_ALL:
		for member_id in active_lobby_members.keys():
			_send_p2p_packet(data.duplicate(), member_id, mode, needs_ack)
		return

	if needs_ack:
		var message_id
		if "message_id" in data:
			message_id = data["message_id"]
		else:
			message_id = next_message_id
			next_message_id += 1
			data["message_id"] = message_id
		if not message_id in messages_needing_ack:
			messages_needing_ack[message_id] = {
				"data": data,
				"recipient_id": recipient_id,
				"mode": mode,
			}
	var serialized: PackedByteArray = []
	serialized.append_array(var_to_bytes(data))
	var _ignore = Steam.sendP2PPacket(recipient_id, serialized, mode)

func _on_panel_correct(panel_node):
	if active_lobby_id != 0 and !is_remote_signal && !ghost_mode:
		_send_p2p_packet({
			"solves": [panel_node.get_path()],
		}, RECIPIENT_BROADCAST_ALL, Steam.P2P_SEND_RELIABLE, true)

func _on_panel_unsolved(panel_node):
	if active_lobby_id != 0 and !is_remote_signal && !ghost_mode:
		_send_p2p_packet({
			"unsolves": [panel_node.get_path()],
		}, RECIPIENT_BROADCAST_ALL, Steam.P2P_SEND_RELIABLE, true)

func _update_player_count_sign():
	if player_count_sign_node != null:
		var count = 1
		for member_id in active_lobby_members:
			if active_lobby_members[member_id].said_hi:
				count += 1
		player_count_sign_node.value = str(count)
