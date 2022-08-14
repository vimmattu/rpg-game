tool
extends "res://scripts/BaseSprite.gd"


export(
	String,
	"adventurer_m",
	"adventurer_f",
	"cleric",
	"fighter",
	"guard",
	"hunter",
	"knight",
	"mage",
	"ninja",
	"oldman",
	"rogue",
	"templar",
	"thief",
	"warrior",
	"wizard"
) var texture = "adventurer_m" setget _set_texture, _get_texture
export(int, 1, 4) var variant = 1 setget _set_variant, _get_variant


func _ready():
	_texture = texture


func _set_texture(new_texture: String):
	texture = new_texture
	_texture = new_texture
	_load_sprites()


func _get_texture() -> String:
	return texture


func _set_variant(new_variant: int):
	variant = new_variant
	_load_sprites()


func _get_variant() -> int:
	return variant


func _get_texture_path_for_sprite(sprite_name: String) -> String:
	return "%s/%s/%s%d.png" % [
		base_directory,
		sprite_name.to_lower(),
		_texture,
		variant,
	]


func update_animation_from_velocity(velocity: Vector2):
	if velocity == Vector2.ZERO:
		$AnimationPlayer.play("RESET")
		return

	$AnimationPlayer.play("walk")
	if velocity.x != 0:
		$Side.flip_h = velocity.x > 0
		$Side.show()
		$Back.hide()
		$Front.hide()
		return

	$Side.hide()
	if velocity.y < 0:
		$Back.show()
		$Front.hide()
	else:
		$Back.hide()
		$Front.show()

