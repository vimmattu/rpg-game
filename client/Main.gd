extends Node2D


export var is_server := false


func _ready():
	if (
		is_server or
		"--server" in OS.get_cmdline_args() or
		OS.has_feature("Server")
	):
		print("Run server!")
		return
	print("Running client")
	get_tree().change_scene("res://scenes/TestWorld.tscn")

