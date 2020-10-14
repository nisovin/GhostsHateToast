extends "res://Bread.gd"

func _init():
	speed = 400
	mult = 0.1
	damage = 1.5
	free_kill = true
	
func _ready():
	$Sprite.region_rect.position.x = floor(rand_range(5, 23))
	$Sprite.region_rect.position.y = floor(rand_range(8, 27))
	$Sprite.rotation = randf() * 2 * PI
	$CollisionShape2D.rotation = $Sprite.rotation
