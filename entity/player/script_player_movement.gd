extends Node

@onready var character: CharacterBody2D = $".."

var move_speed = 100

@export var walk_speed = ConstDefault.player_walk_speed
@export var run_speed = ConstDefault.player_run_speed
@export var sprint_speed = ConstDefault.player_sprint_speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("hotbar_1"):
		#print("DisplayServer.window_get_position(): " + str(DisplayServer.window_get_position()))
		#print("character.get_global_mouse_position(): " + str(character.get_global_mouse_position()))
		#print("get_window().get_mouse_position(): " + str(get_window().get_mouse_position()))1
	move_input(delta)
	right_joypad(delta)

# forget about joypad for now
func right_joypad(delta):
	pass

func right_joypad_old(delta):
	# This is here for test purposes so that, screen isn't spammed with printing
	if not Input.is_action_just_pressed("hotbar_1"):
		return
	
	var input_cursor_direction = Input.get_vector("joypad_mouse_left", "joypad_mouse_right", "joypad_mouse_up", "joypad_mouse_down")
	
	if input_cursor_direction.length() > 0.2:
		var mouse_movement = input_cursor_direction * 500 * delta
		var current_mouse_pos = character.get_global_mouse_position()
		#var current_mouse_pos = get_viewport().get_mouse_position()
		var new_mouse_pos : Vector2 = current_mouse_pos + mouse_movement
		print("current_mouse_pos: " + str(current_mouse_pos))
		print("new_mouse_pos: " +  str(new_mouse_pos))
		
		Input.warp_mouse(new_mouse_pos + Vector2(DisplayServer.window_get_position()))
		print("warp_position: " +  str((new_mouse_pos + Vector2(DisplayServer.window_get_position()))))

func move_input(delta):
	var move_speed = run_speed

	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_pressed("sprint"):
		move_speed = sprint_speed
	
	## NOTE this function is from godot docs, and for some reason they didn't put delta here, so no need probably 
	character.velocity = input_direction * move_speed
