extends "res://entity/utility/state.gd"

@onready var parent : CharacterBody2D = $"../.."

# Constant idk fuckit
var RNG = RandomNumberGenerator.new()



func enter_state() -> void:
	parent.velocity = Vector2.ZERO
