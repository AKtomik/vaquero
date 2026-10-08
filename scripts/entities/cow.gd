extends CharacterBody3D
class_name Cow

# Algo source: https://kindatechnical.com/game-development/steering-behaviors-seek-flee-arrive-and-flocking.html

@export var cow_mesh: MeshInstance3D
@export var cow_shape: CollisionShape3D
@export var cow_obstacle_detection_shape: CollisionShape3D

@export_group("General var")
@export var MAX_SPEED_IDLE: float = 5.0
@export var MAX_SPEED_FLEE: float = 10.0 # Used when fleeing
@export var MAX_FORCE: float = 200.0 # Max steering force
@export var MASS: float = 1.0
@export var GREAT_SPEED_FACTOR: float = 1.0

@export_group("Wander var")
@export var WANDER_RADIUS: float = 1.5 # Circle radius
@export var WANDER_DISTANCE: float = 2.0 # Circle distance ahead
@export var WANDER_JITTER: float = 0.3 # Random angle change per frame
@export var WANDER_WEIGHT: float = 0.2
var wander_angle: float = 0 # Current wander angle

@export_group("Flee var")
var panic_by: Array = []
@export var FLEE_WEIGHT: float = 20.0

@export_group("Flock var")
@export var SEPARATION_RADIUS: float = 2.0 # Personal space
@export var ALIGNMENT_RADIUS: float = 5.0 # Velocity matching range
@export var COHESION_RADIUS: float = 8.0 # Group attraction range
@export var SEPARATION_WEIGHT: float = 1.5
@export var ALIGNMENT_WEIGHT: float = 1.0
@export var COHESION_WEIGHT: float = 1.0
@export var FLOCK_WEIGHT: float = 0.5
var neighbours: Array = []

@export_group("Obstacles var")
var obstacles: Array[Node3D] = []
@export var OBSTACLE_WEIGHT: float = 10.0
@export var OBSTACLE_LOOK_AHEAD: float = 5.0
@export var OBSTACLE_MAX_DIST: float = 100.0

@export_group("Animation")
@export var walk_animation: AnimationPlayer
@export var walk_speed: float = 1

# Audio
@onready var mow_timer: Timer = $AudioStreamPlayer3D/MowTimer
@onready var mow_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	
	wander_angle = randf_range(0, 2 * PI)
	

func _physics_process(delta: float) -> void:
	
	var max_speed = MAX_SPEED_IDLE
	
	var wander_force = wander()
	
	var flee_force = Vector3.ZERO
	var count: int = 0
	for t in panic_by:
		flee_force += flee(t)
		count += 1
	if count > 0:
		flee_force = flee_force / float(count)
		max_speed = MAX_SPEED_FLEE
		
	var flock_force = flock()
	
	var obstacle_avoidance_force = obstacle_avoidance()
	
	# Priority based truncation
	var composite_force = obstacle_avoidance_force * OBSTACLE_WEIGHT
	if composite_force.length() < MAX_FORCE:
		composite_force = flee_force * FLEE_WEIGHT
	if composite_force.length() < MAX_FORCE:
		composite_force += flock_force * FLOCK_WEIGHT
	if composite_force.length() < MAX_FORCE:
		composite_force += wander_force * WANDER_WEIGHT
	apply_steering_force(composite_force, max_speed, delta)
	
	# Rotate to face the right direction
	var current_direction = global_position + velocity
	look_at(current_direction)

	var animation_speed = velocity.length() / 10 * walk_speed
	if (animation_speed > 0):
		walk_animation.play("Armature_001|ArmatureAction")
		walk_animation.speed_scale = animation_speed
	else:
		walk_animation.stop()
		walk_animation.seek(.6, true)

	move_and_slide()


func apply_steering_force(steering_force: Vector3, max_speed: float, dt: float) -> void:
	
	# Truncate to max force
	if steering_force.length() > MAX_FORCE:
		steering_force = steering_force.normalized() * MAX_FORCE
		
	var acceleration = steering_force / MASS
	
	# Update velocity
	velocity += acceleration * dt * GREAT_SPEED_FACTOR
	
	# Clamp to max speed
	if velocity.length() > max_speed * GREAT_SPEED_FACTOR:
		velocity = velocity.normalized() * max_speed * GREAT_SPEED_FACTOR


func wander() -> Vector3:
	
	wander_angle += randf_range(- WANDER_JITTER, WANDER_JITTER)
	
	# Point on circle in front of agent
	var circle_center: Vector3 = velocity.normalized() * WANDER_DISTANCE
	var displacement: Vector3 = Vector3(cos(wander_angle), 0, sin(wander_angle)) * WANDER_RADIUS
	var force = circle_center + displacement
	
	return force


func seek(target: Vector3) -> Vector3:
	
	var desired: Vector3 = (target - position).normalized() * MAX_SPEED_IDLE
	var force = desired - velocity
	
	return force


func flee(threat: Area3D) -> Vector3:
	
	var desired: Vector3 = (global_position - threat.global_position).normalized() * MAX_SPEED_FLEE
	var force = desired - velocity
	
	return force
	
	
func flock() -> Vector3:
	
	return flock_separation() * SEPARATION_WEIGHT + flock_alignement() * ALIGNMENT_WEIGHT + flock_cohesion() * COHESION_WEIGHT
	
func flock_separation() -> Vector3:
	
	var force: Vector3 = Vector3(0, 0, 0)
	var count: int = 0
	for n in neighbours:
		var distance: float = position.distance_to(n.position)
		if distance < SEPARATION_RADIUS and distance > 0:
			var away: Vector3 = position - n.position
			force += away.normalized() / distance # Closer = stronger
			count += 1
	
	if count > 0:
		force = force / float(count)
		
	return force

func flock_alignement() -> Vector3:
	
	var average_velocity: Vector3 = Vector3(0, 0, 0)
	var count: int = 0
	for n in neighbours:
		var distance: float = position.distance_to(n.position)
		if distance < ALIGNMENT_RADIUS:
			average_velocity += n.velocity
			count += 1
	
	if count == 0:
		return Vector3.ZERO
		
	average_velocity = average_velocity / float(count)
	
	return average_velocity - velocity
	
func flock_cohesion() -> Vector3:
	
	var centre_of_mass: Vector3 = Vector3.ZERO
	var count: int = 0
	for n in neighbours:
		var distance: float = position.distance_to(n.position)
		if distance < COHESION_RADIUS:
			centre_of_mass += n.position
			count += 1
			
	if count == 0:
		return Vector3.ZERO
		
	centre_of_mass = centre_of_mass / float(count)
	
	return seek(centre_of_mass)
	
	
func obstacle_avoidance() -> Vector3:
	
	if !obstacles: return Vector3.ZERO
	
	var look_ahead: float = velocity.length() / MAX_SPEED_FLEE * OBSTACLE_LOOK_AHEAD
	var ahead: Vector3 = position + velocity.normalized() * look_ahead
	var half_ahead: Vector3 = position + velocity.normalized() * look_ahead * 0.5
	
	# Find the most threatening obstacle
	var nearest: StaticBody3D = null
	var nearest_distance: float = OBSTACLE_MAX_DIST
	
	for o in obstacles:
		var d1: float = ahead.distance_to(o.global_position)
		var d2: float = half_ahead.distance_to(o.global_position)
		var d3: float = position.distance_to(o.global_position)
		var closest: float = min(d1, d2, d3)
		
		if closest < nearest_distance:
			nearest_distance = closest
			nearest = o

	if nearest == null: return Vector3.ZERO
		
	var avoidance: Vector3 = ahead - nearest.global_position
	return avoidance.normalized() * MAX_FORCE


func _on_panic_area_entered(area: Area3D) -> void:
	panic_by.append(area)

func _on_panic_area_exited(area: Area3D) -> void:
	panic_by.erase(area)


func _on_obstacle_detection_area_entered(area: Area3D) -> void:
	if area.is_in_group("obstacles") and area not in obstacles:
		obstacles.append(area)

func _on_obstacle_detection_area_exited(area: Area3D) -> void:
	if area.is_in_group("obstacles") and area in obstacles:
		obstacles.erase(area)

func _on_obstacle_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("obstacles") and body not in obstacles:
		obstacles.append(body)
		#print("_on_obstacle_detection_body_entered", obstacles)

func _on_obstacle_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group("obstacles") and body in obstacles:
		obstacles.erase(body)


func _on_neighbours_detection_body_entered(body: Node3D) -> void:
	if body not in obstacles:
		neighbours.append(body)
		#print("_on_neighbours_detection_body_entered", neighbours, since)

func _on_neighbours_detection_body_exited(body: Node3D) -> void:
	if body in neighbours:
		neighbours.erase(body)
		#print("_on_neighbours_detection_body_exited", neighbours, since)


func _on_mow_timer_timeout() -> void:
	
	mow_player.play()
	
	mow_timer.wait_time = randf_range(5, 20)
	mow_timer.start()
