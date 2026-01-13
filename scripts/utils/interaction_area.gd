extends Area2D
class_name InteractionArea

@onready var player_ref : Player = get_tree().get_first_node_in_group('player')
@export var action_name : String = "Default Action"

var interact : Callable = func():
	pass

func _on_body_entered(body):
	if body is Player:
		InteractionManager.register_area(self)


func _on_body_exited(body):
	if body is Player:
		InteractionManager.unregister_area(self)
