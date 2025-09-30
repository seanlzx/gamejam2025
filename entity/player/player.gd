extends CharacterBody2D

## 1. Importing Scenes 


## 2. Importing other nodes ⭕
@onready var inventory: CanvasLayer = $inventory
# children
@onready var hotbar: CanvasLayer = $inventory/Hotbar
@onready var health_value_bar: ColorRect = $HUD/HealthBar/Value
@onready var health_label: Label = $HUD/HealthBar/Label
@onready var hud: CanvasLayer = $HUD
@onready var overhead_label: Label = $OverheadLabel


## 3.  CONSTANTS
var HEALTH_VALUE_BAR_ORIGINAL_LENGTH : float


## 4. Overwrites ✍️
# Values to overwrite existing node properties
# Derived on my own, Posthumously Claude agreed
@export var property_overwrites : Dictionary = {
	# built in const MOTION_MODE_FLOATING is 1, suitable for **topdown** games
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING,
}


## 5. Class 🏗️
# Stats
@export var max_health: float = ConstDefault.player_max_health
@export var max_energy: float = ConstDefault.player_max_energy
@export var strength: float = ConstDefault.player_strength
# status  (current value)
var health : float = ConstDefault.player_max_health
var energy : float = ConstDefault.player_max_energy
var dead : bool = false






## 6. Built-in Methods 
func _ready():
	intro_screen()
	carryout_property_overwrites()
	HEALTH_VALUE_BAR_ORIGINAL_LENGTH = health_value_bar.size.x
	# NOTE: unfortunately I prob should realized that canvas items can't be easily readjusted
	# will have to imperatively anchor the inventory children to the ground so that it can handle changing resolutions
	

func _process(delta) -> void:
	if dead:
		return
	for i : int in range(hotbar.number_start, hotbar.number_end):
		if Input.is_action_just_pressed("hotbar_" +str(i)):
			hotbar.selected_number(i)
			hotbar.equip_item(hotbar.selectedSlot, self)
			
	if Input.is_action_just_released("hotbar_left"):
		hotbar.selected_left()
		hotbar.equip_item(hotbar.selectedSlot, self)
	if Input.is_action_just_released("hotbar_right"):
		hotbar.selected_right()
		hotbar.equip_item(hotbar.selectedSlot, self)

	hotbar.equipped_process(delta, self)

func _physics_process(delta: float) -> void:
	move_and_slide()


## 7. Methods
func carryout_property_overwrites() -> void:
	# CharacterBody2D
	motion_mode = property_overwrites.motion_mode



func take_damage(damage):
	update_health(health - damage)
	generate_damage_particles(damage)
	
# TODO not a priority
func generate_damage_particles(damage):
	var label = Label.new()
	var rigidBody = RigidBody2D.new()
	label.text = str(int(damage))
	label.rotation = randf_range(-PI / 6, PI /6)
	# this is to make the color darker when more damage done
	label.set("theme_override_colors/font_color", Color((100-damage)/150, 0, 0))
	label.set("theme_override_font_sizes/font_size", clamp(damage*0.3,15,30))
	
	rigidBody.add_child(label)
	rigidBody.linear_velocity = Vector2(randi_range(-50,50),randi_range(-50,50))
	rigidBody.gravity_scale = 0
	
	
	var on_timer_timeout_lambda = func(garbage):
		if is_instance_valid(garbage):
			garbage.queue_free()
	
	var timer := Timer.new()
	timer.wait_time = 1 + (damage / 100) * 2
	timer.one_shot = true
	timer.timeout.connect(on_timer_timeout_lambda.bind(rigidBody))
	
	# NOTE the order of this add_child and timer.start MATTERS
	add_child(rigidBody)
	rigidBody.add_child(timer)
	timer.start()


func update_health(health_arg):
	health = health_arg
	health_value_bar.size.x = HEALTH_VALUE_BAR_ORIGINAL_LENGTH * (health/max_health)
	health_label.text = str(int(health)) + "/" + str(int(max_health))
	print (str(HEALTH_VALUE_BAR_ORIGINAL_LENGTH)+" * (" +str(health)+"/"+str(max_health)+")")
	if (health < 0):
		death()
	
func death():
	# this prevent characters body from moving after dying
	velocity = Vector2.ZERO
	# as players body is still on ground and it's pretty funny to see the NPCs attack a dead body, have this if statement to prevent death titlecard creation
	if dead : 
		return 
		
	death_menu()
	await get_tree().create_timer(1).timeout
	# dumbest way to kill the player, but easiest way to have the death screen inherit the player, queue free will make the death screen disappear as its a child of player
	remove_child(get_node("ScriptAnimation"))
	remove_child(get_node("ScriptPlayerMovement"))
	remove_child(get_node("ScriptRagdoll"))
	remove_child(get_node("ScriptPlayerPickup"))
	dead = true
	
func death_menu():
	var label : Label = Label.new()
	label.text = "Game Over"
	label.set("theme_override_colors/font_color", Color(1, 1, 1))
	label.set("theme_override_font_sizes/font_size", 100)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER)
	
	var label2 : Label = Label.new()
	label2.text = "currently game doesn't have start menu 😅, refresh browser"
	label2.set("theme_override_colors/font_color", Color(1, 1, 1))
	label2.set("theme_override_font_sizes/font_size", 10)
	label2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label2.set_anchors_preset(Control.PRESET_CENTER)
	label2.position.y += 120
	
	overhead_label.z_index = 1
	
	# NOTE again dirty fix, have the death screen spawn as child of player so that the font is centered but than reparent before queue_free()
	# NOTE DIRTIER FIX teloport player back to starting area, because camera will move to center after character death
	overhead_label.add_child(label)
	overhead_label.add_child(label2)
	overhead_label.text = 'RIP'

func intro_screen():
	var black_screen : ColorRect = ColorRect.new()
	black_screen.color = Color(0, 0, 0, 1)
	black_screen.size = Vector2(2403, 1536)
	black_screen.position = Vector2(-1030, -709)
	black_screen.z_index = 1
	
	var number_of_lines = 10
	var line_array : Array[Label] = []
	var line_position_y = 450
	for i in range(number_of_lines):
		var line : Label = Label.new()
		line.scale = Vector2(2, 2)
		line.position = Vector2(800, line_position_y)
		line_position_y += 50
		line_array.append(line) 
		black_screen.add_child(line)
		
	add_child(black_screen)
	
	#region line sequencing 
	await get_tree().create_timer(1.5).timeout
	line_array[0].text = "I"
	
	await get_tree().create_timer(1.5).timeout
	line_array[0].text = "I.. I"
	
	await get_tree().create_timer(0.8).timeout
	line_array[1].text = "Yes?"
	
	await get_tree().create_timer(1.5).timeout
	line_array[2].text = "I.."
	
	await get_tree().create_timer(1.5).timeout
	line_array[2].text = "I.. I need..."
	
	await get_tree().create_timer(0.8).timeout
	line_array[3].text = "Yes?!"
	
	await get_tree().create_timer(0.3).timeout
	line_array[3].text = "Yes?! Yes?!"
	
	await get_tree().create_timer(1.5).timeout
	line_array[4].text = "I need"
	
	await get_tree().create_timer(2).timeout
	line_array[4].text = "I need mo..."
	
	await get_tree().create_timer(0.3).timeout
	line_array[5].text = "YES?!?!??!?!"
	
	await get_tree().create_timer(0.3).timeout
	line_array[5].text = "YES?!?!??!?! YESSSS?!?!??!"
	
	await get_tree().create_timer(1).timeout
	line_array[6].text = "I"
	
	await get_tree().create_timer(0.2).timeout
	line_array[6].text = "I NEED"
	
	await get_tree().create_timer(0.2).timeout
	line_array[6].text = "I NEED MONEYYYY"
	#region
	
	await get_tree().create_timer(2).timeout
	for line in line_array:
		line.velocity = Vector2(randi_range(100,150),randi_range(100,150))
	
	black_screen.color = Color(0, 0, 0, 0.9)
	await get_tree().create_timer(0.25).timeout
	black_screen.color = Color(0, 0, 0, 0.8)
	await get_tree().create_timer(0.25).timeout
	black_screen.color = Color(0, 0, 0, 0.7)
	await get_tree().create_timer(0.25).timeout
	black_screen.color = Color(0, 0, 0, 0.6)
	await get_tree().create_timer(0.25).timeout
	black_screen.color = Color(0, 0, 0, 0.5)
	await get_tree().create_timer(0.25).timeout
	black_screen.color = Color(0, 0, 0, 0.4)
	await get_tree().create_timer(0.25).timeout
	black_screen.color = Color(0, 0, 0, 0.3)
	await get_tree().create_timer(0.25).timeout
	black_screen.color = Color(0, 0, 0, 0.2)
	await get_tree().create_timer(0.25).timeout
	black_screen.color = Color(0, 0, 0, 0.1)
	await get_tree().create_timer(0.25).timeout
	
	black_screen.queue_free()
