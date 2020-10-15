extends Area2D

var type
var rot_speed = 0
var gone = false

func init(player_has):
	type = get_random_type(player_has)
	rot_speed = rand_range(-3, 3)

func get_random_type(player_has):
	var total = 0
	var options = []
	for p in G.powerup_database:
		if player_has[p.id] < p.duration / 2:
			total += p.weight
			options.append(p)
	if options.size() == 0:
		return G.powerup_database[0]
	var r = randf() * total
	for p in options:
		if r < p.weight:
			return p
		else:
			r -= p.weight
	assert(false)
	return null

func _process(delta):
	position.y += 75 * delta
	rotation += rot_speed * delta

func _on_Powerup_area_entered(area):
	if gone: return
	gone = true
	if area.is_in_group("deathzone"):
		queue_free()
	else:
		area.owner.collect(type)
		$Polygon2D.hide()
		$CollectSound.play()
		yield(get_tree().create_timer(0.5), "timeout")
		queue_free()
