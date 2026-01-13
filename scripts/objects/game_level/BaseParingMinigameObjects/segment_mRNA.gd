extends TextureRect
class_name Segment_mRNA

@export var codon_container: CodonBoxContainer
@export var check_button: Button

var selected_bases: Array[String] = []
var current_index: int = 0

signal codon_filled(correct: bool)

func _ready() -> void:
	_connect_slot_buttons()
	if check_button:
		check_button.pressed.connect(Callable(self, "_on_check_pressed"))

func _connect_slot_buttons() -> void:
	for i in range(3):
		var slot_name = "Slot%d" % (i + 1)
		if has_node(slot_name):
			var button = get_node(slot_name) as Button
			button.pressed.connect(Callable(self, "_on_slot_pressed").bind(i))

func _on_slot_pressed(slot_index: int) -> void:
	current_index = slot_index
	_highlight_selected_slot(slot_index)

func select_base_for_slot(slot_index: int, player_base: String) -> void:
	while selected_bases.size() <= slot_index:
		selected_bases.append("")
	selected_bases[slot_index] = player_base
	_update_slot_visual(slot_index, player_base)

func _on_check_pressed() -> void:
	if not is_codon_filled():
		return
	var correct = _check_codon_correct()
	emit_signal("codon_filled", correct)
	if codon_container:
		codon_container.on_codon_attempt(correct)
	reset_segment()

func is_codon_filled() -> bool:
	return selected_bases.size() == 3 and "" not in selected_bases

func _check_codon_correct() -> bool:
	if not codon_container:
		return false
	var current_dna = codon_container.get_current_codon()
	for i in range(3):
		if selected_bases[i] != _dna_to_rna(current_dna[i]):
			return false
	return true

func _dna_to_rna(dna_base: String) -> String:
	match dna_base.to_upper():
		"A": return "U"
		"T": return "A"
		"G": return "C"
		"C": return "G"
		_: return ""

func _update_slot_visual(slot_index: int, base: String) -> void:
	var slot_name = "Slot%d" % (slot_index + 1)
	if has_node(slot_name):
		var button = get_node(slot_name) as Button
		button.text = base

func _highlight_selected_slot(slot_index: int) -> void:
	for i in range(3):
		var slot_name = "Slot%d" % (i + 1)
		if has_node(slot_name):
			get_node(slot_name).modulate = Color(1,1,1)
	var sel_name = "Slot%d" % (slot_index + 1)
	if has_node(sel_name):
		get_node(sel_name).modulate = Color(0.7,1,0.7)

func reset_segment() -> void:
	selected_bases.clear()
	for i in range(3):
		var slot_name = "Slot%d" % (i + 1)
		if has_node(slot_name):
			get_node(slot_name).text = ""
