extends Node

# References to tutorial objects
var dna: DNA
var nucleolus: Nucleolus
var exit_site: Node
var cutscene: Node

func register_objects(_dna: DNA, _nucleolus: Nucleolus, _exit_site: Node, _cutscene: Node) -> void:
	dna = _dna
	nucleolus = _nucleolus
	exit_site = _exit_site
	cutscene = _cutscene

# ------------------------
# Tutorial Step Functions
# ------------------------

func start_pre_initiation() -> void:
	if dna:
		dna._on_interact_pre_initiation()

func start_initiation() -> void:
	if dna and dna.active_rnap:
		dna._on_drop_place_object_placed(dna.active_rnap)

func start_elongation() -> void:
	if dna:
		dna._start_elongation()

func finish_elongation() -> void:
	if dna:
		dna._finish_elongation()

func spawn_mRNA() -> void:
	if dna:
		dna._spawn_mRNA()

func show_exit_site() -> void:
	if exit_site:
		exit_site.show()

func restart_transcription() -> void:
	if dna:
		dna.restart_transcription()

func focus_node(node: Node, duration: float = 1.0) -> void:
	if cutscene and is_instance_valid(node):
		cutscene.focus_on(node, duration)
