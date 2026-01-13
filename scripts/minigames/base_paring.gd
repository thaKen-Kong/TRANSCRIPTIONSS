extends CanvasLayer
class_name BasePairingMinigame

# -------------------------
# Exports
# -------------------------
@export var green_screen: PackedScene
@export var red_screen: PackedScene
@export var dna_sequence: String = ""               # 12-base DNA
@export var codon_container: CodonBoxContainer     # assign in editor
@export var segment_mRNA: Segment_mRNA             # assign in editor
@export var button_palette: ButtonPalette          # assign in editor
@export var base_paired_label: Label               # "Base Paired: X/Y"
@export var atp_label: Label                       # global ATP label (optional)
@export var feedback_delay: float = 0.5            # delay before minigame closes

# Optional reference to the mRNA trigger that spawned this minigame
var trigger_object: Node = null

# -------------------------
# State
# -------------------------
var codons_matched: int = 0
const MAX_CODONS := 4

signal minigame_completed

# -------------------------
# Lifecycle
# -------------------------
func _ready() -> void:
	# Setup codon container
	if codon_container:
		codon_container.dna_sequence = dna_sequence
		codon_container._ready()

	# Link segment and button palette
	if segment_mRNA:
		segment_mRNA.codon_container = codon_container
	if button_palette:
		button_palette.segment_node = segment_mRNA

	# Connect codon filled signal
	if segment_mRNA:
		segment_mRNA.connect("codon_filled", Callable(self, "_on_codon_filled"))

	_update_base_paired_label()
	_update_atp_label()

# -------------------------
# Handle codon submission
# -------------------------
func _on_codon_filled(correct: bool) -> void:
	if correct:
		codons_matched += 1
		_deduct_atp(0.5)    # correct codon cost
		_show_feedback(true)
	else:
		_deduct_atp(2.0)    # wrong codon cost
		_show_feedback(false)

	_update_base_paired_label()
	_update_atp_label()

	if codons_matched >= MAX_CODONS:
		emit_signal("minigame_completed")
		await _show_feedback_and_close()

# -------------------------
# Deduct ATP
# -------------------------
func _deduct_atp(amount: float) -> void:
	if PlayerInfo.player_info:
		PlayerInfo.player_info.atp_points -= amount
		PlayerInfo.player_info.atp_points = max(PlayerInfo.player_info.atp_points, 0)
	_update_atp_label()

# -------------------------
# Show green/red feedback
# -------------------------
func _show_feedback(success: bool) -> void:
	var scene = green_screen if success else red_screen
	if scene:
		var instance = scene.instantiate()
		add_child(instance)

# -------------------------
# Update Base Paired label
# -------------------------
func _update_base_paired_label() -> void:
	if base_paired_label:
		base_paired_label.text = "Paired: %d/%d" % [codons_matched, MAX_CODONS]

# -------------------------
# Update ATP label
# -------------------------
func _update_atp_label() -> void:
	if atp_label:
		atp_label.text = "ATP: %.1f" % [PlayerInfo.player_info.atp_points]

# -------------------------
# Close minigame and transform trigger
# -------------------------
func _show_feedback_and_close() -> void:
	# Wait to show feedback
	if feedback_delay > 0:
		await get_tree().create_timer(feedback_delay).timeout

	# Safely transform trigger into box
	if trigger_object and is_instance_valid(trigger_object) and trigger_object.is_inside_tree():
		if trigger_object.has_method("transform_into_box"):
			trigger_object.transform_into_box()
		else:
			trigger_object.queue_free()
		trigger_object = null

	# Remove minigame itself
	if is_inside_tree():
		queue_free()
