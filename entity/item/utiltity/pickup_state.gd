extends "res://entity/utility/state.gd"
@onready var parent_item = $"../.."

var timer 

# in seconds
# TODO for testing purposes put as 10 seconds but ought to set to 60
var free_duration = 10


func enter_state() -> void:
	print("enter pickup state")
	timer = get_tree().create_timer(free_duration)
	await timer.timeout
	if parent_item.ItemState == ConstItemState.pickup:
		parent_item.queue_free()
		print("queue free")
	else:
		print("item no longer pickup")
