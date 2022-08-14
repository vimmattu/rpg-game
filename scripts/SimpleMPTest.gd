extends Sprite


var velocity := Vector2()
remote var puppet_pos = Vector2()


func _physics_process(delta):
	if not is_network_master():
		if puppet_pos != Vector2.ZERO:
			print(puppet_pos)
		position = puppet_pos
		return
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		velocity.y = -1
	if Input.is_action_pressed("move_down"):
		velocity.y = 1
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
	if Input.is_action_pressed("move_right"):
		velocity.x = 1
	position += velocity * delta * 200
	rset_unreliable("puppet_pos", position)

