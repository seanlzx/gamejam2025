class_name NPC extends CharacterBody2D

var State = "res://entity/utility/state.gd"


var NPCState : String = ConstNpcState.idle

var pickup_tooltip
var curr_state : State
@onready var states_dict = {
	ConstNpcState.idle : $States/Idle,
	ConstNpcState.roam : $States/Roam,
	ConstNpcState.chase : $States/Chase
} 

func change_state(state):
	# TODO might consider skipping if same as previous state
	## item.gd properties
	if curr_state != null:
		curr_state.exit_state()
	NPCState = state
	states_dict[state].enter_state()
	curr_state = states_dict[state]
	
func process_state(delta):
	states_dict[NPCState].process_state(delta)
	
