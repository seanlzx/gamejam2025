extends "res://entity/item/item.gd"

var character : CharacterBody2D

var damage : int = 5


func _ready(): 
	# if physics mask 1 (ragdoll) arrows barely do damage
	# if physics mask 2 (base) arrows do slightly more damage but clip through wall
	# keep arrows as physics mask 2 until hitting an object than physics mask 1
	# this serendipidous also prevents arrows "on floor" damaging the characters TOO MUCH
	# OR JUST GIVE THEM BOTH 1 and 2 😅
	set_collision_layer_value(ConstCollisionLayer.base,true)
	set_collision_mask_value(ConstCollisionLayer.base,true)
	set_collision_layer_value(ConstCollisionLayer.ragdoll,true)
	set_collision_mask_value(ConstCollisionLayer.ragdoll,true)

	linear_damp = 1
	angular_damp = 1 

	# collision detection
	body_entered.connect(impact)
	contact_monitor = true
	max_contacts_reported = 10
	
	pickup_tooltip = $PickupTooltip
	
	pickup_tooltip.hide()
	# because arrow is child of bow, if the bow moves, so does the arrow. so 
	reparent(get_tree().root)
	change_state(ConstItemState.pickup)
	await get_tree().create_timer(45).timeout
	if ItemState == ConstItemState.pickup : 
		queue_free()

#func _process(delta: float) -> void:
	

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# arrows are gonna despawn anyways, so it doesn't actually make sense for them to despawn upon leaving screen, but for performance sake just have it despawn... a little later
	if ItemState == ConstItemState.pickup : 
		await get_tree().create_timer(30).timeout
		queue_free()

func impact(rigid_body):
	if rigid_body is RigidBody2D:
		var collision_point = global_position
		var relative_velocity = linear_velocity - rigid_body.linear_velocity
		var impact_force = relative_velocity.length() * damage * impact_damage_multiplier
		var rigid_body_parent = rigid_body.get_parent()
		# `rigid_body_parent != character` prevents characters from hurting themselves
		if rigid_body_parent.has_method("take_damage") :
			var character_body = rigid_body_parent
			character_body.take_damage(impact_force)
			print("arrow damage")
			
	# depending on amount of impact chance arrow despawns after impact, as you expect in real life some arrows break
		if randi_range(30,60) < impact_force: 
			## NOTE [bug caught 250929 2210] another bug vulnerability, if the arrow is equipped it can break within inventory causing the game to crash. Try making it so that the arrow simply drops from inventory
			#if ItemState == ConstItemState.equipped:
				#position = get_tree().root.get_node("Main/Player").position 
				#get_tree().root.add_child(self)
				#get_tree().root.get_node("Main/Player/inventory").remove_dragged_item()
			## NOTE [bug caught 250929 2200] had a game breaking bug where, because the arrows can still be picked into inventory for 0.2 seconds in this block. Than further references to the missing instance crashed the game. Resolve it by simply making is **inventory state** so it CAN't be pickuped.
			#change_state(ConstItemState.inventory)
			# NOTE [bug fix 250929 2220] all this effort, too much effort, just make it so it only despawn when ConstItemState.pickup
			if ItemState == ConstItemState.pickup : 
				await get_tree().create_timer(0.2).timeout
				queue_free()
	else:
		# this else block means arrow hit something that wasn't rigid body, give it a 50% chance to despawn
		if randi_range(1,2) > 1: 
			#change_state(ConstItemState.inventory)
			#if ItemState == ConstItemState.equipped:
				#position = get_tree().root.get_node("Main/Player").position 
				#get_tree().root.add_child(self)
				#get_tree().root.get_node("Main/Player/inventory").remove_dragged_item()
			if ItemState == ConstItemState.pickup : 
				await get_tree().create_timer(0.2).timeout
				queue_free()
