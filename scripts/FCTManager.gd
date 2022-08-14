extends Node2D

var FCT = preload("res://scenes/FloatingCombatText.tscn")

export var travel = Vector2(0, -80)
export var duration = 2
export var spread = PI / 2


func show_value(value: String, crit=false):
	var fct = FCT.instance()
	add_child(fct)
	fct.show_value(value, travel, duration, spread, crit)

