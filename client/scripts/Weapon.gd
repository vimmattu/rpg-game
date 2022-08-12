extends Node2D

var _damaged_units = []
var is_attacking := false

export var min_damage := 5
export var max_damage := 10


func _ready():
	hide()
	$AnimationPlayer.connect("animation_started", self, "on_animation_started")
	$AnimationPlayer.connect("animation_finished", self, "on_animation_finished")
	$WeaponLoc/DamageArea.connect("body_entered", self, "on_damagearea_entered")
	$AttackCooldown.connect("timeout", self, "on_attack_cooldown_timeout")


func on_damagearea_entered(body):
	if not is_attacking:
		return
	if body == get_parent():
		return
	if body in _damaged_units:
		return
	if body.get_class() == "Npc":
		var damage = int(floor(rand_range(min_damage, max_damage)))
		get_parent().damage_target(body, damage)
		_damaged_units.append(body)


func on_animation_started(_anim_name: String):
	show()
	is_attacking = true
	$WeaponLoc/DamageArea/CollisionShape2D.disabled = false


func on_animation_finished(_anim_name: String):
	hide()
	$AttackCooldown.start()
	rotation = 0


func on_attack_cooldown_timeout():
	is_attacking = false
	$WeaponLoc/DamageArea/CollisionShape2D.disabled = true
	_damaged_units.clear()


func _physics_process(_delta):
	if is_attacking:
		return

	if Input.is_action_pressed("click_attack"):
		rotation = get_angle_to(get_global_mouse_position())
		$AnimationPlayer.play("cleave")
		return

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

	rotation = vec.angle()
	$AnimationPlayer.play("cleave")

