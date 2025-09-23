extends CanvasLayer
@onready var overhead_label: Label = $"../OverheadLabel"
@onready var player: CharacterBody2D = $".."


const Item = "res://entity/item/item.gd"

const inventory_column_count = 9

@onready var backpack: CanvasLayer = $Backpack
@onready var hotbar: CanvasLayer = $Hotbar
@onready var dropInv: CanvasLayer = $Drop
@onready var DraggedItemSprite: Sprite2D = $DraggedItem
@onready var dropInvButton = dropInv.get_node("Button")
@onready var equipped_pivot_point: RigidBody2D = $"../EquippedPivotPoint"


var previous_slot : Slot
var dragged_item : Item 
var dropped_item : Item
var hovered_slot : Slot
var is_over_dropbutton := false

class Slot:
	var id : String
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
	#hotbar.visible = false
	backpack.visible = false
	dropInv.visible = false
	DraggedItemSprite.visible = false
	
	# assign GUI Nodes to inventory object
	for index : int in inventory.backpack:
		var slotObj : Slot = inventory.backpack[index]
		slotObj.id = "backpack" + str(index)
		slotObj.gui = get_node("Backpack/" + str(index))
		var button : Button = slotObj.gui.get_node("Button")
		button.button_down.connect(drag.bind(slotObj))
		button.mouse_entered.connect(assign_drop.bind(slotObj))
		button.mouse_exited.connect(unassign_drop.bind(slotObj))
		
	for index : int in inventory.hotbar:
		var slotObj : Slot = inventory.hotbar[index]
		slotObj.id = "hotbar" + str(index)
		slotObj.gui = get_node("Hotbar/" + str(index))
		var button : Button = slotObj.gui.get_node("Button")
		button.button_down.connect(drag.bind(slotObj))
		button.mouse_entered.connect(assign_drop.bind(slotObj))
		button.mouse_exited.connect(unassign_drop.bind(slotObj))
	
	dropInvButton.mouse_entered.connect(set_is_over_dropbutton.bind(true))
	dropInvButton.mouse_exited.connect(set_is_over_dropbutton.bind(false))
	
	hotbar.selected_number(1)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("hotbar_1"):
		print_inventory()
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()
	
	if dragged_item: 
		drag_process()	
		
func pickup_item(item : Item) -> Slot:
	var ableToFindSlot = false
	for row in [inventory.hotbar, inventory.backpack]:
		for i in range(1, inventory_column_count + 1):
			var slot : Slot = row[i]
			if slot.item == null:
				add_item(item, slot)

				return slot
				
				
	if not ableToFindSlot:
		overhead_label.text = "inventory full"
		trigger_clear_overhead_label_timer() 
	return null


func trigger_clear_overhead_label_timer():
	await get_tree().create_timer(2).timeout
	overhead_label.text = ""
	
	
func toggle_inventory():
	backpack.visible = not backpack.visible
	#hotbar.visible = not hotbar.visible
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
		
func drag(slotObj : Slot):
	if slotObj.item != null :
		equipped_pivot_point.unequip(slotObj.item)
		dragged_item = slotObj.item
		slotObj.item = null
		slotObj.gui.get_node("ItemSprite").texture = null
		previous_slot = slotObj
	
func drag_process():
	DraggedItemSprite.visible = true
	if dragged_item != null:
		DraggedItemSprite.texture = dragged_item.get_node("ItemSprite").texture
		
	DraggedItemSprite.position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_released("primary"):
		if is_over_dropbutton:
			dragged_item.position = player.position 
			get_tree().root.add_child(dragged_item)
			dragged_item.change_state(ConstItemState.pickup)
			remove_dragged_item()
			return
	
		# This is when hovering over empty space bodoh
		if hovered_slot == null:
			print("dragged_item: "+str(dragged_item))
			add_item(dragged_item, previous_slot)
			if hotbar.selectedSlot == previous_slot:
				hotbar.equip_item(previous_slot, player)
			remove_dragged_item()
			return
		
		print("hovered: " +str(hovered_slot.item))
		# when the hovered slot is occupied
		if hovered_slot.item != null: 
			var previous_item : Item = hovered_slot.item
			
			print("hovered: " +str(hovered_slot.item))
			remove_item(hovered_slot)
			print("after hovered: " +str(hovered_slot.item))
			
			add_item(dragged_item, hovered_slot)
			if hotbar.selectedSlot == hovered_slot:
				hotbar.equip_item(hovered_slot, player)
			
			
			add_item(previous_item, previous_slot)
			if hotbar.selectedSlot == previous_slot:
				hotbar.equip_item(previous_slot, player)
			remove_dragged_item()
			
			return 
			
		add_item(dragged_item, hovered_slot)
		if hotbar.selectedSlot == hovered_slot:
			hotbar.equip_item(hovered_slot, player)
		remove_dragged_item()

	
func assign_drop(slotObj : Slot):
	if hovered_slot != null:
		push_error("hovered_slot already occupied")
		get_tree().quit()
	hovered_slot = slotObj
	print("func assign_drop(slotObj : Slot):
. hovered_slot: " + str(hovered_slot))
	
func unassign_drop(slotObj : Slot):
	if hovered_slot == null:
		push_error("hovered_slot already null")
		get_tree().quit()
	hovered_slot = null
	print("unassign_drop. hovered_slot: " + str(hovered_slot))

func set_is_over_dropbutton(is_over_dropbutton_arg : bool):
	is_over_dropbutton = is_over_dropbutton_arg

#region Low level functions
func add_item(item: Item, slot : Slot):
	if slot.item != null:
		push_error("perform add_item(slot) but slot already occupied")
		get_tree().quit()
	slot.item = item
	slot.gui.get_node("ItemSprite").texture = item.get_node("ItemSprite").texture
	

func remove_item(slot : Slot):
	if slot.item == null:
		push_error("perform remove_item(slot) but slot already null")
		get_tree().quit()
	slot.item = null
	slot.gui.get_node("ItemSprite").texture = null

func add_dragged_item(item : Item):
	if dragged_item is Item:
		push_error("perform add_dragged_item(item) but dragged_item already occupied")
		get_tree().quit()
	dragged_item = item
	DraggedItemSprite.texture = dragged_item.get_node("ItemSprite").texture
	DraggedItemSprite.visible = true

func remove_dragged_item():
	if dragged_item == null:
		push_error("perform remove_dragged_item() but dragged_item is not occupied")
		get_tree().quit()
	dragged_item = null
	DraggedItemSprite.texture = null
	DraggedItemSprite.visible = false
#endregion
