extends Node2D

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
	rotation = 0
	get_parent().get_node("AttackRefillBar").display($AttackCooldown.wait_time)
	$AttackCooldown.start()
	yield($AttackCooldown, "timeout")
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

