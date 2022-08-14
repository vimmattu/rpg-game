tool
extends Node2D

export (String, DIR) var base_directory setget _set_base_dir, _get_base_dir

var sprite_nodes = []
var _texture: String = ""


func get_class() -> String:
	return "UnitSprite"


func _set_base_dir(new_dir: String):
	base_directory = new_dir
	_load_sprites()


func _get_base_dir() -> String:
	return base_directory


func _get_texture_path_for_sprite(sprite_name: String) -> String:
	return "%s/%s/%s.png" % [
		base_directory,
		sprite_name.to_lower(),
		_texture,
	]


func _load_sprites():
	if not _texture: return
	for sprite in sprite_nodes:
		sprite.texture = load(_get_texture_path_for_sprite(sprite.name))


func _ready():
	for n in get_children():
		if n.get_class() == "Sprite":
			sprite_nodes.append(n)
	_load_sprites()


func update_animation_from_velocity(_velocity: Vector2):
	pass

