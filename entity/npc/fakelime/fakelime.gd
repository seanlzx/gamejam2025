class_name Fakelime extends "res://entity/npc/npc.gd"

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
@export var max_health: float = 200
@export var strength: float = ConstDefault.npc_strength
var health : float = 200
# this variable will be set when NPC detects player in on_body_entered

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
	change_state(ConstNpcState.pace)
	
	# NOTE: this is necessary to ensure it's unique to each instance of enemy
	# NOTE: duplicate the shape and reassign it back
	# NOTE: this results in the same effect as `Local to Scene` checkbox in inspector. Behind the scenes probably similar code.
	detection_shape.shape = detection_shape.shape.duplicate()
	detection_area.body_entered.connect(on_body_entered)
	detection_area.body_exited.connect(on_body_exited)
	
	# NOTE quick dirty fix to get the NPCs to attack upon spawning to the equipment to recognize them as the owner
	# NOTE not necessary here as fakelime DOES NOT spawn with equipment
	#equipped_pivot_point.equipped.primary_action(0, self)

	entity_name = "Fakelime"
	entity_description = "He is Limey"

	var random_hostile_dialog_array = [
		"UNACCEPTABLE",
		"UNACCEPTABLEE",
		"UNAACCCEEPPTABLLEE",
		"EEEEEEEEEEEEEEEEEEE",
		"U stands for UNACCEPTABLEEEEE",
	]
	var random_hostile_dialog = random_hostile_dialog_array[randi_range(0, random_hostile_dialog_array.size() - 1)]

	var hostile_dialog_data = [
		{
			# NOTE this id must be unique as it can be referenced by dialog_processor
			id = 0,
			text = random_hostile_dialog,
			# both the NPC dialogue and Player dialogue options are limited to 380 px width, and will wrap downwards, set the height of the box
			height = 25,
			options = [
				{
					text = "...",
					height = 25,
					# array of arguments to put into function
					results_arg = [],
					# function to run
					results = "end_dialog"
				},
			],
		}
	]

	dialog_data = [
		{
			# NOTE this id must be unique as it can be referenced by dialog_processor
			id = 0,
			text = "...",
			# both the NPC dialogue and Player dialogue options are limited to 380 px width, and will wrap downwards, set the height of the box
			height = 25,
			options = [
				{
					text = "Are you happiness?",
					height = 25,
					# array of arguments to put into function
					results_arg = [1],
					# function to run
					results = "dialog_processor"
				},
				{
					text = "This one seems like a nice fellow?",
					height = 25,
					# array of arguments to put into function
					results_arg = [2],
					# function to run
					results = "dialog_processor"
				},
				{
					text = "I’ve come to meet happiness",
					height = 25,
					# array of arguments to put into function
					results_arg = [3],
					# function to run
					results = "dialog_processor"
				},
			],
		},
		{
			# NOTE this id must be unique as it can be referenced by dialog_processor
			id = 1,
			text = "Do I look happy to you?",
			# both the NPC dialogue and Player dialogue options are limited to 380 px width, and will wrap downwards, set the height of the box
			height = 25,
			options = [
				{
					text = "...",
					height = 25,
					# array of arguments to put into function
					results_arg = [],
					# function to run
					results = "end_dialog"
				},
			],
		},
		{
			# NOTE this id must be unique as it can be referenced by dialog_processor
			id = 2,
			text = "u…un…una…",
			# both the NPC dialogue and Player dialogue options are limited to 380 px width, and will wrap downwards, set the height of the box
			height = 25,
			options = [
				{
					text = "...",
					height = 25,
					# array of arguments to put into function
					results_arg = [],
					# function to run
					results = "end_dialog"
				},
			],
		},
		{
			# NOTE this id must be unique as it can be referenced by dialog_processor
			id = 3,
			text = "I love you",
			# both the NPC dialogue and Player dialogue options are limited to 380 px width, and will wrap downwards, set the height of the box
			height = 25,
			options = [
				{
					text = "...",
					height = 25,
					# array of arguments to put into function
					results_arg = [],
					# function to run
					results = "end_dialog"
				},
			],
		},
	]

func _process(delta) -> void:
		
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

func add_quest_and_end_dialog(quest : Quest, npc : NPC = null):
	player.add_quest(quest)
	quest.dict_references = { npc = self}
	end_dialog()
	change_state(ConstNpcState.pace)
	
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
		if NPCState == ConstNpcState.chase:
			return
		change_state(ConstNpcState.idle_only)
		dialog_processor(0)
		
func on_body_exited(body) -> void:
	# check the body is a player. "if it works it's not stupid"
	if body.get_node_or_null("ScriptPlayerMovement") != null:
		print("NPC lost player")
		end_dialog()
		change_state(ConstNpcState.pace)
		
func aggro():
	health_value_bar.color = Color.RED
	await get_tree().create_timer(2).timeout
	end_dialog()
	change_state(ConstNpcState.idle)
	
	sprite_2d.frame = 1
	await get_tree().create_timer(2).timeout
	
	equipped_pivot_point.equip(load("res://entity/item/tool/pot/pot.tscn").instantiate())
	
	change_state(ConstNpcState.chase)
