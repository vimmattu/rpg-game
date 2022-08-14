extends Node2D



func _ready():
	hide()
	$AnimationPlayer.play("float")
	get_parent().connect("hover_started", self, "on_parent_hover_started")
	get_parent().connect("hover_finished", self, "on_parent_hover_finished")


func on_parent_hover_started():
	show()


func on_parent_hover_finished():
	hide()

