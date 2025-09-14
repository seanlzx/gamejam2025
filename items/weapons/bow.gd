extends RigidBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal shoot(projectile, direction, location)

var arrow_speed : int = 500;
var sweet_spot_to_avoid_player_arrow_collision : int = 80;

var ActionDict : Dictionary [ String, String ] =  {
	idle = "RESET",
	draw = "draw"
}
var prev_action : String


func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("primary_action"):
		print("poop")
		run_action( ActionDict.draw )
	
	run_action( ActionDict.idle )

func run_action( action : String ):
	if action == null || action == prev_action:
		return
		
	if animation_player.is_playing():
		return
	
	if action == "draw":
		run_draw()
	
	print ("bow: " + action)
	animation_player.play(action)
	prev_action = action
	
func run_draw() -> void:
	await get_tree().create_timer(0.4).timeout
	print("launch arrow")
	
	var arrow = load("res://items/weapons/arrow.tscn").instantiate()
	
	print("bow parent:" + str(get_parent().get_node("CollisionShape2D")))
	

	arrow.position	+= Vector2.UP * sweet_spot_to_avoid_player_arrow_collision

	var velocity = Vector2.UP
	arrow.linear_velocity = velocity.rotated(rotation) * arrow_speed
	# The arrow.read() will reparent 😎😎😎
	add_child(arrow)
	
	print(
		(
			"bow rotation: %s \n" +
			"bow position: %s \n" +
			"arrow rotation: %s \n" +
			"arrow position: %s \n" 
		) % [ 
			rotation,
			position,
			arrow.rotation,
			arrow.position
		]
	)

#region implement later 😎, comment out first to prevent confusion
#func run_draw_wrong_2() -> void:
	#await get_tree().create_timer(0.4).timeout
	#print("launch arrow")
	#
	#var arrow = load("res://items/weapons/arrow.tscn").instantiate()
	#
	#print(
		#(
			#"bow rotation: %s \n" +
			#"bow position: %s \n" +
			#"arrow rotation: %s \n" +
			#"arrow position: %s \n" 
		#) % [ 
			#rotation,
			#position,
			#arrow.rotation,
			#arrow.position
		#]
	#)
	#
	## todo: this is here for debug purposes
	#arrow.get_node("CollisionShape2D").disabled = true
	#add_child(arrow)
	#
## This function is the hero that gotham deserves but not the one it needs right now.
#func run_draw_wrong() -> void:
	#await get_tree().create_timer(0.4).timeout
	#print("launch arrow")
	#
	#var arrow = load("res://items/weapons/arrow.tscn").instantiate()
	#
	#add_child(arrow)
	#
#endregion
