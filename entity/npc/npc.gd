class_name NPC extends CharacterBody2D

var State = "res://entity/utility/state.gd"


var NPCState : String = ConstNpcState.idle

var pickup_tooltip
var curr_state : State

var dialog_panel : Panel

var dialog_data : Array

var overhead_label : Label

var entity_name : String = "noName"
var entity_description = "noDescription"

@onready var states_dict = {
	ConstNpcState.idle : $States/Idle,
	ConstNpcState.roam : $States/Roam,
	ConstNpcState.chase : $States/Chase,
	ConstNpcState.passive_chase : $States/PassiveChase,
	ConstNpcState.follow_player : $States/FollowPlayer,
	ConstNpcState.pace : $States/Pace,
	ConstNpcState.idle_only : $States/IdleOnly,
} 

func change_state(state):
	# TODO might consider skipping if same as previous state
	## item.gd properties
	if curr_state != null:
		curr_state.exit_state()
	NPCState = state
	states_dict[state].enter_state()
	curr_state = states_dict[state]
	
func process_state(delta):
	states_dict[NPCState].process_state(delta)
	

func dialog_processor(dialog_id):
	if dialog_panel != null:
		dialog_panel.queue_free()
		
	# dialog constants
	const DIALOG_PANEL_WIDTH : int = 400
	var move_to_center = DIALOG_PANEL_WIDTH/2
	const LABEL_WIDTH : int = 380
	const MARGIN : int = 5
	const FONT_SIZE : int = 10
	
	var dialog = dialog_data.filter(func(arg): return arg.id == dialog_id)[0]
	
	# initial dialog prep
	dialog_panel = Panel.new()
	dialog_panel.size.x = DIALOG_PANEL_WIDTH
	dialog_panel.size.y = MARGIN
	dialog_panel.position.x -= move_to_center
	overhead_label.add_child(dialog_panel)
	
	var current_child_node_y = 0
	
	current_child_node_y += MARGIN
	
	# TODO this is suppose to label but make it a button for testing purposes
	var label : RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.set("theme_override_font_sizes/normal_font_size", FONT_SIZE)
	label.set("theme_override_font_sizes/italics_font_size", FONT_SIZE)
	label.set("theme_override_font_sizes/bold_font_size", FONT_SIZE)
	label.set("theme_override_font_sizes/bold_italics_font_size", FONT_SIZE)
	label.set("theme_override_font_sizes/mono_font_size", FONT_SIZE)
	label.size.x = LABEL_WIDTH
	label.position.x += (DIALOG_PANEL_WIDTH-LABEL_WIDTH)/2
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# derived setup
	label.text = dialog.text
	label.size.y = dialog.height
	
	# panel modifications
	dialog_panel.size.y += dialog.height
	dialog_panel.position.y -= dialog.height
	
	# label move down
	label.position.y = current_child_node_y
	current_child_node_y += dialog.height
	
	dialog_panel.add_child(label)
	
	# NOTE no need to reverse options, once added as child the nodes will load from top to bottom
	## duplicate is indeed a SHALLOW COPY which is correct in this case
	#var reversed_options = dialog.options.duplicate()
	## for some reason `dialog.options.duplicate().reverse()` doesn't work
	#reversed_options.reverse()
	for option in dialog.options:
		
		# dialog_panel modifications
		dialog_panel.size.y += option.height + MARGIN
		dialog_panel.position.y -= option.height + MARGIN
		
		# generic setup
		var button : Button = Button.new()
		#button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.size.x = LABEL_WIDTH
		# to center the button
		button.position.x = (DIALOG_PANEL_WIDTH-LABEL_WIDTH)/2
#
		# derived setup
		#button.text = option.text
		button.size.y = option.height
		## - button modifications

		## button move down
		current_child_node_y += MARGIN
		button.position.y = current_child_node_y
		
		## rich text for button
		var richButtonLabel : RichTextLabel = RichTextLabel.new()
		richButtonLabel.bbcode_enabled = true
		richButtonLabel.position.x = (DIALOG_PANEL_WIDTH-LABEL_WIDTH)/2
		richButtonLabel.set("theme_override_font_sizes/normal_font_size", FONT_SIZE)
		richButtonLabel.set("theme_override_font_sizes/italics_font_size", FONT_SIZE)
		richButtonLabel.set("theme_override_font_sizes/bold_font_size", FONT_SIZE)
		richButtonLabel.set("theme_override_font_sizes/bold_italics_font_size", FONT_SIZE)
		richButtonLabel.set("theme_override_font_sizes/mono_font_size", FONT_SIZE)
		richButtonLabel.size.x = LABEL_WIDTH
		richButtonLabel.size.y = option.height
		richButtonLabel.text = option.text
		richButtonLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		richButtonLabel.position.y = current_child_node_y
		
		
		current_child_node_y += option.height
		
		## !!!! actually make the buttons functional
		# I can't belies this actually works
		var run_wrapper = func():
			callv(option.results, option.results_arg)
		button.pressed.connect(run_wrapper)
		
		# order is important for button to remain clickeable
		dialog_panel.add_child(richButtonLabel)
		dialog_panel.add_child(button)
		
		

	dialog_panel.size.y += MARGIN
	dialog_panel.position.y -= MARGIN * MARGIN

	# sort through options back wards
	# spawn directly above head
	#subsequent ones will spawn above head
	
func end_dialog():
	if dialog_panel != null:
		dialog_panel.queue_free()

func generate_damage_particles(damage):
	var label = Label.new()
	var rigidBody = RigidBody2D.new()
	label.text = str(int(damage))
	label.rotation = randf_range(-PI / 6, PI /6)
	# this is to make the color darker when more damage done
	label.set("theme_override_colors/font_color", Color((100-damage)/150, 0, 0))
	label.set("theme_override_font_sizes/font_size", clamp(damage*0.3,15,30))
	
	rigidBody.add_child(label)
	rigidBody.linear_velocity = Vector2(randi_range(-50,50),randi_range(-50,50))
	rigidBody.gravity_scale = 0
	
	
	var on_timer_timeout_lambda = func(garbage):
		if is_instance_valid(garbage):
			garbage.queue_free()
	
	var timer := Timer.new()
	timer.wait_time = 1 + (damage / 100) * 2
	timer.one_shot = true
	timer.timeout.connect(on_timer_timeout_lambda.bind(rigidBody))
	
	# NOTE the order of this add_child and timer.start MATTERS
	add_child(rigidBody)
	rigidBody.add_child(timer)
	timer.start()
