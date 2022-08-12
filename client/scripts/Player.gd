extends "res://scripts/Unit.gd"


func get_class() -> String:
	return "Player"


func get_movement() -> Vector2:
	var velocity := Vector2()
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	return velocity


func _input(_event):
	if Input.is_action_just_pressed("run"):
		is_running = true
	elif Input.is_action_just_released("run"):
		is_running = false

