extends Node2D

const DURATION = 1.5
const HEIGHT = 50

func init(msg):
	$Label.text = msg
	$Tween.interpolate_property($Label, "rect_position:y", 0, -HEIGHT, DURATION, Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Label, "modulate", Color.white, Color.transparent, DURATION, Tween.TRANS_LINEAR)
	$Tween.start()
	yield(get_tree().create_timer(DURATION + 0.1), "timeout")
	queue_free()
