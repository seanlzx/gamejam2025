extends CharacterBody2D 

@export var walk_speed = 150.0
var movement_speed = 100
@export var sprint_speed = 200.0
@export var starting_health = 100.0


@onready var animation_player: AnimationPlayer = $AnimationPlayer

var selected_item : Dictionary = {
	id = -1,
	obj = null
}

var ItemObjArray : Array =  [
	{
		path = "res://items/weapons/sword.tscn",
		name = "sword",
		loadedObj = load("res://items/weapons/sword.tscn").instantiate(),
		key_index = 1
	},
	{
		path = "res://items/weapons/bow.tscn",
		name = "bow",
		loadedObj = load("res://items/weapons/bow.tscn").instantiate(),
		key_index = 2
	},
	{
		path = null,
		name = null,
		loadedObj = null,
		key_index = 0
	}
]

var AnimationDict =  {
	idle = "idle",
	walk = "walk"
}


var prev_animation : String = AnimationDict.idle;

func _ready() -> void:
	
	pass
	
func _physics_process(delta: float) -> void:
	
	if selected_item.obj != null:
		item_pivot_follow_mouse(selected_item.obj)
		#selected_item.obj.global_transform.origin = position
		
	get_input()
	check_direction()
	
	move_and_slide()
	
func get_input():

	var movement_speed = walk_speed

	var input_direction = Input.get_vector("left", "right", "up", "down")
	if Input.is_action_pressed("shift"):
		movement_speed = sprint_speed
	velocity = input_direction * movement_speed
	
	if Input.is_action_just_pressed("hotbar_0"):
		select_item(0)
	if Input.is_action_just_pressed("hotbar_1"):
		select_item(1);
	if Input.is_action_just_pressed("hotbar_2"):
		select_item(2);
	if Input.is_action_just_pressed("hotbar_3"):
		select_item(3);
	if Input.is_action_just_pressed("hotbar_4"):
		select_item(4);
	
	
func select_item( index_arg : int ):
	if index_arg == selected_item.id:
		return
		
	for itemObj in ItemObjArray:
		if itemObj.key_index == index_arg:
			
			if selected_item.obj is Node:
				selected_item.obj.queue_free()
				#remove_child(selected_item.obj)
			
			# this condition checks for a null itemObj
			# this is an unarm hand
			if itemObj.loadedObj == null:
				return 
				
			#selected_item.obj = itemObj.loadedObj
			selected_item.obj = load(itemObj.path).instantiate()
			selected_item.id = index_arg
			print("before player children:" + str(get_children()))
			add_child(selected_item.obj)
			print("after player children:" + str(get_children()))
		
	
	
func item_pivot_follow_mouse( item: RigidBody2D):
	var direction_vector : Vector2 = item.position.direction_to(get_viewport().get_mouse_position())
	
	item.look_at(get_viewport().get_mouse_position())
	item.rotate(PI/4 *2)
	

func play_animation( animation : String ):
	if animation == null || animation == prev_animation:
		return;
	
	print("play " + animation)
	animation_player.play(animation)
	prev_animation = animation

func check_direction() -> void:

	if velocity.length() == 0:
		play_animation(AnimationDict.idle)
		return 
		
	if velocity.x == 0:
		# ⬆️ 
		if velocity.y < 0:
			play_animation(AnimationDict.walk)
		# ⬇️
		elif velocity.y > 0:
			play_animation(AnimationDict.walk)

	elif velocity.x > 0:
		# ↗️
		if velocity.y < 0:
			play_animation(AnimationDict.walk)
		# ➡️s
		elif velocity.y == 0:
			play_animation(AnimationDict.walk)
			
		# ↘️
		elif velocity.y > 0:
			play_animation(AnimationDict.walk)
			
	elif velocity.x < 0:
		# ↙️
		if velocity.y > 0:
			play_animation(AnimationDict.walk)
		# ⬅️
		elif velocity.y == 0:
			play_animation(AnimationDict.walk)
		# ↖️
		elif velocity.y < 0:
			play_animation(AnimationDict.walk)

	return;
