extends KinematicBody2D

signal hover_started
signal hover_finished
signal death_started
signal death_finished
signal respawn

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


func take_damage(from, damage: int, knockback_force: float = 0.0):
	if knockback_force > 0:
		var angle = get_angle_to(from.position) + deg2rad(180)
		knockback =	Vector2(cos(angle), sin(angle)) * knockback_force
	healthbar.show()
	$HealthbarTimer.start()
	health -= damage
	healthbar.value = health
	$FCTManager.show_value(str(damage))
	if health <= 0:
		die()
	var modifier := 1.0 * health / max_health
	$TakeDamageSound.pitch_scale = 1.0 + (1 * modifier)
	$TakeDamageSound.play()


func damage_target(body, damage: int, knockback_force: float = 0.0):
	body.take_damage(self, damage, knockback_force)


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
	print(get_unit_details())
	emit_signal("hover_started")



func on_hover_finished():
	print(get_unit_details())
	emit_signal("hover_finished")


func get_movement() -> Vector2:
	return Vector2.ZERO


func _update_unit_sprites(velocity: Vector2):
	for node in _unit_sprite_nodes:
		node.update_animation_from_velocity(velocity)


func _physics_process(delta):
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
		knockback = move_and_slide(knockback)
		return

	if is_dead: return
	if is_attacking: return
	var velocity := get_movement()
	velocity = velocity.normalized() * speed
	if is_running:
		velocity *= 2
	_update_unit_sprites(velocity)
	move_and_slide(velocity)

