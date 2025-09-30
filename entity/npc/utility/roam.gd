extends "res://entity/utility/state.gd"
@onready var parent : NPC = $"../.."
# `detection_shape` is indeed a node also
var detection_shape : CollisionShape2D
var detection_area : Area2D

# Constant idk fuckit
var RNG = RandomNumberGenerator.new()

var timer : SceneTreeTimer


# in seconds
var rand_duration_start_range : int = 5
var rand_duration_end_range : int = 15

var rand_speed_start_range : int = 60
var rand_speed_end_range : int = 100

var idle_to_roam_ratio : int = 2

# TODO for testing purposes, -400
var rand_detection_start_range : int = 450
var rand_detection_end_range : int = 600

# varying variables
var detection_radius : int



func enter_state() -> void:
	#print(str(parent) + " entered roaming state")
	## setup roaming 
	var speed = RNG.randi_range(rand_speed_start_range, rand_speed_end_range)
	var velocity = Vector2(speed, 0.0)
	
	var direction = RNG.randf_range(0, PI * 2)
	
	var duration = RNG.randi_range(rand_duration_start_range, rand_duration_end_range)
	
	parent.velocity = velocity.rotated(direction)
	
	## prepare class variables and node modifications for search_processing
	detection_shape = parent.detection_shape
	detection_area = parent.detection_area
	detection_radius = RNG.randi_range(rand_detection_start_range, rand_detection_end_range)
	detection_shape.shape.radius = detection_radius
	
	
	#print(
		#str(parent) + " entered roam state\n" +
		#"speed: " + str(speed) + "\n" +
		#"velocity: " + str(velocity) + "\n" +
		#"direction: " + str(direction) + "\n" +
		#"duration: " + str(duration) + "\n" +
		#"detection_radius: " + str(detection_radius) + "\n\n\n"
	#)
	
	## change to either idle or roam
	timer = get_tree().create_timer(duration)
	await timer.timeout
	
	# only run this if NPCState is still roam, if it's chase this block shouldn't run
	if parent.NPCState == ConstNpcState.roam:
		if RNG.randi_range(1, 10) <= idle_to_roam_ratio:
			parent.change_state(ConstNpcState.idle)
		else:
			parent.change_state(ConstNpcState.roam)
			
	#print("roam.enter_state() exited")		

# important to stop timer when state ends	
func exit_state() -> void:
	# frankly not sure if both or only one of this is needed, but it works so continue
	timer.timeout
	timer.emit_signal("timeout")
