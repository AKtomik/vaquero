extends Node2D

@export var credits_layer: CanvasLayer

@export var mute_button: TextureButton
@export var sound_on_idle = preload("res://assets/UI/sound on_idle.png")
@export var sound_on_hover = preload("res://assets/UI/sound on_hover.png")
@export var sound_off_idle = preload("res://assets/UI/sound off_idle.png")
@export var sound_off_hover = preload("res://assets/UI/sound off_hover.png")

@export var best_category: Control
@export var best_tag_play: Label
@export var best_tag_challenge: Label

var sound_on: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	MusicPlayer.play_music_start()
	
	if GameOverlord.game_finished_once:
		print("challenge aviable")
		$CanvasLayer/Challenge.disabled = false
		$CanvasLayer/Challenge.visible = true
		best_category.visible = true
		best_tag_play.text = "Campagne: "+str(GameOverlord.high_score_campaign)
		best_tag_challenge.text = "Défis: "+str(GameOverlord.high_score_challenge)
	else:
		print("no challenge")
		$CanvasLayer/Challenge.disabled = true
		$CanvasLayer/Challenge.visible = false
		best_category.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

var d_count = 0
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if (event.keycode == KEY_D):
				d_count += 1
				if (d_count >= 3):
					GameOverlord.game_finished_once = !GameOverlord.game_finished_once
					get_tree().reload_current_scene()
			else:
				d_count = 0

func _on_start_pressed() -> void:
	
	play_button_sound()
	GameOverlord.start_game()


func _on_credits_pressed() -> void:
	
	play_button_sound()
	credits_layer.visible = true


func _on_quit_pressed() -> void:
	
	play_button_sound()
	get_tree().quit()


func _on_return_pressed() -> void:
	
	play_button_sound()
	credits_layer.visible = false


func play_button_sound() -> void:
	
	SfxPlayer.play_button_click()


func _on_mute_pressed() -> void:
	
	var master_bus = AudioServer.get_bus_index("Master")
	
	if sound_on:
		sound_on = false
		mute_button.texture_normal = sound_off_idle
		mute_button.texture_hover = sound_off_hover
		AudioServer.set_bus_volume_db(master_bus, -80)
		
	else:
		sound_on = true
		mute_button.texture_normal = sound_on_idle
		mute_button.texture_hover = sound_on_hover
		AudioServer.set_bus_volume_db(master_bus, 0)


func _on_challenge_pressed() -> void:
	
	GameOverlord.start_challenge()
	
