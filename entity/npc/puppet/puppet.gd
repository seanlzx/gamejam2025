extends CharacterBody2D

var move_speed = 100

@export var walk_speed = ConstDefault.player_walk_speed
@export var run_speed = ConstDefault.player_run_speed
@export var sprint_speed = ConstDefault.player_sprint_speed
@export var starting_health = ConstDefault.player_walk_speed


func _physics_process(delta: float) -> void:
	# Add the gravity.
	move_input()
	
	# for the ragdoll effect that I'm going for rotation of base node characterbody2D should have no rotation
	rotation = 0
	
	move_and_slide()

func move_input():
	var move_speed = run_speed

	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if Input.is_action_pressed("sprint"):
		move_speed = sprint_speed
		
	velocity = input_direction * move_speed
	
