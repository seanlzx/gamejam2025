extends "res://entity/item/item.gd"

func _ready(): 
	pickup_tooltip = $PickupTooltip
	
	pickup_tooltip.hide()
	# because arrow is child of bow, if the bow moves, so does the arrow. so 
	reparent(get_tree().root)
	change_state(ConstItemState.pickup)
	await get_tree().create_timer(45).timeout
	queue_free()

func _process(delta: float) -> void:
	
	print(
		(
			"arrow rotation: %s \n" +
			"arrow position: %s \n" 
		) % [ 
			rotation,
			position
		]
	)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# arrows are gonna despawn anyways, so it doesn't actually make sense for them to despawn upon leaving screen, but for performance sake just have it despawn... a little later
	await get_tree().create_timer(30).timeout
	queue_free()
	pass
