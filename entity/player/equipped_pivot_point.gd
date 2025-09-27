extends RigidBody2D

# first of this line doesn't work, secondly don't need to declared this import, class_name automatically make thes class global
#const Item = preload("res://entity/item/item.gd").Item

var Collision
@onready var hotbar: CanvasLayer = $"../inventory/Hotbar"

@onready var placeholder_capsule_shape_2d: CollisionShape2D = $PlaceholderCapsuleShape2D

const equipped_rotation : float = PI / 2

var global_equipped_offset : float
var equipped : Item

@onready var pin_joint_1: PinJoint2D = $PlaceholderCapsuleShape2D/PinJoint1
@onready var pin_joint_2: PinJoint2D = $PlaceholderCapsuleShape2D/PinJoint2

@onready var character: CharacterBody2D = $".."

func InputActions(delta):
	if Input.is_action_just_pressed("primary_action"):
		equipped.primary_action(delta, character)
	if Input.is_action_just_pressed("secondary_action"):
		equipped.secondary_action(delta, character)
	if Input.is_action_just_pressed("tertiary_action"):
		equipped.tertiary_action(delta, character)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# TODO no idea if this will work
	#TODO put sword here
	equip(null)
	
	collision_layer = ConstCollisionLayer.base
	collision_mask = ConstCollisionLayer.base
	
	# this tempItem is here entirely just to retrieve default class properties
	# for some reason godot allows you to read class constants but not class vars
	var tempItem : Item = Item.new()
	
	# set this initial values, or else the collision capsule within the player and send him flying
	global_equipped_offset = tempItem.offset_from_player
	placeholder_capsule_shape_2d.position.x = global_equipped_offset
	placeholder_capsule_shape_2d.shape.height = tempItem.equipped_capsule_height
	placeholder_capsule_shape_2d.shape.radius = tempItem.equipped_capsule_radius

	tempItem.queue_free()

func _process(delta: float) -> void:
	if equipped is Item:
		InputActions(delta)
	
	# the fix was simple, just use get_global_mouse_position() NOT get_viewport.get_mouse_position()
	look_at(get_global_mouse_position())
	
	# IMPORTANT This is to keep the PivotPoint itself centered on player parent
	position = Vector2.ZERO
	
	# IMPORTANT This is to keep the placeholder_capsule steady
	placeholder_capsule_shape_2d.position.y = 0
	placeholder_capsule_shape_2d.position.x = global_equipped_offset
	placeholder_capsule_shape_2d.rotation = equipped_rotation
	
	#placeholder_capsule_shape_2d.rotation = equipped_rotation
	#if hotbar.equipped is Item:
		#print(placeholder_capsule_shape_2d.rotation)

func unequip(equipped_arg : Item):
	placeholder_capsule_shape_2d.remove_child(equipped_arg)
	equipped_arg.change_state(ConstItemState.inventory)
	equipped = null

func equip(equipped_arg : Item):
	if equipped_arg is not Item:
		return
		
	equipped = equipped_arg
		
	#NOTE This is not necessary as the sowrd is going to be child of the placeholder_capsule itself
	#equipped.position.x = equipped.offset_from_player
	#equipped.position.y = 0
	#equipped.rotation = equipped_rotation
	
	#NOTE however this if sword is going to be child of the placeholder_capsule itself
	equipped.position = Vector2.ZERO
	equipped.rotation = 0
	

	placeholder_capsule_shape_2d.shape.height = equipped.equipped_capsule_height
	placeholder_capsule_shape_2d.shape.radius = equipped.equipped_capsule_radius
	placeholder_capsule_shape_2d.rotation = equipped.equipped_capsule_rotation
	# screw this just make placeholder collsion a 'shape' and  'capsule'
	equipped.equipped_capsule_joint1_position
	equipped.equipped_capsule_joint2_position
	
	placeholder_capsule_shape_2d.add_child(equipped)
	
	equipped.change_state(ConstItemState.equipped)
	
	# modify joints joints
	
	pin_joint_1.node_a = NodePath("../..")
	pin_joint_1.node_b = NodePath(equipped.get_path())
	pin_joint_2.node_a = NodePath("../..")
	pin_joint_2.node_b = NodePath(equipped.get_path())
	
	pin_joint_1.position.y = equipped.pint_joint_displacement_1
	pin_joint_2.position.y = equipped.pint_joint_displacement_2
	
