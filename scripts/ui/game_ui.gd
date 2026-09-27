class_name PlayUI
extends Control

@onready var SCORE_LABEL: Label = $HerdingScore
@onready var TIMER_LABEL: Label = $TimeScore

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func update_herding_score(value, objective):
	SCORE_LABEL.text = str(value) + "I" + str(objective)

func update_timer(progress, max):
	TIMER_LABEL.text = str(round((max - progress) * 10) / 10)
