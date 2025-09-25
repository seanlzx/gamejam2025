extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO this is only here for testing on sean's setup, 3 monitor setup
	if OS.is_debug_build():
		print("is debug")
		DisplayServer.window_set_current_screen(2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
