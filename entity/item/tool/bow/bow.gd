extends "res://entity/item/item.gd"

# 1. Constants
const gravity_scale_overwrite: float = 0.0

# 2. States

# 3. Overwrites
@export var	mass_overwrite: float = 2.0

@export var linear_damp_overwrite: int = 3
@export var angular_damp_overwrite: int = 3

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var arrow_scene : Resource = preload("res://entity/item/tool/bow/arrow.tscn")

# 5. Variables 
var arrow_speed : int = 500;
var sweet_spot_to_avoid_player_arrow_collision : int = 80;
# the timing in which the arrow is released
var release : float = 0.47

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# TODO remember this 4 values should be adjusted specifically to this items collision
	offset_from_player = 35
	equipped_capsule_height
	equipped_capsule_radius
	equipped_capsule_rotation = 90
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
	animation_player.play("jab")

func secondary_action(delta, character : CharacterBody2D):
	if animation_player.is_playing():
		return
	run_draw(character.get_node("EquippedPivotPoint"))
	animation_player.play("draw")

func tertiary_action(delta, character : CharacterBody2D):
	pass

func run_draw(character_pivot):
	var arrow = arrow_scene.instantiate()
	await get_tree().create_timer(release).timeout
	
	arrow.position	+= Vector2.UP * sweet_spot_to_avoid_player_arrow_collision

	var velocity = Vector2.RIGHT
	arrow.linear_velocity = velocity.rotated(character_pivot.rotation) * arrow_speed
	# The arrow.read() will reparent 😎😎😎
	add_child(arrow)
