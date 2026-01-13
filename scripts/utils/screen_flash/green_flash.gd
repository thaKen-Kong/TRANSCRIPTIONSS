extends ColorRect
class_name green_flash


func _ready():
	self.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.2).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "modulate:a", 0, 0.2).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()
