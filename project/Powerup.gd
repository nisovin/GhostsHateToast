extends Area2D

var type
var rot_speed = 0
var gone = false

func init(player_has, falling_powerups):
	type = get_random_type(player_has, falling_powerups)
	rot_speed = rand_range(-3, 3)

func get_random_type(player_has, falling_powerups):
	var total = 0
	var options = []
	var falling = []
	for f in falling_powerups:
		if not f.gone and f.type:
			falling.append(f.type.id)
	for p in G.powerup_database:
		if player_has[p.id] < p.duration / 2 and not p.id in falling:
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
	if gone: return
	position.y += 75 * delta
	#rotation += rot_speed * delta

func _on_Powerup_area_entered(area):
	if gone: return
	gone = true
	$CPUParticles2D.emitting = false
	if area.is_in_group("deathzone"):
		$Tween.interpolate_property(self, "global_position", global_position, global_position + Vector2(0, 50), 0.25, Tween.TRANS_QUAD, Tween.EASE_IN)
		$Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.25)
	else:
		area.owner.collect(type)
		$CollectSound.play()
		$Tween.interpolate_property(self, "global_position", global_position, area.global_position, 0.25, Tween.TRANS_QUAD, Tween.EASE_IN)
		$Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.25)
	$Tween.start()
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()
