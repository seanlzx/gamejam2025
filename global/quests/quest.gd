class_name Quest extends Node


var id : String
var quest_name : String
var small_description : String
## WARNING Big description DOES NOT work with BBCode
var big_description : String
## A string which identifies a callable function via callv
var infinite_loop_callable : String = ""
## An array of arguments to put in infinite_loop_callable
var infinite_loop_callable_arg_array : Array = []
## A way to retrieve any objects relevant to the script
var dict_references : Dictionary

func _init(
	id : String,
	quest_name : String,
	small_description : String,
	big_description : String,
):
	self.id = id
	self.quest_name = quest_name
	self.small_description = small_description
	self.big_description = big_description
