extends "res://entity/utility/state.gd"
@onready var parent : NPC = $"../.."
# `detection_shape` is indeed a node also
var detection_shape : CollisionShape2D
var detection_area : Area2D

# Constant idk fuckit
var RNG = RandomNumberGenerator.new()

var timer : SceneTreeTimer

var leftmost_position : Vector2 
var rightmost_position : Vector2

var isWalkingRight : bool = true

var speed = 100

var pause = false

func enter_state() -> void:
	#print(str(parent) + " entered roaming state")
	## setup leftmost and rightmost 
	leftmost_position = parent.position + Vector2(-200, 0)
	rightmost_position = parent.position + Vector2(200, 0)
	

# important to stop timer when state ends	
func exit_state() -> void:
	pass

func process_state(delta) -> void:
	parent.velocity = Vector2.ZERO
	
	if pause:
		return
	
	if isWalkingRight: 	
		parent.velocity = Vector2.RIGHT * speed
	else:
		parent.velocity = Vector2.LEFT * speed
	
	if parent.position.x > rightmost_position.x:
		isWalkingRight = false
		if randi_range(1,4) == 1:
			pause_a_while()
		
	if parent.position.x < leftmost_position.x:
		isWalkingRight = true
		if randi_range(1,4) == 1:
			pause_a_while()
		
func pause_a_while():
	pause = true
	await get_tree().create_timer(3).timeout
	pause = false

	
