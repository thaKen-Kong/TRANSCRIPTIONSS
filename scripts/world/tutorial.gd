extends Node2D
class_name TutorialScene

# =========================
# NODES
# =========================
@export var player: Player
@export var nucleolus: Nucleolus
@export var dna: DNA
@export var exit_site: Node2D  # DropArea
@export var cutscene: Node

# =========================
# TUTORIAL CONFIG
@export var deliveries_required: int = 1
@export var reward_scene: PackedScene

# =========================
# INTERNAL STATE
var deliveries_done: int = 0
var game_active: bool = false

# =========================
func _ready() -> void:
	# Assign this scene as game_level for nucleolus
	if nucleolus:
		nucleolus.game_level = self

	# Initialize player
	if player:
		player.position = Vector2(0, 0)

	# Initialize DNA
	if dna:
		dna.tutorial_mode = true
		dna._cutscene_node = cutscene
		dna.position = Vector2(0, -2000)  # offscreen initially
		dna.deliveries_required = deliveries_required
		dna.deliveries_done = 0
		dna.delivered_label.text = "DELIVERED: 0/%d" % deliveries_required
		dna.hide()
		dna.minigame_completed.connect(_on_dna_phase_completed)

	# Connect exit site
	if exit_site:
		exit_site.object_placed.connect(_on_exit_site_object_placed)

	print("TutorialScene ready. Tutorial objects initialized.")

# =========================
func start_level() -> void:
	if not dna:
		push_error("No DNA assigned for tutorial!")
		return

	game_active = true
	deliveries_done = 0

	# Show DNA at spawn point
	dna.show()
	dna._spawn_self(Vector2(0, 0))  # tutorial fixed position

	# Optional: play a short tutorial cutscene
	if cutscene:
		cutscene.play([
			func(): cutscene.focus_on(player, 0.5),
			func(): cutscene.wait(1.0),
			func(): cutscene.focus_on(dna, 0.5),
			func(): cutscene.wait(1.0)
		])

	print("Tutorial started.")

# =========================
func _on_exit_site_object_placed(obj: GrabbableObject) -> void:
	if not game_active:
		return

	# Reset object state
	obj.can_be_grabbed = false
	obj.is_held = false
	obj.holder = null
	obj.global_position = exit_site.global_position

	deliveries_done += 1
	dna.delivered_label.text = "DELIVERED: %d/%d" % [deliveries_done, deliveries_required]

	# Restart DNA transcription for tutorial
	await get_tree().create_timer(0.5).timeout
	dna.restart_transcription()

	if deliveries_done >= deliveries_required:
		_finish_tutorial()

# =========================
func _on_dna_phase_completed(phase_name: String) -> void:
	print("Tutorial DNA phase completed:", phase_name)

	if phase_name == "PARING" and dna.mRNA_scene:
		var mRNA = dna.mRNA_scene.instantiate()
		mRNA.global_position = dna.global_position + Vector2(0, -32)
		get_tree().current_scene.add_child(mRNA)
		print("Tutorial mRNA spawned.")

# =========================
func _finish_tutorial() -> void:
	if not game_active:
		return

	game_active = false
	print("Tutorial finished.")

	if reward_scene:
		var reward = reward_scene.instantiate()
		reward.deliveries_done = deliveries_done
		reward.deliveries_required = deliveries_required
		get_tree().root.add_child(reward)
