@tool
extends ColorRect
class_name blur

@export var time_in : float = 1.0
@export var time_out : float = 1.0

func _ready():
	var tween = get_tree().create_tween()
	self.modulate.a = 0
	tween.tween_property(self, "modulate:a", 1, 0.2)
