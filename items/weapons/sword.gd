extends RigidBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var ActionDict : Dictionary [ String, String ] =  {
	idle = "RESET",
	slash = "slash",
	block = "block"
}
var prev_action : String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("primary_action"):
		print("poop")
		run_action( ActionDict.slash )
		
	if Input.is_action_pressed("secondary_action"):
		print("pee")
		run_action( ActionDict.block )
	
	run_action( ActionDict.idle )

func run_action( action : String ):
	if action == null || action == prev_action:
		return
		
	if animation_player.is_playing():
		return
	
	print ("sword: " + action)
	animation_player.play(action)
	prev_action = action
	
