extends "res://entity/npc/npc.gd"

## 1. Importing Scenes 🎬
@onready var player : Player = get_tree().root.get_node("Main/Player")

## 2. Importing other nodes ⭕
@onready var health_value_bar: ColorRect = $HUD/HealthBar/Value
@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var equipped_pivot_point: RigidBody2D = $EquippedPivotPoint
@onready var sprite_2d: Sprite2D = $RigidBody2D/Sprite2D

## Quite a risky way to get the player character

## 3. CONSTANTS
# Constant idk fuckit
var RNG = RandomNumberGenerator.new()

# this is technically a constants
var HEALTH_VALUE_BAR_ORIGINAL_LENGTH : float

## 4. Overwrites ✍️
@export var property_overwrites : Dictionary = {
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING,
}


## 5. Class 🏗️
@export var max_health: float = 200000
@export var strength: float = ConstDefault.npc_strength
var health : float = 200000
# this variable will be set when NPC detects player in on_body_entered
var health_regen_per_frame : float = 20

class LootStats:
	# note
	var chance : float
	var tscn_path : String
	
	func _init(_chance, _tscn_path):
		chance = _chance
		tscn_path = _tscn_path

## 5.1 NPC specifc
# TODO dont need change player offset distance in weapon rather have +- modifiers for NPCs here, then when npcs does equip, get the values from here to modify existing player_offset.
@export var equipped_offset_to_offset: float = 0222
var loot_array : Array[LootStats] = [
	LootStats.new(5.0, ConstDropsTscnPaths.pot)
]

var idle_range_from: int = 5
var idle_range_to: int = 10

## 5.2 Details

## 6. Built-in Methods 


## 7. Methods

# Stats 

func _ready():
	
	overhead_label = $OverheadLabel

	
	carryout_property_overwrites()
	HEALTH_VALUE_BAR_ORIGINAL_LENGTH = health_value_bar.size.x
	change_state(ConstNpcState.follow_player)
	
	# NOTE: this is necessary to ensure it's unique to each instance of enemy
	# NOTE: duplicate the shape and reassign it back
	# NOTE: this results in the same effect as `Local to Scene` checkbox in inspector. Behind the scenes probably similar code.
	detection_shape.shape = detection_shape.shape.duplicate()
	detection_area.body_entered.connect(on_body_entered)
	detection_area.body_exited.connect(on_body_exited)
	
	# NOTE quick dirty fix to get the NPCs to attack upon spawning to the equipment to recognize them as the owner
	# NOTE not necessary here as clippy DOES NOT spawn with equipment
	#equipped_pivot_point.equipped.primary_action(0, self)

	entity_name = "Clippy"
	entity_description = "clip"

	
	dialog_data = [
		{
			# NOTE this id must be unique as it can be referenced by dialog_processor
			id = 0,
			text = "Howdy Ho! You can call me Clippy! I also go by: Your personal assistant... and best friend. I’ll be guiding you on how to play!!\n\n Your first task is to get a task from me!\n\n Talk to me",
			# both the NPC dialogue and Player dialogue options are limited to 380 px width, and will wrap downwards, set the height of the box
			height = 100,
			options = [
				{
					text = "Hi",
					height = 25,
					# array of arguments to put into function
					results_arg = [],
					# function to run
					results = "complete_talk_quest_and_give_getout_bed_quest"
				},
			],
		},
		{
			id = 1,
			text = "Great! Your second task is: Get out of bed. You can move with [code]WASD[/code]",
			height = 25,
			options = [
			],
		},
		{
			id = 2,
			text = "Good work. It’s in the afternoon... but still!",
			height = 25,
			options = [
				{
					text = "...",
					height = 25,
					# array of arguments to put into function
					results_arg = [QuestClippy.quest_array[2],3],
					# function to run
					results = "add_quest_and_dialog"
				},
			],
		},
		{
			id = 3,
			text = "Next, pick up the Sword with [code]F[/code] please. Press right-click to swing right, left-click to swing left, middle-click to jab!\nTry... Go Ahead... Swing at me a few times! I have a 100,000 health that regenerates!",
			height = 75,
			options = [
			],
		},
		{
			id = 4,
			text = "Amazing work! Remember your swing speed directly affects damage. So swing your mouse real hard to deal lots of it! Press tab to open your inventory. Scroll wheel or number keys to select items on the hotbar (hotbar is the thing at the bottom of your screen). The bow can be shot with right-click.",
			height = 50,
			options = [
				{
					text = "...",
					height = 25,
					# array of arguments to put into function
					results_arg = [5],
					# function to run
					results = "dialog_processor"
				},
			],
		},
		{
			id = 5,
			text = "Now remember, Morgan, what are you here for?",
			height = 25,
			options = [
				{
					text = "Morgan??",
					height = 25,
					# array of arguments to put into function
					results_arg = [6],
					# function to run
					results = "dialog_processor"
				},
			],
		},
		{
			id = 6,
			text = "That’s you, right? Who else would you be?",
			height = 25,
			options = [
				{
					text = "I’m Morgan.",
					height = 25,
					# array of arguments to put into function
					results_arg = [7],
					# function to run
					results = "dialog_processor"
				},
			],
		},
		{
			id = 7,
			text = "And I’ll be Clippy. These emotions been living rent-free in your head for too long now!\n\n And Morgan.\n\n You need to collect rent. Keep em’ in check on their cheque. Look, Encephalon City needs a Sheriff. And you're the man.",
			height = 100,
			options = [
				{
					text = "I’m Morgan.",
					height = 25,
					# array of arguments to put into function
					results_arg = [8],
					# function to run
					results = "dialog_processor"
				},
			],
		},
		{
			id = 8,
			text = "...",
			height = 25,
			options = [
				{
					text = "... ...",
					height = 25,
					# array of arguments to put into function
					results_arg = [9],
					# function to run
					results = "dialog_processor"
				},
			],
		},
		{
			id = 9,
			text = "... ... ...",
			height = 25,
			options = [
				{
					text = "...",
					height = 25,
					# array of arguments to put into function
					results_arg = [10],
					# function to run
					results = "dialog_processor"
				},
			],
		},
		{
			id = 10,
			text = "Simply, you'll need to Gather 3 artifacts from them, or something equivalent of value, to conclude with your duties... Simple?",
			height = 30,
			options = [
				{
					text = "who?",
					height = 25,
					# array of arguments to put into function
					results_arg = [11],
					# function to run
					results = "dialog_processor"
				},
			],
		},
		{
			id = 11,
			text = "Happiness, Sadness, and–",
			height = 25,
			options = [
				{
					text = "And?",
					height = 25,
					# array of arguments to put into function
					results_arg = [12],
					# function to run
					results = "dialog_processor"
				},
			],
		},
		{
			id = 12,
			text = "Not sure about their name yet. Let’s go with static for now.",
			height = 25,
			options = [
				{
					text = "...",
					height = 25,
					# array of arguments to put into function
					results_arg = [13],
					# function to run
					results = "dialog_processor"
				},
			],
		},
		{
			id = 13,
			text = "You can see your own coordinates on the top left of the screen. On the top right you can see your quests status. I just given you 3 quests.",
			height = 35,
			options = [
				{
					text = "...",
					height = 25,
					# array of arguments to put into function
					results_arg = [],
					# function to run
					results = "three_quests"
				},
			],
		},
		
	]
	
	talk_quest()
	# TODO dialog_data(0) for test purposes, remove once not needed
	
func _process(delta) -> void:
	if health <= max_health:	
		health += health_regen_per_frame * delta
	update_health(health)
	process_state(delta)
	pass
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	pass

func carryout_property_overwrites() -> void:
	# CharacterBody2D
	motion_mode = property_overwrites.motion_mode

func take_damage(damage):
	update_health(health - damage)
	generate_damage_particles(damage)
	

func update_health(health_arg):
	health = health_arg
	health_value_bar.size.x = HEALTH_VALUE_BAR_ORIGINAL_LENGTH * (health/max_health)
	if (health < 0):
		death()
	
func death():
	death_animation()
	drop_loot()
	queue_free()

func drop_loot():
	for item in loot_array:
		if RNG.randi_range(1, 100) <= item.chance:
			var drop = load(item.tscn_path).instantiate()
			drop.position = position
			get_tree().root.get_node("Main").add_child(drop)
			
	
# TODO not a priority
func death_animation():
	pass

func on_body_entered(body) -> void:
	# check the body is a player. "if it works it's not stupid"
	if body.get_node_or_null("ScriptPlayerMovement") != null:
		print("NPC detected player")
		player = body
		
func on_body_exited(body) -> void:
	# check the body is a player. "if it works it's not stupid"
	if body.get_node_or_null("ScriptPlayerMovement") != null:
		print("NPC lost player")


func aggro():
	health_value_bar.color = Color.RED
	await get_tree().create_timer(2).timeout
	end_dialog()
	change_state(ConstNpcState.idle)
	
	# TODO Clippy changes to static
	sprite_2d.frame = 1
	await get_tree().create_timer(2).timeout

	# TODO Clippy not gonna use a pot bruh
	equipped_pivot_point.equip(load("res://entity/item/tool/pot/pot.tscn").instantiate())
	
	change_state(ConstNpcState.chase)


func talk_quest():
	dialog_processor(0)
	player.add_quest(QuestClippy.quest_array[0])
	
func complete_talk_quest_and_give_getout_bed_quest():
	player.remove_quest(QuestClippy.quest_array[0])
	dialog_processor(1)
	player.add_quest(QuestClippy.quest_array[1])
	QuestClippy.quest_array[1].dict_references = { clippy = self}
	# logic for quest completion in quest_clippy.gd

func add_quest_and_dialog(quest : Quest, dialog_index : int, clippy : NPC = null):
	player.add_quest(quest)
	dialog_processor(dialog_index)
	quest.dict_references = { clippy = self}

func three_quests():
	player.add_quest(QuestClippy.quest_array[3])
	player.add_quest(QuestClippy.quest_array[4])
	player.add_quest(QuestClippy.quest_array[5])
	end_dialog()
