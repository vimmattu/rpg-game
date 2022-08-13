extends KinematicBody2D

signal hovered


var _unit_sprite_nodes = []
var is_running := false
var is_attacking := false

export var speed := 200
export var health := 100
export var max_health := 100

onready var healthbar = $HealthBar/TextureProgress


func on_death():
	pass


func on_healthbar_timeout():
	healthbar.hide()


func take_damage(damage: int):
	healthbar.show()
	$HealthbarTimer.start()
	health -= damage
	healthbar.value = health
	$FCTManager.show_value(str(damage))
	if health <= 0:
		on_death()
	var modifier := 1.0 * health / max_health
	$TakeDamageSound.pitch_scale = 1.0 + (1 * modifier)
	$TakeDamageSound.play()


func damage_target(body, damage: int):
	body.take_damage(damage)


func _ready():
	$HealthbarTimer.connect("timeout", self, "on_healthbar_timeout")
	$SelectArea.connect("mouse_entered", self, "on_hovered")
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


func on_hovered():
	print(get_unit_details())
	emit_signal("hovered", self)


func get_movement() -> Vector2:
	return Vector2.ZERO


func _update_unit_sprites(velocity: Vector2):
	for node in _unit_sprite_nodes:
		node.update_animation_from_velocity(velocity)


func _physics_process(_delta):
	if is_attacking: return
	var velocity := get_movement()
	velocity = velocity.normalized() * speed
	if is_running:
		velocity *= 2
	_update_unit_sprites(velocity)
	move_and_slide(velocity)

