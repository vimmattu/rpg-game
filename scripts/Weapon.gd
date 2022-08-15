extends Node2D

signal cooldown_finished

var on_cooldown := false
var _damaged_units = []
var is_attacking := false

export var min_damage := 5
export var max_damage := 10
export var knockback := 150.0


func _ready():
	hide()
	$AnimationPlayer.connect("animation_started", self, "on_animation_started")
	$WeaponLoc/DamageArea.connect("body_entered", self, "on_damagearea_entered")


func on_damagearea_entered(body):
	if get_tree().has_network_peer() and not is_network_master():
		return
	if on_cooldown:
		return
	if not is_attacking:
		return
	if body == get_parent():
		return
	if body in _damaged_units:
		return
	if body.get_class() == "Npc":
		var damage = int(floor(rand_range(min_damage, max_damage)))
		get_parent().damage_target(body, damage, knockback)
		_damaged_units.append(body)


func on_animation_started(_anim_name: String):
	show()
	is_attacking = true
	$WeaponLoc/DamageArea/CollisionShape2D.disabled = false
	yield($AnimationPlayer, "animation_finished")
	hide()
	get_parent().get_node("AttackRefillBar").display($AttackCooldown.wait_time)
	on_cooldown = true
	$AttackCooldown.start()
	rotation = 0
	yield($AttackCooldown, "timeout")
	emit_signal("cooldown_finished")
	on_cooldown = false
	is_attacking = false
	$WeaponLoc/DamageArea/CollisionShape2D.disabled = true
	_damaged_units.clear()


remotesync func attack():
	$AnimationPlayer.play("cleave")


func get_attack_angle():
	if Input.is_action_pressed("click_attack"):
		return get_angle_to(get_global_mouse_position())
	var vec = Vector2()
	if Input.is_action_pressed("ui_up"):
		vec.y -= 1	
	if Input.is_action_pressed("ui_down"):
		vec.y += 1	
	if Input.is_action_pressed("ui_right"):
		vec.x += 1	
	if Input.is_action_pressed("ui_left"):
		vec.x -= 1
	if vec == Vector2.ZERO:
		return
	return vec.angle()	


func _physics_process(_delta):
	if is_attacking:
		return

	var attack_angle = get_attack_angle()
	if attack_angle == null: return

	rotation = attack_angle
	if get_tree().has_network_peer():
		rpc("attack")
	else:
		attack()

