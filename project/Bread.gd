extends Area2D

var speed = 300
var mult = 1.0
var damage = 10.0
var free_kill = false
var velocity = Vector2.ZERO
var splitter = false
var duration = 20
var dead = false
var exception = null

func _ready():
	connect("area_entered", self, "_on_area_entered")
	var anim = get_node_or_null("AnimatedSprite")
	if anim:
		anim.play()

func launch(toaster_vel = Vector2.ZERO):
	velocity = toaster_vel * 0.5 + transform.x * speed
	velocity = velocity.clamped(speed)

func set_splitter():
	splitter = true
	modulate = Color.cyan

func _process(delta):
	position += velocity * delta
	duration -= delta
	if duration < 0:
		queue_free()

func _on_area_entered(area):
	if not dead and area.is_in_group("ghost") and exception != area:
		if splitter:
			area.owner.hit(self)
			duration = 20
			splitter = false
			modulate = Color.white
			exception = area
			call_deferred("split_toast")
		else:
			dead = true
			area.owner.hit(self)
			var wait = died()
			if wait > 0:
				yield(get_tree().create_timer(wait), "timeout")
			queue_free()

func split_toast():
	var dupe = duplicate()
	get_parent().add_child(dupe)
	for prop in ["global_position", "global_rotation", "mult", "damage", "velocity", "duration", "splitter", "exception", "dead", "modulate"]:
		dupe.set(prop, get(prop))
	
	global_rotation -= PI / 6
	velocity = velocity.rotated(-PI / 6)
	
	dupe.global_rotation += PI / 6
	dupe.velocity = dupe.velocity.rotated(PI / 6)

func died():
	return 0
