extends CanvasLayer

class example:
	var name : String = "DeleteMe"

# It seems like this is the easiest way to get innerclasses from other scripts
const Slot = preload("res://entity/player/inventory.gd").Slot
var selectedSlot : Slot 

const Item = "res://entity/item/item.gd"

@onready var selected_frame_sprite: Sprite2D = $SelectedFrameSprite

@onready var hotbarDict: Dictionary = $"..".inventory.hotbar
var hotbar_number_array

var number_start = 1
var number_end = 9

var equipped : Item

@onready var equipped_pivot_point: RigidBody2D = $"../../EquippedPivotPoint"


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selectedSlot = hotbarDict[1]
	hotbar_number_array = get_hotbar_number_array()
	

## Called every frame. 'delta' is the elapsed time since the previous frame.
func equipped_process(delta: float, player : CharacterBody2D) -> void:
	pass
	#if equipped is Item:
		#equipped.position = player.position

func selected_left():
	var new_number = get_number_from_slot(selectedSlot) + 1
	
	if new_number > number_end:
		new_number = number_start
		
	selected_number(new_number)
	return new_number

func selected_right():
	var new_number = get_number_from_slot(selectedSlot) - 1
	
	if new_number < number_start:
		new_number = number_end
		
	selected_number(new_number)
	return new_number
	
func get_hotbar_number_array():
	var number_array = []
	for index in hotbarDict:
		var hotslot = hotbarDict[index]
		number_array.append(get_number_from_slot(hotslot))
	return number_array

func selected_number(number: int):	
	# check that number is valid and assign selectedSlot
	var is_number_valid = false
	for index in hotbarDict:
		selectedSlot = hotbarDict[index]
		if get_number_from_slot(selectedSlot) == number:
			is_number_valid = true
			break

	if not is_number_valid:
		push_error("hotbar selected_number does not exist")
		get_tree().quit()
	# change selected item position
	
	selected_frame_sprite.position = selectedSlot.gui.position


func equip_item(slot : Slot, player : CharacterBody2D):
	# This is neccesary to deal with variables pointing to objects that are already freed 
	if not is_instance_valid(equipped):
		equipped = null
	if equipped is Item:
		equipped_pivot_point.unequip(equipped)
	
	equipped = slot.item
	
	equipped_pivot_point.equip(equipped)

	
	
func get_number_from_slot(slot : Slot) -> int:
	var regex = RegEx.new()
	regex.compile("\\d+")
	for numeric_string in regex.search_all(slot.id):
		return int(numeric_string.get_string())
	return -1
	
