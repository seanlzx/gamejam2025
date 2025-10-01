extends Node

@onready var player : Player = get_tree().root.get_node("Main/Player")


var quest_array : Array[Quest] = [
	Quest.new(
		"limehold0",
		"Defeat the false Limeholds",
		"Help happiness clear the library to rent",
		"Help happiness clear the library to rent"
	),
]	

func _ready():
	quest_array[0].infinite_loop_callable = "limehold0"


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
	pass
#endregion
		
	
