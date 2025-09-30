## Description follow player AND teleport

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

var rand_range_stop_from : int = 350;
var rand_range_stop_to : int = 400;

var rand_speed_start_range : int = 100
var rand_speed_end_range : int = 150

var teleport_range : int = 1000

# TODO for testing purposes, -400

# not so varying variables
var speed
var stop_range

func enter_state() -> void:	
	stop_range = RNG.randi_range(rand_range_stop_from, rand_range_stop_to)
	speed = RNG.randi_range(rand_speed_start_range, rand_speed_end_range)

	### prepare class variables and node modifications for search_processing
	detection_shape = parent.detection_shape
	detection_area = parent.detection_area

	
func process_state(delta) -> void:
	# TODO once within range:
	# - stop moving
	# - attack
	if parent.position.distance_to(parent.player.position) < stop_range:
		parent.velocity = Vector2.ZERO
		return
		
	if parent.position.distance_to(parent.player.position) > teleport_range:
		parent.position = parent.player.position + Vector2(randi_range(-100,100),randi_range(-100,100))
	# remember the `parent.player` is assigned the player once on_body_entered detects player
	var velocity = parent.position.direction_to(parent.player.position)
	parent.velocity = velocity * speed
