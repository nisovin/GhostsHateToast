extends Area2D

var type

func _ready():
	type = get_random_type()

func get_random_type():
	var total = 0
	for p in G.powerup_database:
		total += p.weight
	var r = randf() * total
	for p in G.powerup_database:
		if r < p.weight:
			return p
		else:
			r -= p.weight
	assert(false)
	return null

func _process(delta):
	position.y += 75 * delta

func _on_Powerup_area_entered(area):
	if area.is_in_group("deathzone"):
		queue_free()
	else:
		area.owner.collect(type)
		queue_free()
