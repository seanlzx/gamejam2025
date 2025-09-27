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
	await get_tree().create_timer(30).timeout
	queue_free()
	pass

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
