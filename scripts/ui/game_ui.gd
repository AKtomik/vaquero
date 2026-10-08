class_name PlayUI
extends Control

@onready var SCORE_LABEL: Label = $HerdingScore
@onready var TIMER_LABEL: Label = $TimeScore
@onready var TITLE_LABEL: Label = $TitleText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_title("")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func update_herding_score(value, objective):
	SCORE_LABEL.text = str(value) + "/" + str(objective)

func update_timer(progress, max):
	TIMER_LABEL.text = str(round((max - progress) * 10) / 10)
	
func update_title(text: String):
	TITLE_LABEL.text = text
