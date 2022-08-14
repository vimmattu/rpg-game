extends VBoxContainer


func _ready():
	var _sp = $ButtonSP.connect("pressed", self, "on_start_singleplayer")
	var _join = $ButtonMP.connect("pressed", self, "on_start_multiplayer")
	var _quit = $ButtonQuit.connect("pressed", self, "on_quit_game")
	pass


func on_start_singleplayer():
	get_tree().change_scene("res://scenes/TestWorld.tscn")


func on_start_multiplayer():
	print("not yet implemented")


func on_quit_game():
	get_tree().quit()

