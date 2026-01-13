# =========================
# LetterBox.gd
# =========================
extends CanvasLayer
class_name LetterBox

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

func show_bars() -> void:
	if animation_player.has_animation("show"):
		animation_player.play("show")

func hide_bars() -> void:
	if animation_player.has_animation("show"):
		animation_player.play_backwards("show")
