extends Node

@onready var player : Player = get_tree().root.get_node("Main/Player")

@onready var fakelime1 : Fakelime = get_tree().root.get_node("Main/Fakelime1")
@onready var fakelime2 : Fakelime = get_tree().root.get_node("Main/Fakelime2")
@onready var fakelime3 : Fakelime = get_tree().root.get_node("Main/Fakelime3")
@onready var fakelime4 : Fakelime = get_tree().root.get_node("Main/Fakelime4")

@onready var limehold : Limehold = get_tree().root.get_node("Main/Limehold")

var isPassive :bool = true

var quest_array : Array[Quest] = [
	Quest.new(
		"limehold0",
		"Defeat the false Limeholds",
		"Help happiness clear the library to rent",
		"Help happiness clear the library to rent"
	),
	Quest.new(
		"limehold1",
		"Defeated the false Limeholds, return to limehold",
		"",
		"Defeated the false Limeholds, return to limehold"
	),
]	

func _ready():
	quest_array[0].infinite_loop_callable = "limehold0"
	quest_array[1].infinite_loop_callable = "limehold1"


func _process(delta: float) -> void:
	if player == null: 
		return
	if player._quest_array.size() > 0:
		# if quest is not local than don't run it
		for quest in player._quest_array:
			if quest not in self.quest_array:
				continue
			if quest.infinite_loop_callable != "":
				callv(quest.infinite_loop_callable, quest.infinite_loop_callable_arg_array)
 

#region infinite functions
func limehold0():
	var quest_done = true
	quest_array[0].small_description = "Fakelime:\n"
	
	if isPassive:
		isPassive = false
		if is_instance_valid(fakelime1):
			fakelime1.aggro()
		if is_instance_valid(fakelime2):
			fakelime2.aggro()
		if is_instance_valid(fakelime3):
			fakelime3.aggro()
		if is_instance_valid(fakelime4):
			fakelime4.aggro()
		
	if is_instance_valid(fakelime1):
		quest_array[0].small_description += str(int(fakelime1.position.x)) + " / " + str(int(fakelime1.position.y)) + "\n"
		quest_done = false
	if is_instance_valid(fakelime2):
		quest_array[0].small_description += str(int(fakelime2.position.x)) + " / " + str(int(fakelime2.position.y)) + "\n"
		quest_done = false
	if is_instance_valid(fakelime3):
		quest_array[0].small_description += str(int(fakelime3.position.x)) + " / " + str(int(fakelime3.position.y)) + "\n"
		quest_done = false
	if is_instance_valid(fakelime4):
		quest_array[0].small_description += str(int(fakelime4.position.x)) + " / " + str(int(fakelime4.position.y)) + "\n"
		quest_done = false
		
	if quest_done:
		player.remove_quest(quest_array[0])
		player.add_quest(quest_array[1])
		
		
func limehold1():
	if limehold == null:
		return
	quest_array[1].small_description = str(int(limehold.position.x)) + " / " + str(int(limehold.position.y))
	limehold.dialog_data = limehold.overwrite_dialog_data
#endregion
		
	
