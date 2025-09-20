extends Node

@onready var character: CharacterBody2D = $".."

var prev_animation = ""

@onready var sprite_2d: Sprite2D = character.get_node("RigidBody2D/Sprite2D")
@onready var animation_player: AnimationPlayer = character.get_node("RigidBody2D/AnimationPlayer")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_animation()


func check_animation():
	var direction : String = "_left"
	
	if character.velocity.x < 0:
		direction = "_left"
	elif character.velocity.x > 0:
		direction = "_right"
	
	if character.velocity != Vector2.ZERO:
		update_animation("walk" + direction)
	else:
		update_animation("idle")
		

		

func update_animation(animation):
	if animation == null or animation == prev_animation:
		return
	
	animation_player.play(animation)
	prev_animation = animation
