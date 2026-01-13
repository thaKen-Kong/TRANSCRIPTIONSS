extends HBoxContainer
class_name ButtonPalette

@export var segment_node: Segment_mRNA
const ATP_COST_PER_PRESS := 0.1

func _ready() -> void:
	$A.pressed.connect(Callable(self, "_on_button_pressed").bind("A"))
	$U.pressed.connect(Callable(self, "_on_button_pressed").bind("U"))
	$C.pressed.connect(Callable(self, "_on_button_pressed").bind("C"))
	$G.pressed.connect(Callable(self, "_on_button_pressed").bind("G"))

func _on_button_pressed(base: String) -> void:
	if segment_node:
		segment_node.select_base_for_slot(segment_node.current_index, base)

	# Deduct ATP per button press
	if segment_node.get_parent().has_method("_deduct_atp"):
		segment_node.get_parent()._deduct_atp(ATP_COST_PER_PRESS)
