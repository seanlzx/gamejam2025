extends CharacterBody2D

## 1. Importing Scenes 


## 2. Importing other nodes ⭕
@onready var inventory: CanvasLayer = $inventory
# children
@onready var hotbar: CanvasLayer = $inventory/Hotbar


## 3.  CONSTANTS


## 4. Overwrites ✍️
# Values to overwrite existing node properties
# Derived on my own, Posthumously Claude agreed
@export var property_overwrites : Dictionary = {
	# built in const MOTION_MODE_FLOATING is 1, suitable for **topdown** games
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING,
}


## 5. Class 🏗️
# Stats
@export var max_health = ConstDefault.player_max_health
@export var max_energy = ConstDefault.player_max_energy
@export var strength = ConstDefault.player_strength
# status  (current value)
var health : int
var energy : int







## 6. Built-in Methods 
func _ready():
	carryout_property_overwrites()

func _process(delta) -> void:
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
