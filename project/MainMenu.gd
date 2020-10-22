extends Node

const GHOST_SPEED = 75

var ghost_velocity = Vector2.ZERO
var ghost_offset = Vector2(70, 0)
var high_scores_loaded = false

onready var ghost = $Node2D/Ghost

func _ready():
	randomize()
	ghost.play()
	if G.save_data.high_score > 0:
		$HighScore.text = "High Score: " + str(G.save_data.high_score)
	if OS.has_feature("HTML5"):
		$Menu/VBoxContainer/Quit.queue_free()
	$SoundTimer.start(rand_range(3, 6))

func _process(delta):
	ghost_velocity = (ghost.get_global_mouse_position() - ghost.position).clamped(GHOST_SPEED)
	ghost_offset = ghost_offset.rotated(rand_range(-.1, .1))
	ghost_velocity += (ghost.get_global_mouse_position() - ghost.position).clamped(GHOST_SPEED) + ghost_offset
	ghost_velocity = ghost_velocity.clamped(GHOST_SPEED)
	ghost.position += ghost_velocity * delta

func _on_SoundTimer_timeout():
	if not $GhostSound.playing:
		$GhostSound.play()
	$SoundTimer.start(rand_range(15, 30))
	
func _on_Play_pressed():
	get_tree().change_scene("res://Level.tscn")

func _on_FullScreen_pressed():
	OS.window_fullscreen = not OS.window_fullscreen

func _on_Quit_pressed():
	get_tree().quit()

func _on_Credits_pressed():
	$Credits.show()

func _on_CreditsClose_pressed():
	$Credits.hide()
	
func _on_Button_pressed():
	$HighScores.hide()

func _on_HighScores_pressed():
	$HighScores.show()
	if high_scores_loaded: return
	var list = $HighScores/Panel/VBoxContainer/MarginContainer/HighScoreList
	list.text = "Loading..."
	G.get_high_scores()
	yield(G.get_high_scores(), "api_call_complete")
	list.text = ""
	if "scores" in G.api_result:
		for score in G.api_result.scores:
			list.text += str(score.place) + ". " + score.player_name + " - " + str(score.score) + "\n"
		high_scores_loaded = true
	else:
		$HighScores.hide()
