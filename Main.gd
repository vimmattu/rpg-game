extends Node2D


func _ready():
	if Global.is_server():
		print("Run server")
		var _s = get_tree().change_scene("res://scenes/Lobby.tscn")
		return
	print("Run client")
	var _s = get_tree().change_scene("res://scenes/MainMenu.tscn")

