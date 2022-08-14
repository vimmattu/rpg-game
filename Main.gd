extends Node2D


func _ready():
	if (
		"--server" in OS.get_cmdline_args() or
		OS.has_feature("Server")
	):
		print("Run server!")
		return
	print("Running client")
	get_tree().change_scene("res://scenes/TestWorld.tscn")

