extends Area2D

var speed = 300
var mult = 1.0
var damage = 1.0
var free_kill = false
var velocity = Vector2.ZERO
var duration = 20
var dead = false

func _ready():
	connect("area_entered", self, "_on_area_entered")
	var anim = get_node_or_null("AnimatedSprite")
	if anim:
		anim.play()

func launch(toaster_vel = Vector2.ZERO):
	velocity = toaster_vel * 0.5 + transform.x * speed
	velocity = velocity.clamped(speed)

func _process(delta):
	position += velocity * delta
	duration -= delta
	if duration < 0:
		queue_free()

func _on_area_entered(area):
	if not dead and area.is_in_group("ghost"):
		dead = true
		area.owner.hit(self)
		var wait = died()
		if wait > 0:
			yield(get_tree().create_timer(wait), "timeout")
		queue_free()

func died():
	return 0
