class_name Challenge
extends Level

@onready var scene_challenge: PackedScene = preload("res://scenes/levels/challenge.tscn")

func level_end():
	print("level end! ", score_current, "/", score_goal)
	GameOverlord.set_last_score(score_current)
	ended = true
	if score_current >= score_goal:
		sfx_player.stream = sfx_victory
		sfx_player.play()
		$CanvasLayer/ChallengeScore/Label.text = "TON TEMPS : %d sec"%progress_seconds
		$CanvasLayer/ChallengeScore.visible = true
		end_delay_timer.start()
		
	else:
		sfx_player.stream = sfx_game_over
		sfx_player.play()
		if (scene_failure): get_tree().change_scene_to_packed(scene_failure)
		if (dialog_failure): Dialogic.start(dialog_failure)


func _on_end_delay_timeout():

	GameOverlord.switch_to_level(0)


func _on_quit_button_pressed() -> void:
	
	GameOverlord.end_game()
