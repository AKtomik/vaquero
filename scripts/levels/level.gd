class_name Level
extends Node3D

@export_group("propeties")
@export var duration_seconds: float = 60
@export var progress_seconds: float = 0
@export var score_goal: int = 2
@export var do_good_score_end: bool = true
var score_current = 0

@export_group("links")
@export var sun_node: DirectionalLight3D
@export var pen_node: Pen
@export var ui_node: PlayUI

@export_group("next")
@export var scene_success: PackedScene
@export var dialog_success: DialogicTimeline
@export var scene_failure: PackedScene
@export var dialog_failure: DialogicTimeline

# Audio
@export_group("audio")
@export var ambient: AudioStream
@onready var music_arcade = preload("res://assets/audio/music/Theme4_V2Corridos.ogg")
@onready var sfx_game_over = preload("res://assets/audio/sfx/GIMMICK_Defeat.ogg")
@onready var sfx_victory = preload("res://assets/audio/sfx/GIMMICK_Victory.ogg")
@onready var sfx_feedback_enter_pen = [preload("res://assets/audio/sfx/FB_Enclos1.ogg"), preload("res://assets/audio/sfx/FB_Enclos2.ogg"), preload("res://assets/audio/sfx/FB_Enclos3.ogg"), preload("res://assets/audio/sfx/FB_Enclos4.ogg"), preload("res://assets/audio/sfx/FB_Enclos5.ogg")]
var sfx_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer

# state
var cinematic = true
var started = false
var ended = false

# Timer to add a delay at the end of the level
var end_delay_timer: Timer

func setup():
	ui_node.visible = false
	ui_node.update_herding_score(score_current, score_goal)
	
	MusicPlayer.stream = music_arcade
	MusicPlayer.play()
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	var sfx_feedback_randomizer = AudioStreamRandomizer.new()
	for s in sfx_feedback_enter_pen:
		sfx_feedback_randomizer.add_stream(-1, s)
	sfx_feedback_randomizer.random_pitch = 2.0
	sfx_player.stream = sfx_feedback_randomizer
	
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "SFX"
	add_child(ambient_player)
	ambient_player.stream = ambient
	ambient_player.play()
	
	end_delay_timer = Timer.new()
	end_delay_timer.wait_time = 3
	add_child(end_delay_timer)
	end_delay_timer.timeout.connect(_on_end_delay_timeout)

func start():
	cinematic = false
	started = true
	ui_node.visible = true
	print("level started!")

func level_end():
	print("level end! ", score_current, "/", score_goal)
	GameOverlord.set_last_score(score_current)
	ended = true
	if score_current >= score_goal:
		sfx_player.stream = sfx_victory
		sfx_player.play()
		end_delay_timer.start()
	else:
		sfx_player.stream = sfx_game_over
		sfx_player.play()
		if (scene_failure): get_tree().change_scene_to_packed(scene_failure)
		if (dialog_failure): Dialogic.start(dialog_failure)

# score_current
func add_score():
	if (ended): return
	score_current += 1
	ui_node.update_herding_score(score_current, score_goal)
	sfx_player.play()
	if (do_good_score_end && score_current >= score_goal): level_end()

func remove_score():
	if (ended): return
	score_current -= 1
	ui_node.update_herding_score(score_current, score_goal)

# loop
func _ready() -> void:
	pen_node.cow_enter_pen.connect(add_score)
	pen_node.cow_left_pen.connect(remove_score)
	setup()
	print("level ready!")

func _process(delta: float) -> void:
	if (started && !ended): progress_seconds += delta
	
	ui_node.update_timer(progress_seconds, duration_seconds)
	
	var progress = progress_seconds / duration_seconds
	sun_node.rotation.x = - progress * PI
	if (progress >= 1 && !ended): level_end()


func _on_end_delay_timeout():

	if (scene_success): get_tree().change_scene_to_packed(scene_success)
	if (dialog_success): Dialogic.start(dialog_success)
	
