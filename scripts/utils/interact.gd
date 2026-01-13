extends Area2D
class_name Interact

@onready var player : Player = get_tree().get_first_node_in_group('player')
var can_interact : bool = false

var interact : Callable

func _on_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		


func _on_body_exited(body):
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed('e') and can_interact:
		
