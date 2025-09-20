extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("hello")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	right_joypad_old(delta)

func right_joypad_old(delta):
	# This is here for test purposes so that, screen isn't spammed with printing
	#if not Input.is_action_just_pressed("hotbar_1"):
		#return
	
	var input_cursor_direction = Input.get_vector("joypad_mouse_left", "joypad_mouse_right", "joypad_mouse_up", "joypad_mouse_down")
	
	if input_cursor_direction.length() > 0.2:
		var mouse_movement = input_cursor_direction * 500 * delta
		var current_mouse_pos = get_viewport().get_mouse_position() + Vector2(DisplayServer.window_get_position())
		var new_mouse_pos : Vector2 = current_mouse_pos + mouse_movement
		print("current_mouse_pos: " + str(current_mouse_pos))
		print("new_mouse_pos: " +  str(new_mouse_pos))
		
		#Input.warp_mouse(new_mouse_pos + Vector2(DisplayServer.window_get_position()))
		Input.warp_mouse(new_mouse_pos)
		print("warp_position: " +  str((new_mouse_pos + Vector2(DisplayServer.window_get_position()))))
