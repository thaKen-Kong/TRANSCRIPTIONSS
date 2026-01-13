@tool
extends Control
class_name PHM_UI

var can_open : bool = false
@export var open : bool = false
@onready var pos = global_position
@onready var parent_node : Node2D = get_parent().get_parent()

#PHASES
@export var binding_phase_done : bool = false
@export var elongation_phase_done : bool = false
@export var pairing_phase_done : bool = false
@export var termination_phase_done : bool = false


func _ready():
	parent_node.emit_signal("call")
	hide()
	displayUI(false)

func displayUI(condition : bool = false):
	var tween = get_tree().create_tween()
	if condition:
		show()
		tween.tween_property(self, "global_position", Vector2(global_position.x, pos.y), 0.5).set_ease(Tween.EASE_IN_OUT)
	else:
		tween.tween_property(self, "global_position", Vector2(global_position.x, pos.y - 2000), 0.5).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		hide()
