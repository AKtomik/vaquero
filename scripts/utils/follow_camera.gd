extends Camera3D

@export var level: Level
@export var follow_node: Node3D
var position_difference: Vector3
var position_followed: Vector3

@export var magnet_position: Node3D
@export var starting_position: Node3D

@export var ALIGN_SPEED: float = .09
@export var CINEMATIC_SPEED: float = .09
@export_range(0, 1) var MIDDLE_RATIO: float = .5
@export_range(-3, 10) var FOLLOW_EXAGERATION: float = 0

@export var Y_LOCK_ENABLED: bool = false
var y_lock_value: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position_followed = starting_position.position
	y_lock_value = position.y
	position_difference = position - follow_node.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var ideal_position = magnet_position.position.lerp(follow_node.position + position_difference, MIDDLE_RATIO)
	if (level.cinematic): position_followed = position_followed.move_toward(ideal_position, CINEMATIC_SPEED)
	else: position_followed = position_followed.lerp(ideal_position, ALIGN_SPEED)

	var unalignement = ideal_position - position_followed
	position = position_followed
	
	if (level.started): position = position + unalignement * FOLLOW_EXAGERATION
	else:
		position_followed = position_followed.move_toward(ideal_position, ALIGN_SPEED)
		if (unalignement.length() < .1):
			position_followed = ideal_position
			level.cinematic_end()
	
	if (Y_LOCK_ENABLED): position.y = y_lock_value
