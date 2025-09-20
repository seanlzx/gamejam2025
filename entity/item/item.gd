class_name Item extends RigidBody2D

var ItemState : String = ConstItemState.pickup

var is_pickup_show = false

var pickup_tooltip

func show_pickup_tooltip():
	if is_pickup_show:
		return
	pickup_tooltip.show()
	is_pickup_show = true

func hide_pickup_tooltip():
	if not is_pickup_show:
		return
	pickup_tooltip.hide()
	is_pickup_show = false
