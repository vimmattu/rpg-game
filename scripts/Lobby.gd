extends Node2D

var ip = 'localhost'
var port = 3000
var max_players = 4


func _ready():
	var peer = NetworkedMultiplayerENet.new()
	if Global.is_server():
		peer.create_server(port, max_players)
	else:
		peer.create_client(ip, port)
	get_tree().set_network_peer(peer)

	get_tree().connect("connected_to_server", self, "_connection_ok")
	get_tree().connect("connection_failed", self, "_connection_failed")


func _connection_ok():
	print("Connected to server %s:%d" % [ip, port])


func _connection_failed():
	print("Failed to connect to server %s:%d" % [ip, port])

