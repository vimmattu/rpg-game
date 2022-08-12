tool
extends "res://scripts/BaseSprite.gd"


export(
	String,
	"bug",
	"chest",
	"crab",
	"crystal",
	"egg",
	"elemental",
	"eye",
	"fighter",
	"flame",
	"frog",
	"ghost",
	"golem",
	"guardian",
	"imp",
	"knight",
	"mage",
	"mineral",
	"mushroom",
	"ogre",
	"plank",
	"plant",
	"rat",
	"revenant",
	"rhino",
	"skeleton",
	"slime",
	"snake",
	"sneel",
	"staffmage",
	"swordknight",
	"tycoon",
	"wasp",
	"worm",
	"zombie"
) var texture = "bug" setget _set_texture, _get_texture
export(int, 1, 3) var variant = 1 setget _set_variant, _get_variant


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


func _get_texture_path_for_sprite(_sprite_name: String) -> String:
	return "%s/%s%d.png" % [
		base_directory,
		_texture,
		variant,
	]


func update_animation_from_velocity(velocity: Vector2):
	if velocity == Vector2.ZERO:
		$AnimationPlayer.play("RESET")
		return
	$AnimationPlayer.play("walk")
	$Sprite.flip_h = velocity.x > 0

