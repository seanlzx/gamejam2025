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
# so far swing_speed is unused
var swing_speed : float = 20
var damage : int = 10

var character : CharacterBody2D

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
	
	# collision detection
	body_entered.connect(impact)
	contact_monitor = true
	max_contacts_reported = 10

func _process(delta):
	pass
	
func primary_action(delta, character_arg : CharacterBody2D):
	character = character_arg
	animation_player.play("swing_right")

func secondary_action(delta, character_arg : CharacterBody2D):
	character = character_arg
	animation_player.play("swing_left")

func tertiary_action(delta, character_arg : CharacterBody2D):
	character = character_arg
	animation_player.play("stab")

func impact(rigid_body):
	var collision_point = global_position
	var relative_velocity = linear_velocity - rigid_body.linear_velocity
	var impact_force = relative_velocity.length() * damage * impact_damage_multiplier
	var rigid_body_parent = rigid_body.get_parent()
	# `rigid_body_parent != character` prevents characters from hurting themselves
	if rigid_body_parent.has_method("take_damage") && rigid_body_parent != character :
		var character_body = rigid_body_parent
		character_body.take_damage(impact_force)
