extends RigidBody2D



func _ready(): 
	# because arrow is child of bow, if the bow moves, so does the arrow. so 
	reparent(get_tree().root)
	
	await get_tree().create_timer(15).timeout
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
	await get_tree().create_timer(2).timeout
	queue_free()
	pass
