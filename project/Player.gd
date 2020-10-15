extends Node2D

signal fired

const EDGE = 100
const SPEED = 250
const ROTATION_SPEED = 0.2
const MIN_ROT = -PI * .80
const MAX_ROT = -PI * .20
const COOLDOWN_DURATION = 0.75

var aim_mode = "M"
var joy_device = 0

var cooldown_modifier = 1.0
var speed_modifier = 1.0

var speed = 0
var cooldown = 0

var powerups = {
	"triple": 0,
	"rapid_fire": 0,
	"two_slot": 0,
	"four_slot": 0,
	"splitter": 0,
	"dense": 0
}

onready var toaster = $Toaster
onready var sprite = $Toaster/AnimatedSprite
onready var sound = $AudioStreamPlayer

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
		if cooldown <= 0:
			sprite.play("default")
			if Input.is_action_pressed("fire"):
				fire()
	
	var dir = 0
	if Input.is_action_pressed("move_right"):
		dir += 1
	if Input.is_action_pressed("move_left"):
		dir -= 1
	speed = dir * SPEED * speed_modifier
	if dir != 0:
		position.x += speed * delta
		position.x = clamp(position.x, EDGE, 640 - EDGE)
	
	if aim_mode == "M" and get_global_mouse_position().y < position.y:
		toaster.look_at(get_global_mouse_position())
		toaster.global_rotation = clamp(toaster.global_rotation, MIN_ROT, MAX_ROT)
	elif aim_mode == "J":
		var x = Input.get_joy_axis(joy_device, 2)
		var y = Input.get_joy_axis(joy_device, 3)
		if abs(x) > 0.5 or abs(y) > 0.5:
			toaster.look_at(toaster.global_position + Vector2(x, y))
			toaster.global_rotation = clamp(toaster.global_rotation, MIN_ROT, MAX_ROT)
	
	if powerups.triple > 0:
		$Toaster2.global_rotation = toaster.global_rotation
		$Toaster3.global_rotation = toaster.global_rotation

	for key in powerups:
		if powerups[key] > 0:
			powerups[key] -= delta
			if powerups[key] <= 0:
				powerups[key] = 0
				if has_method("powerup_" + key):
					call("powerup_" + key, false)

func _unhandled_input(event):
	if event.is_action_pressed("fire"):
		if cooldown <= 0:
			fire()
			
	if event is InputEventMouseMotion:
		aim_mode = "M"
	if event is InputEventJoypadMotion and (event.axis == 2 or event.axis == 3):
		aim_mode = "J"
		joy_device = event.device

func fire():
	if powerups.four_slot > 0:
		fire_projectile(toaster, -0.1)
		fire_projectile(toaster, 0.1)
		fire_projectile(toaster, -0.3)
		fire_projectile(toaster, 0.3)
	elif powerups.two_slot > 0:
		fire_projectile(toaster, -0.15)
		fire_projectile(toaster, 0.15)
	else:
		fire_projectile(toaster)
	if powerups.triple > 0:
		fire_projectile($Toaster2)
		fire_projectile($Toaster3)
	cooldown = COOLDOWN_DURATION * cooldown_modifier
	sound.pitch_scale = rand_range(0.9, 1.1) * (1 / cooldown_modifier)
	sound.play()
	sprite.play("fire")
	
func fire_projectile(t, angle_offset = 0):
	var projectile
	if powerups.dense > 0:
		projectile = G.Bagel.instance()
	else:
		projectile = G.Toast.instance()
	if powerups.splitter > 0:
		projectile.set_splitter()
	emit_signal("fired", projectile)
	projectile.global_position = t.global_position
	projectile.rotation = t.rotation + angle_offset
	projectile.launch(Vector2(speed, 0))
	return projectile

func collect(powerup):
	powerups[powerup.id] = min(powerups[powerup.id] + powerup.duration, powerup.duration * 1.5)
	if has_method("powerup_" + powerup.id):
		call("powerup_" + powerup.id)
	call_deferred("collect_message", powerup)

func collect_message(powerup):
	var msg = G.PowerupMessage.instance()
	get_parent().add_child(msg)
	msg.global_position = toaster.global_position - Vector2(0, 15)
	msg.init(powerup.name)

func powerup_triple(enable = true):
	if enable:
		$TripleAnimationPlayer.play("triple_show")
	else:
		$TripleAnimationPlayer.play("triple_hide")

func powerup_rapid_fire(enable = true):
	if enable:
		cooldown_modifier = 0.4
	else:
		cooldown_modifier = 1.0

func powerup_two_slot(enable = true):
	if enable:
		if powerups.four_slot <= 0:
			$Toaster/AnimatedSprite.scale = Vector2(1.2, 1.2)
	else:
		$Toaster/AnimatedSprite.scale = Vector2.ONE

func powerup_four_slot(enable = true):
	if enable:
		$Toaster/AnimatedSprite.scale = Vector2(1.5, 1.5)
	else:
		if powerups.two_slot > 0:
			$Toaster/AnimatedSprite.scale = Vector2(1.2, 1.2)
		else:
			$Toaster/AnimatedSprite.scale = Vector2.ONE
		
