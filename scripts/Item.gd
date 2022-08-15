extends Node2D

signal hover_started
signal hover_finished

var _hovered := false
var _equipper_candidate = null
var _original_parent = null
var _equip_instance = null

export var item_name := ""
export (PackedScene) var equip_scene


func _ready():
	add_to_group("hoverable")
	_original_parent = get_parent()
	$AnimationPlayer.play("float")
	$TakeRange.connect("mouse_entered", self, "on_hover_started")
	$TakeRange.connect("mouse_exited", self, "on_hover_finished")
	$TakeRange.connect("body_entered", self, "on_body_entered")
	$TakeRange.connect("body_exited", self, "on_body_exited")


func on_hover_started():
	_hovered = true
	print("item details bitch")
	emit_signal("hover_started")



func on_hover_finished():
	_hovered = false
	print("item details bitch")
	emit_signal("hover_finished")


remotesync func pick_item(body):
	hide()
	get_parent().remove_child(self)
	_equip_instance = equip_scene.instance()

	body.get_node("Items").add_child(self)
	body.add_child(_equip_instance)
	if get_tree().has_network_peer():
		_equip_instance.set_network_master(body.get_network_master())
		set_network_master(body.get_network_master())


remotesync func drop_item():
	if _equip_instance.is_attacking or _equip_instance.on_cooldown:
		yield(_equip_instance, "cooldown_finished")

	_equip_instance.queue_free()
	position = get_parent().get_parent().position

	get_parent().remove_child(self)
	_original_parent.add_child(self)
	if get_tree().has_network_peer():
		set_network_master(_original_parent.get_network_master())
	show()


func on_body_entered(body):
	if body.get_class() == "Player":
		_equipper_candidate = body


func on_body_exited(body):
	if body == _equipper_candidate:
		_equipper_candidate = null


func _input(event):
	if _equipper_candidate and Input.is_action_just_pressed("ui_accept"):
		if not _hovered: return
		if _equipper_candidate.is_dead: return
		if get_tree().has_network_peer():
			rpc("pick_item", _equipper_candidate)
		else:
			pick_item(_equipper_candidate)
		_equipper_candidate = null
		return
	if get_parent() != _original_parent and Input.is_action_just_pressed("ui_select"):
		if get_parent().get_parent().is_dead: return
		if get_tree().has_network_peer():
			rpc("drop_item")
		else:
			drop_item()

