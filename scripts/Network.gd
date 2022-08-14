extends Node


signal player_loaded


var connected = false
var local_info = {
	"foo": "bar"
}
var players = {}
var players_ready = []


func handle_failed_connection():
	get_tree().network_peer = null
	connected = false
	get_tree().change_scene("res://scenes/MainMenu.tscn")


func _ready():
	get_tree().connect("connected_to_server", self, "_connection_ok")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")


func _connection_ok():
	connected = true
	print("Local id: %s" % get_tree().get_network_unique_id())


func _player_connected(id):
	print("Player %s connected" % id)
	rpc_id(id, "register_player", local_info)


func _player_disconnected(id):
	print("Player %s disconnect" % id)


func _server_disconnected():
	print("Disconnected from server")
	handle_failed_connection()


func _connection_failed():
	handle_failed_connection()


remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	players[id] = info
	if not get_tree().is_network_server():
		rpc_id(1, "client_player_count_updated", players.size())


remote func client_player_count_updated(count):
	if count == players.size():
		players_ready.append(get_tree().get_rpc_sender_id())
		if players_ready.size() == players.size() and players.size() > 1:
			rpc("pre_start_game")
			pre_start_game()


func load_player(world, id):
	print("loading player %s" % id)
	var player_node = load("res://scenes/Player.tscn").instance()
	print("Setting network master as %d for %s" % [id, player_node])
	player_node.set_network_master(id)
	player_node.name = str(id)
	world.get_node("YSort").add_child(player_node)

	if not get_tree().is_network_server():
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())


remote func pre_start_game():
	var self_pid = get_tree().get_network_unique_id()
	var world = load("res://scenes/TestWorld.tscn").instance()
	get_tree().get_root().add_child(world)
	load_player(world, self_pid)
	for p in players:
		load_player(world, p)

