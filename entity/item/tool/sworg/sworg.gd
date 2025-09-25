extends "res://entity/item/item.gd"

# 1. Constants
const gravity_scale_overwrite: float = 0.0

# 2. States

# 3. Overwrites
@export var	mass_overwrite: float = 2.0

@export var linear_damp_overwrite: int = 3
@export var angular_damp_overwrite: int = 3

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# 5. Variables specific to this item
var swing_speed : float = 20
var damage : int = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# TODO remember this 4 values should be adjusted specifically to this items collision
	offset_from_player = 60
	equipped_capsule_height = 30
	equipped_capsule_radius = 10
	equipped_capsule_rotation  = 90
	pint_joint_displacement_1
	pint_joint_displacement_2
	
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
	
func primary_action(delta, character : CharacterBody2D):
	animation_player.play("swing_left")

func secondary_action(delta, character : CharacterBody2D):
	animation_player.play("swing_right")


func tertiary_action(delta, character : CharacterBody2D):
	animation_player.play("stab")
