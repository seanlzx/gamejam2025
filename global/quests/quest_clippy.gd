extends Node

@onready var player : Player = get_tree().root.get_node("Main/Player")
@onready var limehold : Limehold = get_tree().root.get_node("Main/Limehold")


var quest_array : Array[Quest] = [
	Quest.new(
		"clippy0",
		"Talk to Clippy",
		"Talk to Clippy, he's the metal box looking thing",
		"Talk to Clippy, he's the box looking thing. He's your best friend. You just met him today."
	),
	Quest.new(
		"clippy1",
		"Get out of bed",
		"Move with [code]WASD[/code]",
		"W to move up\nS to move down\nA to move left\nD to move right"
	),
	Quest.new(
		"clippy2",
		"Swing at Clippy",
		"Swing at Clippy",
		"pick up the Sword with `F`. Press `right-click` to swing left,` left-click` to swing right, `middle-click` to jab!"
	),
	Quest.new(
		"clippy3",
		"Find [rainbow]Happiness[/rainbow]",
		"TODO Insert Happiness Coords",
		"Find Happiness"
	),
	Quest.new(
		"clippy4",
		"Confront [fade]Sadness[/fade]",
		"TODO Insert Sadness Coords",
		"Confront Sadness"
	),
	Quest.new(
		"clippy5",
		"[wave amp=50.0]Static[/wave]",
		"[wave amp=50.0]Static[/wave]",
		"Static"
	),
]	

## NOTE in ready assign quest_array[<index>].infinite_loop_callable to any relevant infinite callables
func _ready():
	## NOTE Similar naming convention for below, unless special
	## - Array Index
	## - Quest.ID
	## - function string
	quest_array[1].infinite_loop_callable = "clippy1"
	quest_array[2].infinite_loop_callable = "clippy2"
	quest_array[3].infinite_loop_callable = "clippy3"

## the process checks if the player has any quests that has an infinite callable
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
## NOTE Below onwards, are function defined for Quest.infinite_loop_callable
func clippy1():
	if (
		Input.is_action_pressed("left") or 
		Input.is_action_pressed("right") or 
		Input.is_action_pressed("up") or 
		Input.is_action_pressed("down")
	):
		player.remove_quest(quest_array[1])
		quest_array[1].dict_references.clippy.dialog_processor(2)
		
func clippy2():
	if quest_array[2].dict_references.clippy.health < quest_array[2].dict_references.clippy.max_health:
		player.remove_quest(quest_array[2])
		# TODO
		quest_array[2].dict_references.clippy.dialog_processor(4)
		
func clippy3():
	if limehold == null:
		return
		
	quest_array[3].small_description = str(int(limehold.position.x)) + " / " + str(int(limehold.position.y))
	
#endregion
		
	
