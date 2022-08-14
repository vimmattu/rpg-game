extends "res://scripts/Unit.gd"


func get_class() -> String:
	return "Player"


func _ready():
	can_respawn = true
	$Camera2D.current = not get_tree().has_network_peer() or is_network_master()
	connect("death_started", self, "on_death_started")
	connect("respawn", self, "on_respawn")


func on_death_started():
	$HumanSprite/AnimationPlayer.play("death")


func on_respawn():
	$HumanSprite/Back.rotation_degrees = 0
	$HumanSprite/Front.rotation_degrees = 0
	$HumanSprite/Side.rotation_degrees = 0


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
	if Input.is_action_just_pressed("tab_select"):
		handle_tab_select()


func handle_tab_select():
	var last_hovered = -1
	var actual = []
	var nodes = get_tree().get_nodes_in_group("hoverable")
	var overlapping_nodes = []
	var overlapping_areas = []

	for a in $TabSelector.get_overlapping_areas():
		overlapping_areas.append(a.get_parent())
	overlapping_nodes.append_array(overlapping_areas)
	overlapping_nodes.append_array($TabSelector.get_overlapping_bodies())

	for node in nodes:
		if node in overlapping_nodes:
			actual.append(node)
	if not len(actual): return

	for i in range(len(actual)):
		if actual[i].get_node("HoverIndicator").visible:
			last_hovered = i

	var modifier = -1 if Input.is_action_pressed("run") else 1

	var new_idx = last_hovered + modifier
	if new_idx < 0 or new_idx >= len(actual):
		new_idx = 0
	for node in nodes:
		node.on_hover_finished()
	actual[new_idx].on_hover_started()

