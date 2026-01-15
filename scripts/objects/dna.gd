extends StaticBody2D
class_name DNA

signal minigame_completed(phase_name: String)

# =========================
# PHASES
enum PHASES {
	PRE_INITIATION,
	INITIATION,
	ELONGATION,
	TERMINATION,
	PARING
}

var current_phase: PHASES = PHASES.PRE_INITIATION

# =========================
# CONFIG
var dna_sequence_template: String = ""
var deliveries_required: int
var deliveries_done: int = 0

@export var mRNA_scene: PackedScene
@export var rna_polymerase_scene: PackedScene
@export var rna_spawn_position: Vector2 = Vector2(0, -64)
@export var elongation_speed: float = 300

@export var promoter_region_minigame: PackedScene
@export var rna_polymerase_minigame: PackedScene
@export var pre_termination_minigame: PackedScene
@export var termination_minigame_scene: PackedScene
@export var mRNA_trigger_scene: PackedScene
@export var base_pairing_minigame_scene: PackedScene

@export var tutorial_mode: bool = false

# =========================
# NODES
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var drop_place: DropPlace = $PROMOTER_REGION
@onready var termination_visual: Sprite2D = $TerminationSite
@onready var mRNA_Spawn: Marker2D = $mRNA_SPAWN_POINT
@onready var rnap_spawn: Marker2D = $RNAP_SPAWNPOINT
@onready var rna_polymerase_texture: Sprite2D = $TerminationSite/RnaPolymerase
@onready var termination_marker: Marker2D = $TerminationMarker
@onready var dna_start = $"dna-Start"
@onready var dna_end = $"dna-End"

# =========================
# STATE
var active_rnap: Node2D
var elongating: bool = false
var spawned_nodes: Array[Node] = []
var _interaction_locked: bool = false
var _cutscene_node: Node = null
var _elongation_target: Vector2
var _mRNA_trigger_spawned: bool = false

# =========================
func _ready() -> void:
	position = Vector2(0, -2000)
	termination_visual.hide()
	rna_polymerase_texture.hide()

	if drop_place:
		drop_place.object_placed.connect(_on_drop_place_object_placed)
		drop_place.hide()

	if interaction_area:
		interaction_area.interact = Callable(self, "_on_interact_pre_initiation")
		interaction_area.set_process_input(false)
		_hide_interaction_area()

	if tutorial_mode and get_parent():
		_cutscene_node = get_parent().get_node_or_null("Cutscene")

	_setup_phase(current_phase)

# =========================
func _setup_phase(phase: PHASES) -> void:
	current_phase = phase

	match phase:
		PHASES.PRE_INITIATION:
			_interaction_locked = false
			_show_interaction_area()
			interaction_area.set_process_input(true)
		PHASES.INITIATION, PHASES.ELONGATION, PHASES.TERMINATION, PHASES.PARING:
			_interaction_locked = true
			_hide_interaction_area()
			interaction_area.set_process_input(false)
			if phase == PHASES.ELONGATION:
				_start_elongation()

# =========================
# INTERACTION AREA CONTROL
func _show_interaction_area() -> void:
	if not interaction_area:
		return
	interaction_area.show_outline(true)
	interaction_area.show_label(true)
	interaction_area.monitoring = true
	interaction_area.monitorable = true

func _hide_interaction_area() -> void:
	if not interaction_area:
		return
	interaction_area.show_outline(false)
	interaction_area.show_label(false)
	interaction_area.monitoring = false
	interaction_area.monitorable = false

# =========================
# PLAYER INTERACTION
func _on_interact_pre_initiation(player: Node2D) -> void:
	if _interaction_locked:
		return

	_interaction_locked = true
	_hide_interaction_area()
	interaction_area.set_process_input(false)

	if promoter_region_minigame:
		var minigame_instance = promoter_region_minigame.instantiate()
		add_child(minigame_instance)
		spawned_nodes.append(minigame_instance)
		minigame_instance.minigame_finished.connect(_on_promoter_minigame_finished)

# =========================
func _on_promoter_minigame_finished(dna_sequence: String, promoter_index: int) -> void:
	current_phase = PHASES.INITIATION

	if rna_polymerase_scene:
		active_rnap = rna_polymerase_scene.instantiate()
		add_child(active_rnap)
		spawned_nodes.append(active_rnap)
		active_rnap.global_position = global_position + rna_spawn_position

	if drop_place:
		drop_place.show()

	_setup_phase(current_phase)

# =========================
func _on_drop_place_object_placed(obj: GrabbableObject) -> void:
	if current_phase != PHASES.INITIATION:
		return

	active_rnap = obj
	spawned_nodes.append(obj)
	obj.can_be_grabbed = false
	obj.is_held = false
	obj.holder = null
	obj.global_position = drop_place.global_position

	interaction_area.set_process_input(false)

	if rna_polymerase_minigame:
		var mini = rna_polymerase_minigame.instantiate()
		add_child(mini)
		spawned_nodes.append(mini)

# =========================
# PHASE COMPLETION
func _on_phase_completed(phase_name: String) -> void:
	emit_signal("minigame_completed", phase_name)

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.update_phase_display(phase_name)

	match phase_name:
		"PRE_INITIATION":
			_setup_phase(PHASES.INITIATION)
		"INITIATION":
			if drop_place:
				drop_place.hide()
			_setup_phase(PHASES.ELONGATION)
			termination_visual.show()
		"ELONGATION":
			_setup_phase(PHASES.TERMINATION)
		"TERMINATION":
			_setup_phase(PHASES.PARING)
			if not _mRNA_trigger_spawned and mRNA_trigger_scene:
				var trigger = mRNA_trigger_scene.instantiate()
				add_child(trigger)
				spawned_nodes.append(trigger)
				trigger.global_position = mRNA_Spawn.global_position
				trigger.dna_sequence = dna_sequence_template
				_mRNA_trigger_spawned = true
		"PARING":
			pass

# =========================
# ELONGATION
func _start_elongation() -> void:
	if not active_rnap or not termination_visual:
		push_warning("No active RNA polymerase or termination site.")
		return

	_elongation_target = termination_marker.global_position
	active_rnap.global_position = rnap_spawn.global_position
	elongating = true

	if rna_polymerase_texture:
		rna_polymerase_texture.hide()

func _process(delta: float) -> void:
	if current_phase != PHASES.ELONGATION or not elongating or not active_rnap:
		return

	var dir = (_elongation_target - active_rnap.global_position).normalized()
	var distance = active_rnap.global_position.distance_to(_elongation_target)
	var step = min(elongation_speed * delta, distance)
	active_rnap.global_position += dir * step
	active_rnap.rotation = dir.angle()

	var bar := active_rnap.get_node_or_null("ProgressBar")
	if bar:
		var total_distance = (global_position + rna_spawn_position).distance_to(_elongation_target)
		bar.value = 100.0 * (1.0 - distance / total_distance)

	if distance <= 1.0:
		_finish_elongation()

func _finish_elongation() -> void:
	elongating = false
	if is_instance_valid(active_rnap):
		active_rnap.queue_free()
	active_rnap = null

	if rna_polymerase_texture:
		rna_polymerase_texture.modulate.a = 0.0
		rna_polymerase_texture.show()
		var tween = get_tree().create_tween()
		tween.tween_property(rna_polymerase_texture, "modulate:a", 1.0, 0.3)

	if pre_termination_minigame:
		var pre = pre_termination_minigame.instantiate()
		add_child(pre)
		spawned_nodes.append(pre)
	if termination_minigame_scene:
		var term = termination_minigame_scene.instantiate()
		add_child(term)
		spawned_nodes.append(term)
		term.termination_complete.connect(_on_termination_minigame_complete)

	_on_phase_completed("ELONGATION")

func _on_termination_minigame_complete(success: bool) -> void:
	_on_phase_completed("TERMINATION")

# =========================
# SPAWN WITH CAMERA SHAKE
func spawn_to_position(target_pos: Vector2) -> void:
	position = target_pos + Vector2(0, -200)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.1).set_ease(Tween.EASE_IN)
	await tween.finished
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.camera.start_shake(12, 0.5)

# =========================
# RESET
func restart_transcription() -> void:
	# Free all spawned nodes
	for node in spawned_nodes:
		if is_instance_valid(node):
			node.queue_free()
	spawned_nodes.clear()
	active_rnap = null
	elongating = false
	_elongation_target = Vector2.ZERO
	_mRNA_trigger_spawned = false

	if termination_visual:
		termination_visual.hide()
	if rna_polymerase_texture:
		rna_polymerase_texture.hide()
	if drop_place:
		drop_place.hide()

	# Reset phase
	current_phase = PHASES.PRE_INITIATION
	_setup_phase(current_phase)

	# Reactivate interaction area
	if interaction_area:
		interaction_area.interact = Callable(self, "_on_interact_pre_initiation")
		interaction_area.set_process_input(true)
		_show_interaction_area()
	_interaction_locked = false
