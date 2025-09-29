extends "res://entity/utility/state.gd"
@onready var parent : CharacterBody2D = $"../.."
# `detection_shape` is indeed a node also
var detection_shape : CollisionShape2D
var detection_area : Area2D

var RNG = RandomNumberGenerator.new()

var timer : SceneTreeTimer

# in seconds
# TODO for testing purposes put as 10 seconds but ought to set to 60
var free_duration = 100

var rand_from_stand_and_attack_range : int = 80;
var rand_to_stand_and_attack_range : int = 100;

var rand_speed_start_range : int = 170
var rand_speed_end_range : int = 200

# TODO for testing purposes, -400

var rand_combat_start_range : int = 800 # - 400
var rand_combat_end_range : int = 1000 # - 400
# varying variables
var detection_radius : int

# not so varying variables
var speed
var attack_range

func enter_state() -> void:
	print(str(parent) + " entered chase state")
	
	attack_range = RNG.randi_range(rand_from_stand_and_attack_range, rand_to_stand_and_attack_range)
	speed = RNG.randi_range(rand_speed_start_range, rand_speed_end_range)
	
	### prepare class variables and node modifications for search_processing
	detection_shape = parent.detection_shape
	detection_area = parent.detection_area
	var combat_radius = RNG.randi_range(rand_combat_start_range, rand_combat_end_range)
	detection_shape.shape.radius = combat_radius

	
func process_state(delta) -> void:
	# TODO once within range:
	# - stop moving
	# - attack
	if parent.position.distance_to(parent.player.position) < attack_range:
		parent.velocity = Vector2.ZERO
		return
		
	# remember the `parent.player` is assigned the player once on_body_entered detects player
	var velocity = parent.position.direction_to(parent.player.position)
	parent.velocity = velocity * speed
