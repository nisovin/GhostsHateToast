extends Node2D

onready var player = $Player

onready var score_label = $CanvasLayer/Label

var interval = 4.0
var ghost_count = 0
var ghost_health_multiplier = 1.0
var score = 0
var escaping = false
var escaped = 0
var cheats_used = false
var gameover = false

var cheatcode = ""

func _ready():
	$Player.connect("fired", self, "_on_player_fired")
	$SpawnTimer.start(interval)
	if OS.has_feature("HTML5"):
		$CanvasLayer/Pause/VBoxContainer/Quit.queue_free()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		$CanvasLayer/Pause.show()
		get_tree().paused = true

func _unhandled_key_input(event):
	if event.pressed and event.scancode == KEY_F1:
		cheat_yeast()
	if event.pressed and event.scancode == KEY_F2:
		interval = 1
	if event.pressed and event.scancode == KEY_F3:
		score = 1500
		end_game()
	if event.pressed and event.scancode == KEY_F4:
		spawn_powerup(Vector2(player.position.x, 100))
	if event.pressed and event.scancode == KEY_F5:
		player.collect(G.powerup_database[0])
	if event.pressed and event.scancode == KEY_F6:
		player.collect(G.powerup_database[1])
	if event.pressed and event.scancode == KEY_F7:
		player.collect(G.powerup_database[2])
	if event.pressed and event.scancode == KEY_F9:
		player.collect(G.powerup_database[3])
	if event.pressed and event.scancode == KEY_F10:
		player.collect(G.powerup_database[4])
	if event.pressed and event.scancode == KEY_F11:
		player.collect(G.powerup_database[5])
	if event.pressed and event.scancode >= KEY_A and event.scancode <= KEY_Z and not gameover:
		var key = OS.get_scancode_string(event.scancode)
		cheatcode += key
		if cheatcode.length() > 20:
			cheatcode = cheatcode.substr(cheatcode.length() - 20)
		check_cheat_code()

func _on_player_fired(projectile):
	$ToastHolder.add_child(projectile)

func _on_SpawnTimer_timeout():
	ghost_count += 1
	var ghost = G.Ghost.instance()
	ghost.init(ghost_count, ghost_health_multiplier)
	var i = randi() % $GhostPaths.get_child_count()
	$GhostPaths.get_child(i).add_child(ghost)
	ghost.offset = 0
	ghost.connect("died", self, "_on_ghost_die")
	$SpawnTimer.start(rand_range(interval * 0.7, interval * 1.2))

func _on_DifficultyTimer_timeout():
	ghost_health_multiplier + 0.25
	print(ghost_health_multiplier)

func _on_ghost_die(ghost, bread):
	if gameover: return
	var mult = ghost.data.mult * bread.mult if bread != null else 0
	var dist = ghost.unit_offset

	var points = (2 - dist) * mult * (20.0 / interval)

	score += points
	score_label.text = "Score: " + str(round(score))

	if bread != null and not bread.free_kill and interval > 1:
		interval -= 0.2 * mult
		if interval < 1:
			interval = 1

	if ghost.data.has("drop"):
		var drops = int(floor(ghost.data.drop))
		var chance = ghost.data.drop - drops
		if randf() < chance:
			drops += 1
		if drops > 0:
			spawn_powerup(ghost.position)

func spawn_powerup(position):
	var powerup = G.Powerup.instance()
	powerup.init(player.powerups)
	powerup.position = position
	$ToastHolder.call_deferred("add_child", powerup)

func _on_DeathZone_area_entered(area):
	if area.is_in_group("trigger"):
		area.owner.escape()
		if not escaping and not gameover:
			escaped_ghost()

func escaped_ghost():
	escaping = true
	interval = clamp(interval * 2, 2.5, max(4, interval))
	$EscapeAudio.play()

	if escaped < 5:
		escaped += 1

		var life_tex = get_node("CanvasLayer/Lives/Life" + str(escaped))
		life_tex.texture = preload("res://art/life_2.png")
		life_tex.modulate.a = 0.8

		yield(get_tree().create_timer(2.5), "timeout")
		fire_side_launchers()
		yield(get_tree().create_timer(2.5), "timeout")
		escaping = false

	else:
		end_game()

func fire_side_launchers():
	for i in 8:
		var crumb = G.Crumb.instance()
		crumb.position = $LeftLauncher.position
		crumb.rotation = rand_range(PI * -0.1, PI * -0.4)
		crumb.launch()
		$ToastHolder.add_child(crumb)
		crumb = G.Crumb.instance()
		crumb.position = $RightLauncher.position
		crumb.rotation = rand_range(PI * -0.6, PI * -0.9)
		crumb.launch()
		$ToastHolder.add_child(crumb)

func end_game():
	gameover = true
	interval = 0.5
	$Player.queue_free()
	var s = round(score)
	$CanvasLayer/GameOver/Center/VBoxContainer/FinalScore.text = "Score: " + str(s)
	if score > 500:
		if G.save_data.unlocked_cheatcodes < G.cheatcode_database.size():
			$CanvasLayer/GameOver/Cheatcode.text = G.cheatcode_database[G.save_data.unlocked_cheatcodes]
			G.save_data.unlocked_cheatcodes += 1
		else:
			$CanvasLayer/GameOver/Cheatcode.text = G.cheatcode_database[randi() % G.cheatcode_database.size()]
	$CanvasLayer/GameOver.show()
	if s > G.save_data.high_score and not cheats_used:
		G.save_data.high_score = s
	G.save_game()

func check_cheat_code():
	for c in G.cheatcode_database:
		if cheatcode.ends_with(c):
			cheatcode = ""
			cheats_used = true
			call("cheat_" + c.to_lower())

func cheat_yeast():
	spawn_powerup(Vector2(player.position.x, 75))

func cheat_sandwich():
	activate_powerup_by_name("two_slot")
	
func cheat_creamcheese():
	activate_powerup_by_name("dense")

func cheat_gluten():
	fire_side_launchers()

func cheat_fullloaf():
	activate_powerup_by_name("four_slot")
	activate_powerup_by_name("rapid_fire")

func cheat_crossover():
	for path in $GhostPaths.get_children():
		for ghost in path.get_children():
			ghost.kill()

func cheat_graveyard():
	interval = 0.5

func cheat_godofbread():
	for p in G.powerup_database:
		player.collect(p)

func activate_powerup_by_name(name):
	for p in G.powerup_database:
		if p.id == name:
			player.collect(p)

func _on_Menu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://MainMenu.tscn")

func _on_Resume_pressed():
	$CanvasLayer/Pause.hide()
	get_tree().paused = false

func _on_Quit_pressed():
	get_tree().quit()

