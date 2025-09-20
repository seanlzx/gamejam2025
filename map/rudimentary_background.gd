extends Label
## Description: With usage of text, Create a rudimentary background

@export_group("RudimentaryBackgroundSettings")
## Pattern to be repeated
@export var text_pattern = " [_] "
## The multiplication of `patterns_per_line` and `lines` should not exceed 100000, or lag as fuck
@export var patterns_per_line = 100
@export var lines = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# This ensure text is **centered** and **overflow** is even
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var prep_text = ""
	for i1 in range(1, lines):
		for i2 in range(1, patterns_per_line):
			prep_text += text_pattern
		prep_text += "\n"
	
	text = prep_text
	
	set_anchors_and_offsets_preset(Control.PRESET_CENTER) # this is the code that keeps it all centered
	
