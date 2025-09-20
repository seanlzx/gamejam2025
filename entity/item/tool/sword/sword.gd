extends "res://entity/item/item.gd"

var State = "res://entity/utility/state.gd"

# 1. Constants
const gravity_scale_overwrite: float = 0.0

# 2. States
@onready var states_dict = {
	ConstItemState.pickup : $States/PickupState
} 
var prev_state : State 

# 3. Overwrites
@export var	mass_overwrite: float = 2.0

@export var linear_damp_overwrite: int = 3
@export var angular_damp_overwrite: int = 3


# 5. Variables

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	change_state(ConstItemState.pickup)
	
	
	pickup_tooltip = $PickupTooltip
	
	
	pickup_tooltip.hide()
	
	gravity_scale = gravity_scale_overwrite
	mass = mass_overwrite
	linear_damp = linear_damp_overwrite
	angular_damp = angular_damp_overwrite
	pass # Replace with function body.

func _process(delta):
	pass
	
func change_state(state):
	# TODO might consider skipping if same as previous state
	## item.gd properties
	if prev_state != null:
		prev_state.exit_state()
	ItemState = state
	states_dict[state].enter_state()
	prev_state = states_dict[state]
