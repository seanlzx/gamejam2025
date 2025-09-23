extends Node

const Slot = preload("res://entity/player/inventory.gd").Slot

@onready var player: CharacterBody2D = $".."
@onready var PickupArea: Area2D = player.get_node("PickupArea")
@onready var hotbar: CanvasLayer = $"../inventory/Hotbar"



var Item = "res://entity/item/item.gd"

# NOTE making use of this variable to attempt to get rid of pickup tooltips, not sure how surefire it is though
var prev_closest_item : Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PickupArea.collision_layer = ConstCollisionLayer.ragdoll
	PickupArea.collision_layer = ConstCollisionLayer.ragdoll
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var bodies : Array = PickupArea.get_overlapping_bodies()

	if not is_instance_valid(prev_closest_item): 
		prev_closest_item = null

	if bodies.size() == 0:
		return
	
	var closest_item: Item 
	var closest_distance = INF # INF for infinity😎
	for body : PhysicsBody2D in bodies:
		if body is Item:
			var body_distance = player.position.distance_to(body.position)
			if body_distance < closest_distance:
				closest_distance = body_distance
				closest_item = body
	
	if closest_item == null:
		
		# is _instance_valid important, without it after queue free `prev_closest_item is Item` will cause an error
		if prev_closest_item is Item:
			prev_closest_item.hide_pickup_tooltip()
		return
	
	if closest_item.ItemState == ConstItemState.pickup:
		if (
			prev_closest_item != closest_item 
			and 
			prev_closest_item is Item
		):
			prev_closest_item.hide_pickup_tooltip()
		
		closest_item.show_pickup_tooltip()
		if Input.is_action_just_pressed("interact"):
			
			# previous had the pickup_item() function return true and false
			# instead now have it return available_slot, and if no slot is available it returns null
			var available_slot = player.inventory.pickup_item(closest_item)
			
			if available_slot is Slot:
				closest_item.ItemState = ConstItemState.inventory
				# fuckery
				closest_item.get_parent().remove_child(closest_item)
				
				if available_slot == hotbar.selectedSlot:
					hotbar.equip_item(available_slot, player)
				# TODO still have to account for situations where inventory full
		prev_closest_item = closest_item
