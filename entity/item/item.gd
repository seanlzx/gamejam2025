class_name Item extends RigidBody2D

var State = "res://entity/utility/state.gd"


var ItemState : String = ConstItemState.pickup

var is_pickup_show = false

var pickup_tooltip
var prev_state : State
@onready var states_dict = {
	ConstItemState.pickup : $States/PickupState
} 

var offset_from_player : float


func show_pickup_tooltip():
	if is_pickup_show:
		return
	pickup_tooltip.show()
	is_pickup_show = true

func hide_pickup_tooltip():
	if not is_pickup_show:
		return
	pickup_tooltip.hide()
	is_pickup_show = false

func change_state(state):
	# TODO might consider skipping if same as previous state
	## item.gd properties
	if prev_state != null:
		prev_state.exit_state()
	ItemState = state
	states_dict[state].enter_state()
	prev_state = states_dict[state]
