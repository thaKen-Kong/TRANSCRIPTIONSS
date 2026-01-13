extends StaticBody2D
class_name QUIZ_HOUSE

@onready var interaction_area : InteractionArea = $InteractionArea

func _ready():
	interaction_area.interact = Callable(self, "open_quiz")

func open_quiz():
	pass
