extends RigidBody2D

# first of this line doesn't work, secondly don't need to declared this import, class_name automatically make thes class global
#const Item = preload("res://entity/item/item.gd").Item

var Collision
@onready var hotbar: CanvasLayer = $"../inventory/Hotbar"

@onready var placeholder_capsule_shape_2d: CollisionShape2D = $PlaceholderCapsuleShape2D

const equipped_rotation : float = PI / 2

var global_equipped_offset : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
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

func unequip(equipped : Item):
	placeholder_capsule_shape_2d.remove_child(equipped)
	equipped.change_state(ConstItemState.inventory)

func equip(equipped : Item):
	if equipped is not Item:
		return
		
	#NOTE This is not necessary as the sowrd is going to be child of the placeholder_capsule itself
	equipped.position.x = 0
	equipped.position.y = 0
	equipped.rotation = 0
	

	placeholder_capsule_shape_2d.shape.height = equipped.equipped_capsule_height
	placeholder_capsule_shape_2d.shape.radius = equipped.equipped_capsule_radius
	placeholder_capsule_shape_2d.rotation = equipped.equipped_capsule_rotation
	# screw this just make placeholder collsion a 'shape' and  'capsule'
	equipped.equipped_capsule_joint1_position
	equipped.equipped_capsule_joint2_position
	
	placeholder_capsule_shape_2d.add_child(equipped)
	
	equipped.change_state(ConstItemState.equipped)
	
	
