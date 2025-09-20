extends CanvasLayer
@onready var overhead_label: Label = $"../OverheadLabel"

const Item = "res://entity/item/item.gd"

const inventory_column_count = 9

@onready var backpack: CanvasLayer = $Backpack
@onready var hotbar: CanvasLayer = $Hotbar
@onready var dropInv: CanvasLayer = $Drop


var previous_slot : Slot
var dragged_item : Item 

class Slot:
	var gui : Panel
	var item : Item

@export var inventory = {
	# 🥲 all the keys below are indeed ints, but to access need string?
	backpack = {
		1:Slot.new(),
		2:Slot.new(),
		3:Slot.new(),
		4:Slot.new(),
		5:Slot.new(),
		6:Slot.new(),
		7:Slot.new(),
		8:Slot.new(),
		9:Slot.new(),
	},
	hotbar = {
		1:Slot.new(),
		2:Slot.new(),
		3:Slot.new(),
		4:Slot.new(),
		5:Slot.new(),
		6:Slot.new(),
		7:Slot.new(),
		8:Slot.new(),
		9:Slot.new(),
	},
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hotbar.visible = false
	backpack.visible = false
	dropInv.visible = false
	
	# assign GUI Nodes to inventory object
	for index : int in inventory.backpack:
		var slotObj : Slot = inventory.backpack[index]
		slotObj.gui = get_node("Backpack/" + str(index))
		var button : Button = slotObj.gui.get_node("Button")
		button.pressed.connect(dragdrop.bind(slotObj))

	for index : int in inventory.hotbar:
		var slotObj : Slot = inventory.hotbar[index]
		slotObj.gui = get_node("Hotbar/" + str(index))
		var button : Button = slotObj.gui.get_node("Button")
		button.pressed.connect(dragdrop.bind(slotObj))
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("hotbar_1"):
		print_inventory()
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()
		
func pickup_item(item : Item):
	var ableToFindSlot = false
	for row in [inventory.hotbar, inventory.backpack]:
		for i in range(1, inventory_column_count + 1):
			var slot : Slot = row[i]
			if slot.item == null:
				add_item(item, slot)
				return true
				
	if not ableToFindSlot:
		overhead_label.text = "inventory full"
		trigger_clear_overhead_label_timer() 
	return false

func add_item(item: Item, slot : Slot):
	slot.item = item
	slot.gui.get_node("ItemSprite").texture = item.get_node("ItemSprite").texture
	


func trigger_clear_overhead_label_timer():
	await get_tree().create_timer(2).timeout
	overhead_label.text = ""
	
	
func toggle_inventory():
	backpack.visible = not backpack.visible
	hotbar.visible = not hotbar.visible
	dropInv.visible = not dropInv.visible

	
# this function only for testing purposes
func print_inventory():
	print("backpack")
	for index : int in inventory.backpack:
		var slot : Slot = inventory.backpack[index]
		print(
				"index: %d, gui: %s, item: %s" % [
				index,
				slot.gui,
				slot.item
			]
		)
	print("hotbar")
	for index : int in inventory.hotbar:
		var slot : Slot = inventory.hotbar[index]
		print(
				"index: %d, gui: %s, item: %s" % [
				index,
				slot.gui,
				slot.item
			]
		)
		
func dragdrop(slotObj : Slot):
	if slotObj.item != null :
		dragged_item = slotObj.item
		slotObj.item = null
		slotObj.gui.get_node("ItemSprite").texture = null
		
		print(dragged_item)
	previous_slot
	dragged_item
		
		
	
		
