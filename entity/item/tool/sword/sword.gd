extends "res://entity/item/item.gd"

# 1. Constants
const gravity_scale_overwrite: float = 0.0

# 2. States

# 3. Overwrites
@export var	mass_overwrite: float = 2.0

@export var linear_damp_overwrite: int = 3
@export var angular_damp_overwrite: int = 3


# 5. Variables
# offset from player is negative as this is going UP


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	offset_from_player = -60
	
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
	
