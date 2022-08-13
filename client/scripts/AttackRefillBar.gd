extends Node2D


func _ready():
	hide()


func display(time: float):
	$TextureProgress.value = 0
	show()
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property($TextureProgress, "value", 0, 100, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	hide()
	tween.queue_free()

