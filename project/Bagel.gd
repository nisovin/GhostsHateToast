extends "res://Bread.gd"

var dir = 1

func _init():
	speed = 250
	damage = 20
	if randf() < 0.5:
		dir = -1

func _process(delta):
	$AnimatedSprite.rotation += PI * dir * delta

func died():
	$AnimatedSprite.hide()
	$CollisionShape2D.queue_free()
	$DieParticles.emitting = true
	speed *= 0.25
	velocity *= 0.25
	return 3
