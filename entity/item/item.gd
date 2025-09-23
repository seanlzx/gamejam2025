class_name Item extends RigidBody2D

var State = "res://entity/utility/state.gd"


var ItemState : String = ConstItemState.pickup

var is_pickup_show = false

var pickup_tooltip
var prev_state : State
@onready var states_dict = {
	ConstItemState.pickup : $States/PickupState,
	ConstItemState.inventory : $States/InventoryState,
	ConstItemState.equipped : $States/EquippedState,
} 

var offset_from_player : float = 50

var equipped_capsule_height : float = 30
var equipped_capsule_radius : float = 10
var equipped_capsule_rotation : float = PI / 2
var equipped_capsule_joint1_position : float = 10
var equipped_capsule_joint2_position : float = 20
var pint_joint_displacement_1 : float = 5
var pint_joint_displacement_2 : float = -5

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
	
func primary_action(delta, character : CharacterBody2D):
	pass

func secondary_action(delta, character : CharacterBody2D):
	pass

func tertiary_action(delta, character : CharacterBody2D):
	pass
