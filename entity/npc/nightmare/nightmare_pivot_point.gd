extends RigidBody2D

# 1. Importing Scenes 


# 2. Importing other nodes ?
@onready var character: CharacterBody2D = $".."

@onready var placeholder_capsule_shape_2d: CollisionShape2D = $PlaceholderCapsuleShape2D

@onready var pin_joint_1: PinJoint2D = $PlaceholderCapsuleShape2D/PinJoint1
@onready var pin_joint_2: PinJoint2D = $PlaceholderCapsuleShape2D/PinJoint2



# 3. CONSTANTS
const EQUIPPED_ROTATION : float = PI / 2
var RNG = RandomNumberGenerator.new()

# 4. Overwrites ??


# 5. Class ???
var global_equipped_offset : float
var equipped : Item


# 6. Built-in Methods 


# 7. Methods

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = ConstCollisionLayer.base
	collision_mask = ConstCollisionLayer.base
	
	# this tempItem is here entirely just to retrieve default class properties
	# for some reason godot allows you to read class constants but not class vars
	var tempItem : Item = Item.new()
	
	global_equipped_offset = tempItem.offset_from_player
	placeholder_capsule_shape_2d.position.x = global_equipped_offset
	placeholder_capsule_shape_2d.shape.height = tempItem.equipped_capsule_height
	placeholder_capsule_shape_2d.shape.radius = tempItem.equipped_capsule_radius

	tempItem.queue_free()
	# TODO temporary for testing
	#if Input.is_action_just_pressed("hotbar_0"):

	if RNG.randi_range(1,10) < 3:
		var sworg: Item = preload("res://entity/item/tool/sworg/sworg.tscn").instantiate()
		equip(sworg)
	else:
		var sword: Item = preload("res://entity/item/tool/sword/sword.tscn").instantiate()
		equip(sword)

func _process(delta: float) -> void:
	
	# the fix was simple, just use get_global_mouse_position() NOT get_viewport.get_mouse_position()
	
	# IMPORTANT This is to keep the PivotPoint itself centered on player parent
	position = Vector2.ZERO
	
	# IMPORTANT This is to keep the placeholder_capsule steady
	placeholder_capsule_shape_2d.position.y = 0
	placeholder_capsule_shape_2d.position.x = global_equipped_offset
	placeholder_capsule_shape_2d.rotation = EQUIPPED_ROTATION
	
	#placeholder_capsule_shape_2d.rotation = EQUIPPED_ROTATION
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
	equipped.position.x = equipped.offset_from_player + character.equipped_offset_to_offset
	#equipped.position.y = 0
	#equipped.rotation = EQUIPPED_ROTATION
	
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
	
