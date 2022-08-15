extends VBoxContainer

var game_scene = preload("res://scenes/TestWorld.tscn")
var lobby_scene = preload("res://scenes/Lobby.tscn")


func _ready():
	var _sp = $ButtonSP.connect("pressed", self, "on_start_singleplayer")
	var _join = $ButtonMP.connect("pressed", self, "on_start_multiplayer")
	var _quit = $ButtonQuit.connect("pressed", self, "on_quit_game")


func on_start_singleplayer():
	var _game = get_tree().change_scene_to(game_scene)


func on_start_multiplayer():
	var _lobby = get_tree().change_scene_to(lobby_scene)


func on_quit_game():
	get_tree().quit()

