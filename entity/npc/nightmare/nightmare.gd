extends CharacterBody2D


## 1. Importing Scenes 🎬


## 2. Importing other nodes ⭕
@onready var inventory: CanvasLayer = $inventory


## 3. CONSTANTS


## 4. Overwrites ✍️
@export var property_overwrites : Dictionary = {
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING,
}


## 5. Class 🏗️
@export var max_health = ConstDefault.npc_max_health
@export var strength = ConstDefault.npc_strength
var health : int
## 5.1 NPC specifc
# TODO dont need change player offset distance in weapon rather have +- modifiers for NPCs here, then when npcs does equip, get the values from here to modify existing player_offset.
@export var equipped_offset_to_offset: float

## 6. Built-in Methods 


## 7. Methods

# Stats 


func _ready():
	carryout_property_overwrites()

func _process(delta) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	move_and_slide()


func carryout_property_overwrites() -> void:
	# CharacterBody2D
	motion_mode = property_overwrites.motion_mode
