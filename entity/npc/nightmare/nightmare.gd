extends "res://entity/npc/npc.gd"

## 1. Importing Scenes 🎬

## 2. Importing other nodes ⭕
@onready var health_value_bar: ColorRect = $HUD/HealthBar/Value
@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var equipped_pivot_point: RigidBody2D = $EquippedPivotPoint

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
@export var max_health: float = ConstDefault.npc_max_health
@export var strength: float = ConstDefault.npc_strength
var health : float = ConstDefault.npc_max_health
# this variable will be set when NPC detects player in on_body_entered
var player : CharacterBody2D

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
	LootStats.new(30.0, ConstDropsTscnPaths.sword),
	LootStats.new(5.0, ConstDropsTscnPaths.sworg),
	LootStats.new(10.0, ConstDropsTscnPaths.bow)
]

## 6. Built-in Methods 


## 7. Methods

# Stats 

func _ready():
	carryout_property_overwrites()
	HEALTH_VALUE_BAR_ORIGINAL_LENGTH = health_value_bar.size.x
	change_state(ConstNpcState.idle)
	
	# NOTE: this is necessary to ensure it's unique to each instance of enemy
	# NOTE: duplicate the shape and reassign it back
	# NOTE: this results in the same effect as `Local to Scene` checkbox in inspector. Behind the scenes probably similar code.
	detection_shape.shape = detection_shape.shape.duplicate()
	detection_area.body_entered.connect(on_body_entered)
	detection_area.body_exited.connect(on_body_exited)
	
	# NOTE quick dirty fix to get the NPCs to attack upon spawning to the equipment to recognize them as the owner
	equipped_pivot_point.equipped.primary_action(0, self)

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
	print (str(HEALTH_VALUE_BAR_ORIGINAL_LENGTH)+" * (" +str(health)+"/"+str(max_health)+")")
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
		change_state(ConstNpcState.chase)
		
func on_body_exited(body) -> void:
	# check the body is a player. "if it works it's not stupid"
	if body.get_node_or_null("ScriptPlayerMovement") != null:
		print("NPC lost player")
		change_state(ConstNpcState.roam)
