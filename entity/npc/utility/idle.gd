extends "res://entity/utility/state.gd"

@onready var parent : CharacterBody2D = $"../.."

# Constant idk fuckit
var RNG = RandomNumberGenerator.new()

var timer 


# in seconds
# TODO for testing purposes put as 10 seconds but ought to set to 60
var rand_start_range : int =  5
var rand_end_range : int = 10

func enter_state() -> void:
	if "idle_range_from" in parent && parent.idle_range_from != null:
		rand_start_range = parent.idle_range_from
	if "idle_range_to" in parent && parent.idle_range_to != null:
		rand_end_range = parent.idle_range_to

	print(str(parent) + " entered idle state")
	var duration = RNG.randi_range(rand_start_range, rand_end_range)
	timer = get_tree().create_timer(duration)
	await timer.timeout
	parent.change_state(ConstNpcState.roam)
