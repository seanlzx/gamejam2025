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

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hotbar_number_array = get_hotbar_number_array()

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func selected_left():
	#TODO
	pass

func selected_right():
	#TODO
	pass
	
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

var previous_equipped : Item

func equip_item(slot : Slot, player : CharacterBody2D):
	if previous_equipped is Item:
		player.remove_child(previous_equipped)
		previous_equipped.ItemState = ConstItemState.inventory
	
	player.add_child(slot.item)
	slot.item.ItemState = ConstItemState.equiped
	
	previous_equipped = slot.item
	
	# despawn previously equipped item
	
func get_number_from_slot(slot : Slot) -> int:
	var regex = RegEx.new()
	regex.compile("\\d+")
	print(slot.id)
	for numeric_string in regex.search_all(slot.id):
		return int(numeric_string.get_string())
	return -1
	
