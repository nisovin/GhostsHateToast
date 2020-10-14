extends "res://Bread.gd"

func died():
	$AnimatedSprite.hide()
	$CollisionShape2D.queue_free()
	$DieParticles.emitting = true
	speed *= 0.25
	velocity *= 0.25
	return 3
