class_name Challenge
extends Level

@onready var scene_challenge: PackedScene = preload("res://scenes/levels/challenge.tscn")
@export var do_end_to_menu = false

#@export var respawn_points = Array[Node3D]

func level_end():
	print("challenge end! score: ", score_current, " (fake goal", score_goal,")")
	var last_best : int = GameOverlord.high_score_challenge
	GameOverlord.set_last_score(score_current)
	ended = true
	if score_current >= last_best:
		sfx_player.stream = sfx_victory
		sfx_player.play()
		$CanvasLayer/ChallengeScore/Label.text = "score : "+str(score_current)+"\nRECORD BATTU !"
		$CanvasLayer/ChallengeScore.visible = true
		end_delay_timer.start()
		
	else:
		sfx_player.stream = sfx_game_over
		sfx_player.play()
		$CanvasLayer/ChallengeScore/Label.text = "score : "+str(score_current)+"\nrecord : "+str(last_best)
		$CanvasLayer/ChallengeScore.visible = true
		end_delay_timer.start()

func _on_end_delay_timeout():
	$CanvasLayer/ChallengeScore.visible = false
	if (do_end_to_menu): GameOverlord.end_challenge()

func _on_quit_button_pressed() -> void:
	GameOverlord.end_challenge()
