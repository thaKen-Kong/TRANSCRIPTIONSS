extends Panel
class_name CodonBox

@onready var label: Label = $Label

@export var active_style: StyleBoxFlat
@export var inactive_style: StyleBoxFlat

func set_codon(text: String) -> void:
	label.text = text
	visible = text != ""


func set_active(active: bool) -> void:
	if active:
		add_theme_stylebox_override("panel", active_style)
	else:
		add_theme_stylebox_override("panel", inactive_style)
