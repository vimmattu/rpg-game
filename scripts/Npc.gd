extends "res://scripts/Unit.gd"


var target = null
export var min_damage := 4
export var max_damage := 6
export var knockback_force := 50.0


func get_class() -> String:
	return "Npc"


func _ready():
	connect("death_started", self, "on_death_started")
	$AggroRange.connect("body_entered", self, "on_aggro_range_entered")
	$AnimationPlayer.connect("animation_started", self, "on_animation_started")


func on_death_started():
	$AnimationPlayer.play("death")


func on_animation_started(anim_name: String):
	if anim_name == 'attack':
		on_attack_started()


func on_attack_started():
	is_attacking = true
	yield($AnimationPlayer, "animation_finished")
	is_attacking = false
	$AttackInterval.start()
	yield($AttackInterval, "timeout")
	$AttackInterval.stop()


func on_aggro_range_entered(body):
	if target:
		return
	if body.get_class() == "Player":
		if body.is_dead: return
		target = body
		target.connect("death_started", self, "on_target_death")


func on_target_death():
	target.disconnect("death_started", self, "on_target_death")
	target = null


remotesync func attack():
	$AnimationPlayer.play("attack")


func get_movement() -> Vector2:
	if not target: return Vector2.ZERO

	if target in $AttackRange.get_overlapping_bodies():
		if $AttackInterval.is_stopped():
			if get_tree().has_network_peer():
				rpc("attack")
			else:
				attack()
		return Vector2.ZERO

	var angle_to_target := get_angle_to(target.position)
	var velocity := Vector2(cos(angle_to_target), sin(angle_to_target))
	return velocity * speed


func cause_damage():
	if get_tree().has_network_peer() and not is_network_master(): return
	if target in $AttackRange.get_overlapping_bodies():
		var damage = int(floor(rand_range(min_damage, max_damage)))
		damage_target(target, damage, knockback_force)

