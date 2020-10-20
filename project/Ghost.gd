extends PathFollow2D

signal died

var data
var node
var health = 1
var speed = 0
var immune = 0
var gone = false

onready var animator = $AnimationPlayer
onready var audio = $AudioStreamPlayer

func init(count, health_mult):
	data = random_ghost(count)
	
	health = data.hp * health_mult
	speed = data.speed * rand_range(0.9, 1.1)
	
	node = $Entity.get_child(data.sprite)
	for child in $Entity.get_children():
		if child != node:
			child.queue_free()
	
	node.visible = true
	if data.has("tint"):
		modulate = data.tint
	var sprite = node.get_node("AnimatedSprite")
	sprite.play("default")
	if randf() < 0.5:
		sprite.flip_h = true
	var anim = sprite.get_node_or_null("AnimationPlayer")
	if anim:
		anim.play("idle")
		
	$AudioStreamPlayer.pitch_scale = rand_range(0.8, 1.2)

func random_ghost(count):
	var options = []
	var total = 0
	for g in G.ghost_database:
		if g.next <= count:
			options.push_back(g)
			total += g.weight
	var r = randf() * total
	for g in options:
		if r < g.weight:
			if g.has("cd") and g.cd > 0:
				g.next = count + g.cd
			return g
		else:
			r -= g.weight
	assert(false)
	return null

func _process(delta):
	offset += speed * delta
	if immune > 0:
		immune -= delta

func hit(bread):
	if gone or immune > 0: return
	health -= bread.damage
	if health <= 0:
		kill(bread)
	else:
		animator.play("hit")
		immune = 0.25
		play_random_sound(data.hurt_sounds)

func kill(bread = null):
	if gone: return
	gone = true
	call_deferred("disable")
	play_random_sound(data.death_sounds)
	if randf() < 0.3:
		animator.play("die2")
	else:
		animator.play("die")
	emit_signal("died", self, bread)
	yield(get_tree().create_timer(10), "timeout")
	queue_free()

func escape():
	if gone: return
	gone = true
	call_deferred("disable")
	animator.play("escape")
	yield(animator, "animation_finished")
	queue_free()

func disable():
	$Entity.collision_layer = 0
	$Entity.collision_mask = 0
	node.disabled = true
	var trigger = node.get_node_or_null("Trigger")
	if trigger:
		trigger.queue_free()

func play_random_sound(array):
	if array.size() > 0:
		var i = randi() % array.size()
		play_sound(array[i])

func play_sound(id):
	$AudioStreamPlayer.stream = G.sounds[id]
	$AudioStreamPlayer.play()
