extends CharacterBody3D

@export var SPEED_MAX: float = 12.0
@export var SPEED_ACCELERATION: float = 1.
@export var SPEED_DECELERATION: float = .05

@export var visual_rotated: Node3D
@export var level: Level
@export var walk_animation: AnimationPlayer
@export var walk_speed: float = 1

# Audio
@onready var sfx_galop = preload("res://assets/audio/sfx/Loop_Galop.ogg")
@onready var sfx_horse_neigh = [preload("res://assets/audio/sfx/OS_Cheval_Henissement1.ogg"), preload("res://assets/audio/sfx/OS_Cheval_Henissement2.ogg")]
@onready var sfx_horse_sniff = [preload("res://assets/audio/sfx/OS_Cheval_Renifle1.ogg"), preload("res://assets/audio/sfx/OS_Cheval_Renifle2.ogg"), preload("res://assets/audio/sfx/OS_Cheval_Renifle3.ogg"), preload("res://assets/audio/sfx/OS_Cheval_Renifle4.ogg")]
@onready var galop_player: AudioStreamPlayer3D = $GalopPlayer
@onready var horse_player: AudioStreamPlayer3D = $HorsePlayer
@onready var neigh_timer: Timer = $NeighTimer

var last_facing: Vector2

func _ready() -> void:
	galop_player.stream = sfx_galop


func _physics_process(delta: float) -> void:
	if not is_on_floor(): velocity += get_gravity() * delta
	
	if (!level || level.started):
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = move_toward(velocity.x, direction.x * SPEED_MAX, SPEED_ACCELERATION)
			velocity.z = move_toward(velocity.z, direction.z * SPEED_MAX, SPEED_ACCELERATION)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED_DECELERATION)
			velocity.z = move_toward(velocity.z, 0, SPEED_DECELERATION)
		
		var facing = last_facing
		
		if velocity:
			facing = Vector2(velocity.x, velocity.z).normalized()
			last_facing = facing
			
			if not galop_player.playing:
				galop_player.play()
			
		else:
			facing = last_facing
			
			if galop_player.playing:
				galop_player.stop()
				horse_player.stream = sfx_horse_sniff.pick_random()
				horse_player.play()

		#print("facing:", facing, facing.angle(), visual_rotated.rotation)
		visual_rotated.rotation.y = -facing.angle() + PI / 2

	var animation_speed = velocity.length() / 10 * walk_speed
	if (animation_speed > 0):
		walk_animation.play("Armature|ArmatureAction")
		walk_animation.speed_scale = animation_speed
	else:
		walk_animation.stop()
		walk_animation.seek(.6, true)

		
	move_and_slide()


func _on_neigh_timer_timeout() -> void:
	
	if not horse_player.playing:
		
		horse_player.stream = sfx_horse_neigh.pick_random()
		horse_player.play()
		
	neigh_timer.wait_time = randf_range(3, 12)
	neigh_timer.start()
