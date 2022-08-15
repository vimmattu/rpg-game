extends KinematicBody2D

signal damaged
signal hover_started
signal hover_finished
signal death_started
signal death_finished
signal respawn

var puppet_pos = Vector2.ZERO
var puppet_velocity = Vector2.ZERO
var puppet_knockback = Vector2.ZERO

var knockback = Vector2.ZERO

var _unit_sprite_nodes = []
var is_running := false
var is_attacking := false
var is_dead := false
var can_respawn := false

var respawn_location: Vector2 = Vector2.ZERO

export var speed := 200
export var health := 100
export var max_health := 100

onready var healthbar = $HealthBar/TextureProgress


func die():
	is_dead = true
	emit_signal("death_started")
	var tween := Tween.new()
	tween.interpolate_property(self, "modulate:a", 1, 0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	add_child(tween)
	tween.start()
	yield(tween, 'tween_completed')
	emit_signal("death_finished")
	if not can_respawn:
		queue_free()
	else:
		$RespawnTimer.start()
		yield($RespawnTimer, 'timeout')
		emit_signal("respawn")
		modulate.a = 1
		position = respawn_location
		health = max_health
		is_dead = false


func on_healthbar_timeout():
	healthbar.hide()


remotesync func take_damage(from, damage: int, knockback_force: float = 0.0):
	if knockback_force > 0:
		var angle = get_angle_to(from) + deg2rad(180)
		knockback =	Vector2(cos(angle), sin(angle)) * knockback_force
	healthbar.show()
	$HealthbarTimer.start()
	health -= damage
	healthbar.value = health
	$FCTManager.show_value(str(damage))
	emit_signal("damaged")
	if health <= 0:
		die()
	var modifier := 1.0 * health / max_health
	$TakeDamageSound.pitch_scale = 1.0 + (1 * modifier)
	$TakeDamageSound.play()


func damage_target(body, damage: int, knockback_force: float = 0.0):
	if get_tree().has_network_peer():
		body.rpc("take_damage", position, damage, knockback_force)
	else:
		body.take_damage(position, damage, knockback_force)


func _ready():
	add_to_group("hoverable")
	respawn_location = position
	$HealthbarTimer.connect("timeout", self, "on_healthbar_timeout")
	$SelectArea.connect("mouse_entered", self, "on_hover_started")
	$SelectArea.connect("mouse_exited", self, "on_hover_finished")
	healthbar.hide()
	healthbar.max_value = max_health
	healthbar.value = health
	for node in get_children():
		if node.get_class() == "UnitSprite":
			_unit_sprite_nodes.append(node)


func get_unit_details():
	return {
		"health": health,
		"max_health": max_health
	}


func on_hover_started():
	emit_signal("hover_started")
	UI.add_tooltip(self, self.name, "What the fuck\nNew line")


func on_hover_finished():
	emit_signal("hover_finished")
	UI.remove_tooltip(self)


func get_movement() -> Vector2:
	return Vector2.ZERO


func _update_unit_sprites(velocity):
	for node in _unit_sprite_nodes:
		node.update_animation_from_velocity(Vector2.ZERO if not velocity else velocity)


puppet func update_remote_movement(r_pos, r_velocity, r_knockback):
	puppet_pos = r_pos
	puppet_velocity = r_velocity
	puppet_knockback = r_knockback


func _handle_remote_update(_delta) -> Vector2:
	position = puppet_pos
	var velocity = puppet_knockback if puppet_knockback != Vector2.ZERO else puppet_velocity
	_update_unit_sprites(velocity)
	move_and_slide(velocity)
	puppet_pos = position
	return velocity


func _handle_local_update(delta):
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
		knockback = move_and_slide(knockback)
		if get_tree().has_network_peer():
			rpc_unreliable("update_remote_movement", position, Vector2.ZERO, knockback)
		return

	if is_dead: return
	if is_attacking: return

	var velocity = Vector2.ZERO
	velocity = get_movement()
	velocity = velocity.normalized() * speed
	if is_running:
		velocity *= 2
	if get_tree().has_network_peer():
		rpc_unreliable("update_remote_movement", position, velocity, Vector2.ZERO)
	move_and_slide(velocity)
	return velocity


func _physics_process(delta):
	var velocity = null
	if not get_tree().has_network_peer() or is_network_master():
		velocity = _handle_local_update(delta)
	else:
		velocity = _handle_remote_update(delta)
	_update_unit_sprites(velocity)

