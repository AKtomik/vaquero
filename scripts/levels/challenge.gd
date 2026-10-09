class_name Challenge
extends Level

@export var scene_cow: PackedScene
@export var parent_cow: Node3D

@export var respawn_nodes_parent: Node3D
var respawn_points: Array = []

@export var do_end_to_menu = false

func _ready() -> void:
	super._ready()
	respawn_points = respawn_nodes_parent.get_children().map(func(n: Node3D): return Vector3(n.position.x, n.position.y, n.position.z))

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

func add_score():
	super.add_score()
	var respawn = respawn_points.pick_random()
	var cow = scene_cow.instantiate()
	parent_cow.add_child(cow)
	cow.position = respawn
	print("spawn cow:", cow, " at:", respawn)
