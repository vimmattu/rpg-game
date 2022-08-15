extends Node2D

var player_scene := preload("res://scenes/Player.tscn")


func _ready():
	if not get_tree().has_network_peer():
		$YSort.add_child(player_scene.instance())

