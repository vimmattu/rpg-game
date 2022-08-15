extends CanvasLayer

var tooltip_objs = {}


func _ready():
	$Tooltip.hide()


func _update_tooltip():
	if not tooltip_objs.size():
		$Tooltip.hide()
		return
	var obj_to_show = tooltip_objs[tooltip_objs.keys()[0]]
	$Tooltip/VBoxContainer/Title.text = obj_to_show["title"]
	$Tooltip/VBoxContainer/Description.text = obj_to_show["description"]
	$Tooltip.show()


func add_tooltip(key, title, description):
	tooltip_objs[key] = {
		"title": title,
		"description": description,
	}
	_update_tooltip()


func remove_tooltip(key):
	tooltip_objs.erase(key)
	_update_tooltip()

