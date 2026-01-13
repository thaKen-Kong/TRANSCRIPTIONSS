extends Node
class_name FSM

@export var initial_state : State
var current_state : State
var states : Dictionary = {}

@export var entity : CharacterBody2D

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition_state.connect(transition_to_next_state)
	
	if initial_state:
		initial_state.enter(entity)
		current_state = initial_state

func _process(delta):
	if entity and current_state:
		current_state.update(entity, delta)

func transition_to_next_state(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit(entity)
		
	new_state.enter(entity)
	current_state = new_state
