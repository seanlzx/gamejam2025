extends Node


# I like this, the forums say this might be dangerous but I like this
@onready var character: CharacterBody2D = $".."

var rigid_body_mass = 50.0
var rigid_body_gravity_scale = 0.0

var rigid_body_friction = 1.0 # floating point, 1 is max
var rigid_body_rough = true

var rigid_body_collision_layer = ConstCollisionLayer.ragdoll
var rigid_body_collision_mask = ConstCollisionLayer.ragdoll

# this is a floating point value, 
# - value 0 is the center
# - value 1.0 will be the very upper/bottom edge of the collisionShape
var pin_joints_displacement_from_center = 0.5
var pin_joints_softness = 0

func _ready():
	carryout_property_overwrites()
	generate_ragdoll_nodes()

func carryout_property_overwrites() -> void:
	
	var rigid_body : RigidBody2D = character.get_node("RigidBody2D")
	
	# RigidBody2D
	rigid_body.mass = rigid_body_mass
	rigid_body.gravity_scale = rigid_body_gravity_scale
	
	var physics_material : PhysicsMaterial = PhysicsMaterial.new()
	physics_material.friction = rigid_body_friction
	physics_material.rough = rigid_body_rough
	
	# THIS is physics_material_overwrite NOT property_overwrites 😠 fuck you
	rigid_body.physics_material_override = physics_material
	
	rigid_body.collision_layer = rigid_body_collision_layer
	rigid_body.collision_mask = rigid_body_collision_mask
	
# Called when the node enters the scene tree for the first time.

# This function is dependent on:
# 1. Having the correct node structure
# 2. That the $RigidBody2D/CollisionShape2D has measureable dimensions
# It will then carryout node creation and assign appropriate properties to achieve a ragdoll effect
func generate_ragdoll_nodes() -> void:
	var cs : CollisionShape2D = character.get_node("PlaceholderCollisionShape2D")
	var rbcs : CollisionShape2D = character.get_node("RigidBody2D/CollisionShape2D")

	# 1. placeholderColisionshape copies RigidBody CollisionShape
	cs.shape = rbcs.shape
	cs.position = rbcs.position
	cs.rotation = rbcs.rotation
	cs.scale = rbcs.scale
	cs.skew = rbcs.skew
	
	var TopPinJoint = PinJoint2D.new()
	var BottomPinJoint = PinJoint2D.new()

	# 2. PinJoint overwrites
	TopPinJoint.softness = pin_joints_softness
	BottomPinJoint.softness = pin_joints_softness

	# 3. assigned correct PinJointNodes, if unsure do test out the node, print the paths
	TopPinJoint.node_a = NodePath("../..")
	TopPinJoint.node_b = NodePath("../../RigidBody2D")
	BottomPinJoint.node_a = NodePath("../..")
	BottomPinJoint.node_b = NodePath("../../RigidBody2D")


	# 4. calculate and assign the displacement from center, 
	# 4.1 Also check if the collisionShape is compatible with this logic
	var edge_to_center_length : float

	if rbcs.shape is CircleShape2D:
		edge_to_center_length = rbcs.shape.radius
	elif rbcs.shape is CapsuleShape2D:
		edge_to_center_length = rbcs.shape.height / 2
	elif rbcs.shape is RectangleShape2D:
		edge_to_center_length = rbcs.shape.y / 2
	else:
		push_error("the `generate_ragdoll_nodes()` function is only designed for CircleShape2D, CapsuleShape2D and RectangleShape2D. Due to difficulties calculating distance between center and edges for other shapes not of the aforementioned.")
		get_tree().quit()
		
	# NOTE: Even if you rotate the CapsuleShape, 
	# because the pin joints are children of the Capsule, 
	# their positions will be relative to the parent.
	# Therefore aligned as per the code below.
	# TODO: calculate displace from center
	TopPinJoint.position.y -= edge_to_center_length * pin_joints_displacement_from_center
	BottomPinJoint.position.y += edge_to_center_length * pin_joints_displacement_from_center
		
			
	# NOTE: add as child of CollisionShape for ease of position in above lines of code
	cs.add_child(TopPinJoint)
	cs.add_child(BottomPinJoint)
