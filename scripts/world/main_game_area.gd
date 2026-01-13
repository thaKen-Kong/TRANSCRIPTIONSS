extends Node2D
class_name GAME_LEVEL

# =========================
# NODES
# =========================
@export var cutscene: Cutscene
@onready var dna_spawn_point: Marker2D = $Map/DNA_SPAWN_POINT

# =========================
# LEVEL CONFIG
@export var exit_site: DropPlace
@export var dna_objects: Array[DNA] = []
@export var deliveries_required: int = 3
@export var reward_per_delivery: int = 10
@export var level_duration: float = 200.0
@export var reward_scene: PackedScene

# =========================
# INTERNAL STATE
var deliveries_done: int = 0
var timer: float = 0.0
var game_active: bool = false

# =========================
func _ready() -> void:
	# Hide DNA until level starts
	cutscene.play([
		func(): cutscene.focus_on($Map/player, 0.8),
		func(): cutscene.wait(2.0)
	])
	
	for dna in dna_objects:
		dna.hide()

	# Connect exit site
	if exit_site:
		exit_site.object_placed.connect(_on_exit_site_object_placed)

	# Connect DNA minigame signals
	for dna in dna_objects:
		dna.minigame_completed.connect(_on_dna_phase_completed)

	print("GAME_LEVEL ready. Waiting for start trigger.")

	# Load config from GameState
	if GameState.next_level_config:
		var cfg = GameState.next_level_config
		level_duration = cfg.get("time_limit", level_duration)
		deliveries_required = cfg.get("deliveries_required", deliveries_required)
		reward_per_delivery = cfg.get("reward", reward_per_delivery)

		if dna_objects.size() > 0:
			dna_objects[0].dna_sequence_template = cfg.get("dna_sequence", dna_objects[0].dna_sequence_template)

		GameState.next_level_config = null

# =========================
func start_level() -> void:
	if dna_objects.is_empty():
		push_error("No DNA objects assigned!")
		return

	game_active = true
	timer = level_duration
	deliveries_done = 0

	var dna := dna_objects[0]
	_setup_dna(dna)

	# Play cutscene first
	await get_tree().create_timer(0.4).timeout
	if cutscene:
		cutscene.play([
			func(): cutscene.focus_on(dna),
			func(): cutscene.wait(0.5),
			func(): cutscene.focus_on(dna.dna_start),
			func(): cutscene.wait(1.0),
			func(): cutscene.focus_on(dna.dna_end),
			func(): cutscene.wait(1.0)
		])

	print("Level started.")

# =========================
func _setup_dna(dna: DNA) -> void:
	dna.deliveries_required = deliveries_required
	dna.deliveries_done = deliveries_done
	dna.delivered_label.text = "DELIVERED: 0/%d" % deliveries_required
	dna.timer_label.text = "Time Left: %.1fs" % timer

	dna.show()
	dna._spawn_self(dna_spawn_point.global_position)

# =========================
func _process(delta: float) -> void:
	if not game_active:
		return

	timer -= delta
	timer = max(timer, 0)

	if dna_objects.size() > 0:
		dna_objects[0].timer_label.text = "Time Left: %.1fs" % timer

	if timer <= 0:
		_finish_level()

# =========================
# DELIVERY HANDLING
func _on_exit_site_object_placed(obj: GrabbableObject) -> void:
	if not game_active:
		return

	obj.can_be_grabbed = false
	obj.is_held = false
	obj.holder = null
	obj.global_position = exit_site.global_position

	deliveries_done += 1

	if dna_objects.size() > 0:
		var dna = dna_objects[0]
		dna.delivered_label.text = "DELIVERED: %d/%d" % [deliveries_done, deliveries_required]

		await get_tree().create_timer(0.5).timeout
		dna.restart_transcription()

	if deliveries_done >= deliveries_required:
		_finish_level()

# =========================
# DNA PHASE TRACKING
func _on_dna_phase_completed(phase_name: String) -> void:
	print("DNA phase completed:", phase_name)

	if phase_name == "PARING" and dna_objects.size() > 0:
		var dna := dna_objects[0]
		if dna.mRNA_scene:
			var mRNA = dna.mRNA_scene.instantiate()
			mRNA.global_position = dna.global_position + Vector2(0, -32)
			get_tree().current_scene.add_child(mRNA)
			print("mRNA spawned.")

# =========================
# LEVEL END
func _finish_level() -> void:
	if not game_active:
		return

	game_active = false
	print("Level finished.")

	if reward_scene == null:
		push_error("Reward scene not assigned!")
		return

	var reward = reward_scene.instantiate()
	reward.deliveries_done = deliveries_done
	reward.deliveries_required = deliveries_required
	reward.time_left = timer
	reward.reward_per_delivery = reward_per_delivery

	get_tree().root.add_child(reward)
