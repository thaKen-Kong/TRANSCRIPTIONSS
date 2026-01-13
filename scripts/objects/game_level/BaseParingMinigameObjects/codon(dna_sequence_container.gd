extends GridContainer
class_name CodonBoxContainer

@export var dna_sequence: String = ""               
@export var codon_boxes: Array[CodonBox] = []       # assign 4 CodonBoxes

const CODON_LENGTH := 3
const MAX_CODONS := 4
const REQUIRED_DNA_LENGTH := CODON_LENGTH * MAX_CODONS

var codons: Array[String] = []  
var current_index: int = 0      

func _ready() -> void:
	if dna_sequence != "":
		_split_dna_to_codons()
		_update_codon_boxes()

func _split_dna_to_codons() -> void:
	var clean_sequence = dna_sequence.to_upper()
	assert(clean_sequence.length() == REQUIRED_DNA_LENGTH, "DNA must be exactly 12 bases")
	assert(codon_boxes.size() == MAX_CODONS, "CodonBoxContainer requires 4 CodonBoxes")

	codons.clear()
	for i in range(0, REQUIRED_DNA_LENGTH, CODON_LENGTH):
		codons.append(clean_sequence.substr(i, CODON_LENGTH))

func _update_codon_boxes() -> void:
	for i in range(MAX_CODONS):
		var codon = codons[i]
		var box = codon_boxes[i]
		box.set_codon(codon)
		box.set_active(i == 0)

func get_current_codon() -> String:
	return codons[current_index]

func set_active_codon(index: int) -> void:
	current_index = clamp(index, 0, MAX_CODONS - 1)
	for i in range(MAX_CODONS):
		codon_boxes[i].set_active(i == current_index)

func advance_to_next() -> void:
	if current_index < MAX_CODONS - 1:
		set_active_codon(current_index + 1)

func on_codon_attempt(correct: bool) -> void:
	if correct:
		advance_to_next()
