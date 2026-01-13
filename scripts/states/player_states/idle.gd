extends State
class_name Idle

func enter(entity):
	entity.velocity = Vector2.ZERO

func exit(_entity):
	pass

func update(entity, _delta):
	var direction := Input.get_vector("a", "d", "w", "s")

	if direction != Vector2.ZERO:
		transition_state.emit(self, "move")
