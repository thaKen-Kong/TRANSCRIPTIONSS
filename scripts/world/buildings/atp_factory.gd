extends StaticBody2D
class_name ATP_FACTORY

@onready var interaction_area : InteractionArea = $InteractionArea

func _ready():
	interaction_area.interact = Callable(self, "collect_atp")
	
func collect_atp():
	pass
