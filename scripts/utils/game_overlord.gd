extends Node

@onready var menu_scene = preload("res://scenes/ui/menu.tscn")
@onready var narrative_scene = preload("res://scenes/narrative/narrative_scene.tscn")
#@onready var level_scene_0 = preload("res://scenes/levels/level0.tscn")
@onready var level_scene_1 = preload("res://scenes/levels/level1.tscn")
@onready var level_scene_2 = preload("res://scenes/levels/level2.tscn")
@onready var level_scene_3 = preload("res://scenes/levels/level3.tscn")
@onready var level_scene_4 = preload("res://scenes/levels/level4.tscn")
@onready var level_scene_challenge = preload("res://scenes/levels/challenge.tscn")
@onready var game_over_scene = preload("res://scenes/narrative/game_over.tscn")

var game_over_text = ""
var game_finished_once = true
var loyauty: int = 0
var last_level: int = 0
var last_score: int = 0
var total_score: int = 0# todo: use it
var high_score: int = 0# todo: use it

# scenes
func start_game() -> void:
	print("manager start game")
	get_tree().change_scene_to_packed(narrative_scene)
	Dialogic.start("intro")

func end_game() -> void:
	print("manager end game to menu")
	last_level = 0
	last_score = 0
	total_score = 0
	if not game_finished_once:
		game_finished_once = true
		
	get_tree().change_scene_to_packed(menu_scene)
	
	
func start_challenge() -> void:
	
	switch_to_level(0)
	
	
	

func switch_to_level(id: int):
	print("manager switch level ", id)
	if (last_level < id): total_score += last_score
	last_level = id
	match id:
		0: get_tree().change_scene_to_packed(level_scene_challenge)
		1: get_tree().change_scene_to_packed(level_scene_1)
		2: get_tree().change_scene_to_packed(level_scene_2)
		3: get_tree().change_scene_to_packed(level_scene_3)
		4: get_tree().change_scene_to_packed(level_scene_4)
		_: printerr("Unknown level id")


func game_over(id: int) -> void:
	print("manager game over number ", id)
	last_level = 0
	last_score = 0
	total_score = 0
	await get_tree().change_scene_to_packed(game_over_scene)
	match id:
		0:
			game_over_text = "Mort par la main de ton père."
		_:
			game_over_text = "C'est la fin pour toi."
	
# loyauty
func get_loyauty():
	return loyauty

func is_still_loyal():
	return loyauty >= 0

func set_loyauty(value):
	loyauty = value

func add_loyauty(value):
	loyauty += value

# score
func get_last_score():
	return last_score

func set_last_score(value):
	last_score = value
