class_name Player extends CharacterBody2D

## 1. Importing Scenes 


## 2. Importing other nodes ⭕
@onready var inventory: CanvasLayer = $inventory
# children
@onready var hotbar: CanvasLayer = $inventory/Hotbar
@onready var health_value_bar: ColorRect = $HUD/HealthBar/Value
@onready var health_label: Label = $HUD/HealthBar/Label
@onready var hud: CanvasLayer = $HUD
@onready var overhead_label: Label = $OverheadLabel
@onready var coordinates_label: Label = $HUD/Coordinates
@onready var quests_label: RichTextLabel = $HUD/Quests


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
# TODO put +2000 to health as currently don't have means to upgrade health
@export var max_health: float = ConstDefault.player_max_health + 2000
@export var max_energy: float = ConstDefault.player_max_energy
@export var strength: float = ConstDefault.player_strength
# status  (current value)
# TODO put +2000 to health as currently don't have means to upgrade health
var health : float = ConstDefault.player_max_health + 2000
var energy : float = ConstDefault.player_max_energy
var dead : bool = false
var black_screen: ColorRect
var _quest_array: Array[Quest] = []


## 6. Built-in Methods 
func _ready():
	# TODO disabled temporarily, reenable

	carryout_property_overwrites()
	HEALTH_VALUE_BAR_ORIGINAL_LENGTH = health_value_bar.size.x
	# NOTE: unfortunately I prob should realized that canvas items can't be easily readjusted
	# will have to imperatively anchor the inventory children to the ground so that it can handle changing resolutions
	update_health(health)
	quests_label.bbcode_enabled = true
	quests_label.fit_content = true
	
	intro_screen()
	
	
func _process(delta) -> void:
	check_quests()
	
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

	# TODO kill blackscreen for debug purposes, probably should just keep in final product
	if Input.is_action_just_pressed("hotbar_0"):
		if is_instance_valid(black_screen):
			# NOTE do remove child rather than queue free as timers still runnign in black_screen
			remove_child(black_screen)

	coordinates_label.text = "Coords: " + str(int(position.x)) + "/" + str(int(position.y))

func _physics_process(delta: float) -> void:
	move_and_slide()


## 7. Methods
func carryout_property_overwrites() -> void:
	# CharacterBody2D
	motion_mode = property_overwrites.motion_mode



func take_damage(damage):
	update_health(health - damage)
	generate_damage_particles(damage)


#region Quests
func add_quest(quest : Quest):
	if _quest_array.find_custom(
		func(existing_quest): return existing_quest.id == quest.id
	) != -1: 
		return
	
	var og_quest_name = quest.quest_name
	var og_small_description = quest.small_description
	
	var fade_in = func (quest : Quest):
		quest.quest_name =  "[color=#999999]" +quest.quest_name + "[/color]"
		quest.small_description = "[color=#999999]" + quest.small_description + "[/color]"
		_quest_array.append(quest)
		await get_tree().create_timer(3).timeout
		quest.quest_name = og_quest_name
		quest.small_description = og_small_description
	
	fade_in.call(quest)
	#await get_tree().create_timer(3).timeout
	#actually_add.call(quest)

func remove_quest(quest : Quest):
	var index : int = _quest_array.find_custom( 
		func(existing_quest): return existing_quest.id == quest.id
	)
	
	if index == -1: 
		return
	
	# NOTE if you add strikethrough but don't clear the quest immediately, than the few seconds the quest is still around, my quest_clippy.gd still thinks the quests in running. However a workaround would be to `infinite_loop_callable = null`
	# TODO as of 20251001 1025am the strikethru system is still broken
	#var strikethrough = func (quest : Quest):
		#_quest_array[index].infinite_loop_callable = ""
		#_quest_array[index].quest_name = "[s][color=#999999]" + _quest_array[index].quest_name + "[/color][/s]"
		#_quest_array[index].small_description = "[s][color=#999999]" + _quest_array[index].small_description + "[/color][/s]"

	
	
#region NOTE temporary strikethru alternative part 1/2
	var tempsol1 = "[s][color=#999999]" + _quest_array[index].quest_name + "[/color][/s]\n"
	var tempsol2 = "[s][color=#999999]" + _quest_array[index].small_description + "[/color][/s]"	
#endregion
	
	
	var actually_remove = func (quest : Quest):
		_quest_array.remove_at(index)
			
	#strikethrough.call(quest)
	#await get_tree().create_timer(3).timeout
	actually_remove.call(quest)
	#region NOTE temporary strikethru alternative 2/2
	var richlabel : RichTextLabel= RichTextLabel.new()
	richlabel.bbcode_enabled = true
	richlabel.fit_content = true
	richlabel.size = Vector2(400,50)
	richlabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	richlabel.text += tempsol1 +  tempsol2
	hud.add_child(richlabel)
	richlabel.position = quests_label.position 
	richlabel.position.x -= 400
	await get_tree().create_timer(3).timeout
	quests_label.remove_child(richlabel)
	richlabel.position = quests_label.position 
#endregion

func check_quests():
	quests_label.text = "[font_size=30][b]Quests:[/b][/font_size]"
	if _quest_array.size() > 0:
		for quest in _quest_array:
			quests_label.text += "[indent][indent][hint=" + quest.big_description + "][b]" + quest.quest_name + "[/b][/hint][/indent][/indent]\n" 
			quests_label.text += "[indent][indent][indent][indent][hint=" + quest.big_description + "]" + quest.small_description + "[/hint][/indent][/indent][/indent][/indent]\n" 
	
#endregion
	
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
	black_screen = ColorRect.new()
	black_screen.color = Color(0, 0, 0, 1)
	black_screen.size = Vector2(2403, 1536)
	black_screen.position = Vector2(-1030, -709)
	black_screen.z_index = 1
	
	var number_of_lines = 10
	var line_array : Array[RichTextLabel] = []
	var line_position_y = 450
	for i in range(number_of_lines):
		var line : RichTextLabel = RichTextLabel.new()
		line.scale = Vector2(2, 2)
		line.position = Vector2(800, line_position_y)
		line.size = Vector2(1000,50)
		line.bbcode_enabled = true
		line.fit_content = true
		line_position_y += 50
		line_array.append(line) 
		black_screen.add_child(line)
		
	var skiptext = RichTextLabel.new()
	skiptext.text = "[color=#777777]press 0 to skip intro[/color]"
	skiptext.size = Vector2(200,50)
	skiptext.position = Vector2(1200,900)
	skiptext.bbcode_enabled = true
	black_screen.add_child(skiptext)
		
	add_child(black_screen)
	
	#region line sequencing 
	await get_tree().create_timer(1.5).timeout
	line_array[0].text = "I"
	
	await get_tree().create_timer(1.5).timeout
	line_array[0].text = "I.. I"
	
	await get_tree().create_timer(0.8).timeout
	line_array[1].text = "[color=#777777]Yes?"
	
	await get_tree().create_timer(1.5).timeout
	line_array[2].text = "I.."
	
	await get_tree().create_timer(1.5).timeout
	line_array[2].text = "I.. I need..."
	
	await get_tree().create_timer(0.8).timeout
	line_array[3].text = "[color=#777777]Yes?![/color]"
	
	await get_tree().create_timer(0.3).timeout
	line_array[3].text = "[color=#777777]Yes?! Yes?![/color]"
	
	await get_tree().create_timer(1.5).timeout
	line_array[4].text = "I need"
	
	await get_tree().create_timer(2).timeout
	line_array[4].text = "I need mo..."
	
	await get_tree().create_timer(0.3).timeout
	line_array[5].text = "[color=#777777]YES?!?!??!?![/color]"
	
	await get_tree().create_timer(0.3).timeout
	line_array[5].text = "[color=#777777]YES?!?!??!?! YESSSS?!?!??![/color]"
	
	await get_tree().create_timer(1).timeout
	line_array[6].text = "I"
	
	await get_tree().create_timer(0.2).timeout
	line_array[6].text = "I NEED"
	
	await get_tree().create_timer(0.2).timeout
	line_array[6].text = "I NEED MONEYYYY"
	#region
	
	await get_tree().create_timer(2).timeout
	
	var line_vectory := []
	for line in line_array:
		line_vectory.append(Vector2(randi_range(-10,10),randi_range(-10,10)))
	
	black_screen.color = Color(0, 0, 0, 0.9)
	for i in range(number_of_lines):
		line_array[i].position += line_vectory[i]
	await get_tree().create_timer(0.1).timeout
	black_screen.color = Color(0, 0, 0, 0.8)
	for i in range(number_of_lines):
		line_array[i].position += line_vectory[i]
	await get_tree().create_timer(0.1).timeout
	black_screen.color = Color(0, 0, 0, 0.7)
	for i in range(number_of_lines):
		line_array[i].position += line_vectory[i]
	await get_tree().create_timer(0.1).timeout
	black_screen.color = Color(0, 0, 0, 0.6)
	for i in range(number_of_lines):
		line_array[i].position += line_vectory[i]
	await get_tree().create_timer(0.1).timeout
	black_screen.color = Color(0, 0, 0, 0.5)
	for i in range(number_of_lines):
		line_array[i].position += line_vectory[i]
	await get_tree().create_timer(0.1).timeout
	black_screen.color = Color(0, 0, 0, 0.4)
	for i in range(number_of_lines):
		line_array[i].position += line_vectory[i]
	await get_tree().create_timer(0.1).timeout
	black_screen.color = Color(0, 0, 0, 0.3)
	for i in range(number_of_lines):
		line_array[i].position += line_vectory[i]
	await get_tree().create_timer(0.1).timeout
	black_screen.color = Color(0, 0, 0, 0.2)
	for i in range(number_of_lines):
		line_array[i].position += line_vectory[i]
	await get_tree().create_timer(0.1).timeout
	black_screen.color = Color(0, 0, 0, 0.1)
	for i in range(number_of_lines):
		line_array[i].position += line_vectory[i]
	await get_tree().create_timer(0.1
	).timeout
	
	black_screen.queue_free()
